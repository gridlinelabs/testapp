import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_model.dart';

/// AI Receipt Parsing Service
/// Uses Claude API to parse OCR text into structured receipt data

class AiService {
  // API key should be loaded from secure config / env in production
  static const String _claudeApiUrl =
      'https://api.anthropic.com/v1/messages';
  final String apiKey;

  AiService({required this.apiKey});

  /// Parse raw OCR text from a receipt into structured items + total
  Future<ParsedReceipt> parseReceiptText(String ocrText) async {
    final prompt = '''
You are a receipt parsing assistant. Parse the following OCR text from a receipt
and extract all line items with their prices.

Return a JSON object with this exact structure:
{
  "merchant": "Store name (if found)",
  "date": "YYYY-MM-DD (if found, else null)",
  "items": [
    {"name": "Item name", "price": 9.99, "quantity": 1}
  ],
  "subtotal": 29.99,
  "tax": 2.40,
  "total": 32.39,
  "currency": "USD"
}

Rules:
- Clean up item names (fix OCR errors, capitalize properly)
- All prices must be positive numbers
- If quantity is not clear, assume 1
- Ignore non-item lines (loyalty points, store address, etc.)
- Only return valid JSON, no explanation

OCR Text:
$ocrText
''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI parsing failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    final text = (content.first as Map<String, dynamic>)['text'] as String;

    // Extract JSON from response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch == null) throw Exception('No JSON in AI response');

    final parsed = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
    return ParsedReceipt.fromJson(parsed);
  }

  /// Suggest how to split items among people using AI
  Future<Map<String, List<String>>> suggestItemAssignment({
    required List<ReceiptItem> items,
    required List<String> memberNames,
  }) async {
    final itemList = items
        .map((i) => '- ${i.name}: \$${i.price.toStringAsFixed(2)}')
        .join('\n');
    final members = memberNames.join(', ');

    final prompt = '''
You are helping split a restaurant bill. Based on typical ordering patterns,
suggest which items might belong to which person.

Members: $members

Items:
$itemList

Return JSON:
{
  "assignments": {
    "Item name": ["Person1", "Person2"]
  },
  "reasoning": "Brief explanation"
}

Be practical — appetizers/shared dishes should be split among all.
Drinks/mains are usually individual. Return valid JSON only.
''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 512,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    final text = (content.first as Map<String, dynamic>)['text'] as String;

    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch == null) return {};

    final parsed = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
    final assignments = parsed['assignments'] as Map<String, dynamic>? ?? {};

    return assignments.map((key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        ));
  }
}

class ParsedReceipt {
  final String? merchant;
  final String? date;
  final List<ReceiptItem> items;
  final double? subtotal;
  final double? tax;
  final double total;
  final String currency;

  const ParsedReceipt({
    this.merchant,
    this.date,
    required this.items,
    this.subtotal,
    this.tax,
    required this.total,
    this.currency = 'USD',
  });

  factory ParsedReceipt.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? [])
        .map((item) {
          final map = item as Map<String, dynamic>;
          return ReceiptItem(
            name: map['name'] as String? ?? 'Unknown item',
            price: (map['price'] as num?)?.toDouble() ?? 0.0,
            quantity: (map['quantity'] as num?)?.toInt() ?? 1,
          );
        })
        .where((item) => item.price > 0)
        .toList();

    return ParsedReceipt(
      merchant: json['merchant'] as String?,
      date: json['date'] as String?,
      items: rawItems,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
