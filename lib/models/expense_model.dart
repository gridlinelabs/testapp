import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum SplitType { equal, custom, percentage, byItem }

enum ExpenseCategory {
  food, transport, accommodation, entertainment,
  utilities, shopping, health, other,
}

class ExpenseSplit extends Equatable {
  final String userId;
  final String userName;
  final double amount;
  final bool isPaid;

  const ExpenseSplit({
    required this.userId,
    required this.userName,
    required this.amount,
    this.isPaid = false,
  });

  factory ExpenseSplit.fromMap(Map<String, dynamic> map) => ExpenseSplit(
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        amount: (map['amount'] ?? 0.0).toDouble(),
        isPaid: map['isPaid'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'isPaid': isPaid,
      };

  ExpenseSplit copyWith({bool? isPaid, double? amount}) => ExpenseSplit(
        userId: userId,
        userName: userName,
        amount: amount ?? this.amount,
        isPaid: isPaid ?? this.isPaid,
      );

  @override
  List<Object?> get props => [userId, userName, amount, isPaid];
}

class ReceiptItem extends Equatable {
  final String name;
  final double price;
  final int quantity;
  final List<String> assignedUserIds;

  const ReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.assignedUserIds = const [],
  });

  double get totalPrice => price * quantity;

  factory ReceiptItem.fromMap(Map<String, dynamic> map) => ReceiptItem(
        name: map['name'] ?? '',
        price: (map['price'] ?? 0.0).toDouble(),
        quantity: map['quantity'] ?? 1,
        assignedUserIds: List<String>.from(map['assignedUserIds'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'assignedUserIds': assignedUserIds,
      };

  ReceiptItem copyWith({
    String? name,
    double? price,
    int? quantity,
    List<String>? assignedUserIds,
  }) =>
      ReceiptItem(
        name: name ?? this.name,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        assignedUserIds: assignedUserIds ?? this.assignedUserIds,
      );

  @override
  List<Object?> get props => [name, price, quantity, assignedUserIds];
}

class ExpenseModel extends Equatable {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String paidBy; // userId
  final String paidByName;
  final SplitType splitType;
  final List<ExpenseSplit> splits;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;
  final String? notes;
  final String? receiptImageUrl;
  final List<ReceiptItem>? receiptItems;
  final String currencyCode;
  final bool isSettled;

  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.paidByName,
    required this.splitType,
    required this.splits,
    required this.category,
    required this.date,
    required this.createdAt,
    this.notes,
    this.receiptImageUrl,
    this.receiptItems,
    this.currencyCode = 'USD',
    this.isSettled = false,
  });

  String get categoryEmoji => switch (category) {
        ExpenseCategory.food => '🍕',
        ExpenseCategory.transport => '🚗',
        ExpenseCategory.accommodation => '🏨',
        ExpenseCategory.entertainment => '🎬',
        ExpenseCategory.utilities => '💡',
        ExpenseCategory.shopping => '🛒',
        ExpenseCategory.health => '💊',
        ExpenseCategory.other => '📝',
      };

  String get categoryLabel => switch (category) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.accommodation => 'Accommodation',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.utilities => 'Utilities',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.other => 'Other',
      };

  double amountOwedBy(String userId) {
    final split = splits.where((s) => s.userId == userId).firstOrNull;
    return split?.amount ?? 0.0;
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paidBy: data['paidBy'] ?? '',
      paidByName: data['paidByName'] ?? '',
      splitType: SplitType.values.firstWhere(
        (e) => e.name == data['splitType'],
        orElse: () => SplitType.equal,
      ),
      splits: (data['splits'] as List<dynamic>? ?? [])
          .map((s) => ExpenseSplit.fromMap(s as Map<String, dynamic>))
          .toList(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      receiptImageUrl: data['receiptImageUrl'],
      receiptItems: data['receiptItems'] != null
          ? (data['receiptItems'] as List<dynamic>)
              .map((i) => ReceiptItem.fromMap(i as Map<String, dynamic>))
              .toList()
          : null,
      currencyCode: data['currencyCode'] ?? 'USD',
      isSettled: data['isSettled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'groupId': groupId,
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'paidByName': paidByName,
        'splitType': splitType.name,
        'splits': splits.map((s) => s.toMap()).toList(),
        'category': category.name,
        'date': Timestamp.fromDate(date),
        'createdAt': Timestamp.fromDate(createdAt),
        'notes': notes,
        'receiptImageUrl': receiptImageUrl,
        'receiptItems': receiptItems?.map((i) => i.toMap()).toList(),
        'currencyCode': currencyCode,
        'isSettled': isSettled,
      };

  @override
  List<Object?> get props => [
        id, groupId, title, amount, paidBy, splitType,
        splits, category, date, isSettled,
      ];
}

/// Optimal debt settlement transaction
class SettlementTransaction {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;

  const SettlementTransaction({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
  });
}

/// Calculates minimal transactions to settle all debts
List<SettlementTransaction> calculateMinimalTransactions(
  Map<String, double> balances, // userId -> net balance
  Map<String, String> userNames, // userId -> name
) {
  final transactions = <SettlementTransaction>[];
  final creditors = <MapEntry<String, double>>[];
  final debtors = <MapEntry<String, double>>[];

  for (final entry in balances.entries) {
    if (entry.value > 0.01) {
      creditors.add(entry);
    } else if (entry.value < -0.01) {
      debtors.add(MapEntry(entry.key, -entry.value));
    }
  }

  creditors.sort((a, b) => b.value.compareTo(a.value));
  debtors.sort((a, b) => b.value.compareTo(a.value));

  int i = 0, j = 0;
  final creditAmounts = creditors.map((e) => e.value).toList();
  final debitAmounts = debtors.map((e) => e.value).toList();

  while (i < creditors.length && j < debtors.length) {
    final settle = creditAmounts[i] < debitAmounts[j]
        ? creditAmounts[i]
        : debitAmounts[j];

    transactions.add(SettlementTransaction(
      fromUserId: debtors[j].key,
      fromUserName: userNames[debtors[j].key] ?? 'Unknown',
      toUserId: creditors[i].key,
      toUserName: userNames[creditors[i].key] ?? 'Unknown',
      amount: double.parse(settle.toStringAsFixed(2)),
    ));

    creditAmounts[i] -= settle;
    debitAmounts[j] -= settle;

    if (creditAmounts[i] < 0.01) i++;
    if (debitAmounts[j] < 0.01) j++;
  }

  return transactions;
}
