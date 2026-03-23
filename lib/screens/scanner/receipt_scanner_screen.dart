import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/buttons.dart';
import '../../models/expense_model.dart';
import '../../models/group_model.dart';
import '../../providers/groups_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/common/loading_overlay.dart';
import '../expenses/add_expense_screen.dart';

// Provider for AI service (API key should be loaded from secure config)
final aiServiceProvider = Provider<AiService>((ref) {
  // In production: load from secure storage or environment variable
  const apiKey = String.fromEnvironment('CLAUDE_API_KEY', defaultValue: '');
  return AiService(apiKey: apiKey);
});

class ReceiptScannerScreen extends ConsumerStatefulWidget {
  final String groupId;

  const ReceiptScannerScreen({super.key, required this.groupId});

  @override
  ConsumerState<ReceiptScannerScreen> createState() =>
      _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState
    extends ConsumerState<ReceiptScannerScreen> {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer();

  File? _imageFile;
  String? _rawText;
  ParsedReceipt? _parsed;
  bool _isProcessing = false;
  String _statusMessage = '';
  List<ReceiptItem> _editableItems = [];

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );
      if (picked == null) return;

      setState(() {
        _imageFile = File(picked.path);
        _isProcessing = true;
        _statusMessage = 'Reading receipt...';
        _parsed = null;
        _editableItems = [];
      });

      await _processImage(File(picked.path));
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
      _showSnack('Failed to pick image: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      // Step 1: OCR with ML Kit
      setState(() => _statusMessage = 'Running OCR...');
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await _textRecognizer.processImage(inputImage);
      final rawText = recognized.text;

      if (rawText.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
        });
        _showSnack('Could not read text from image');
        return;
      }

      setState(() {
        _rawText = rawText;
        _statusMessage = 'Parsing with AI...';
      });

      // Step 2: AI parsing
      final aiService = ref.read(aiServiceProvider);
      final parsed = await aiService.parseReceiptText(rawText);

      setState(() {
        _parsed = parsed;
        _editableItems = List.from(parsed.items);
        _isProcessing = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
      _showSnack('AI parsing failed: $e');
    }
  }

  Future<void> _proceedToExpense() async {
    if (_editableItems.isEmpty) return;

    final firestoreService = ref.read(firestoreServiceProvider);
    final group = await firestoreService.getGroup(widget.groupId);
    if (group == null || !mounted) return;

    Navigator.pop(context); // close scanner
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(
        group: group,
        prefilledItems: _editableItems,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_editableItems.isNotEmpty)
            TextButton(
              onPressed: _proceedToExpense,
              child: Text(
                'Use',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isProcessing,
        message: _statusMessage,
        child: _imageFile == null
            ? _ScannerHome(
                onCamera: () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
              )
            : _ResultView(
                imageFile: _imageFile!,
                parsed: _parsed,
                editableItems: _editableItems,
                onItemsChanged: (items) =>
                    setState(() => _editableItems = items),
                onRescan: () => setState(() {
                  _imageFile = null;
                  _parsed = null;
                  _editableItems = [];
                }),
                onProceed: _editableItems.isNotEmpty ? _proceedToExpense : null,
              ),
      ),
    );
  }
}

class _ScannerHome extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ScannerHome({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingAll16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppSpacing.shadowPrimary,
            ),
            child: const Center(
              child: Text('🧾', style: TextStyle(fontSize: 56)),
            ),
          ),
          AppSpacing.hX2l,
          Text('Scan Your Receipt', style: AppTypography.headlineSmall,
              textAlign: TextAlign.center),
          AppSpacing.hSm,
          Text(
            'Take a photo or upload from gallery.\nOur AI will parse items and prices automatically.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.hX3l,
          AppGradientButton(
            label: 'Take Photo',
            onPressed: onCamera,
            leadingIcon:
                const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
          AppSpacing.hMd,
          AppButton(
            label: 'Choose from Gallery',
            variant: AppButtonVariant.outline,
            onPressed: onGallery,
            leadingIcon: const Icon(Icons.photo_library_outlined,
                color: AppColors.primary, size: 20),
          ),
          AppSpacing.hX2l,
          // Tips
          Container(
            padding: AppSpacing.paddingAll16,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppSpacing.borderRadiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips for best results',
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.primary)),
                AppSpacing.hSm,
                for (final tip in [
                  'Ensure good lighting',
                  'Keep receipt flat and uncrumpled',
                  'Capture the full receipt in frame',
                  'Avoid glare and shadows',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.primary),
                        AppSpacing.wSm,
                        Text(tip, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatefulWidget {
  final File imageFile;
  final ParsedReceipt? parsed;
  final List<ReceiptItem> editableItems;
  final ValueChanged<List<ReceiptItem>> onItemsChanged;
  final VoidCallback onRescan;
  final VoidCallback? onProceed;

  const _ResultView({
    required this.imageFile,
    required this.parsed,
    required this.editableItems,
    required this.onItemsChanged,
    required this.onRescan,
    this.onProceed,
  });

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  @override
  Widget build(BuildContext context) {
    final parsed = widget.parsed;

    return Column(
      children: [
        // Receipt image thumbnail
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.grey900,
            image: DecorationImage(
              image: FileImage(widget.imageFile),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: AppSpacing.paddingAll16,
              child: OutlinedButton.icon(
                onPressed: widget.onRescan,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: const Text('Rescan',
                    style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ),
          ),
        ),

        if (parsed == null)
          const Expanded(
            child: Center(
              child: AppEmptyState(
                title: 'No items detected',
                message:
                    'Try rescanning with better lighting',
                icon: Text('🔍', style: TextStyle(fontSize: 48)),
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              children: [
                // Merchant / total header
                Container(
                  padding: AppSpacing.paddingAll16,
                  color: AppColors.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (parsed.merchant != null)
                            Text(parsed.merchant!,
                                style: AppTypography.titleMedium),
                          Text(
                            '${widget.editableItems.length} items detected',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total', style: AppTypography.labelSmall),
                          Text(
                            '\$${parsed.total.toStringAsFixed(2)}',
                            style: AppTypography.amountSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Items list (editable)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: widget.editableItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) => _EditableReceiptItemRow(
                      item: widget.editableItems[i],
                      onChanged: (updated) {
                        final items = List<ReceiptItem>.from(
                            widget.editableItems);
                        items[i] = updated;
                        widget.onItemsChanged(items);
                      },
                      onDelete: () {
                        final items = List<ReceiptItem>.from(
                            widget.editableItems);
                        items.removeAt(i);
                        widget.onItemsChanged(items);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Bottom action bar
        if (parsed != null)
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: AppSpacing.shadowMd,
            ),
            child: AppGradientButton(
              label: 'Split These Items',
              onPressed: widget.onProceed,
              leadingIcon:
                  const Icon(Icons.people, color: Colors.white, size: 20),
            ),
          ),
      ],
    );
  }
}

class _EditableReceiptItemRow extends StatefulWidget {
  final ReceiptItem item;
  final ValueChanged<ReceiptItem> onChanged;
  final VoidCallback onDelete;

  const _EditableReceiptItemRow({
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_EditableReceiptItemRow> createState() =>
      _EditableReceiptItemRowState();
}

class _EditableReceiptItemRowState extends State<_EditableReceiptItemRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _priceCtrl =
        TextEditingController(text: widget.item.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Name field
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameCtrl,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => widget.onChanged(widget.item.copyWith(name: v)),
            ),
          ),
          AppSpacing.wSm,
          // Price field
          SizedBox(
            width: 72,
            child: TextField(
              controller: _priceCtrl,
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                prefixText: '\$',
              ),
              onChanged: (v) {
                final price = double.tryParse(v) ?? widget.item.price;
                widget.onChanged(widget.item.copyWith(price: price));
              },
            ),
          ),
          AppSpacing.wSm,
          // Delete button
          GestureDetector(
            onTap: widget.onDelete,
            child: const Icon(Icons.close, size: 18, color: AppColors.grey300),
          ),
        ],
      ),
    );
  }
}
