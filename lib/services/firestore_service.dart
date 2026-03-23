import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Groups ──────────────────────────────────────────────────────────────

  Stream<List<GroupModel>> watchUserGroups(String userId) {
    return _db
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GroupModel.fromFirestore(d)).toList());
  }

  Future<GroupModel> createGroup(GroupModel group) async {
    final memberIds = group.members.map((m) => m.userId).toList();
    final doc = await _db.collection('groups').add({
      ...group.toFirestore(),
      'memberIds': memberIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Increment groupCount for all members
    final batch = _db.batch();
    for (final memberId in memberIds) {
      batch.update(
        _db.collection('users').doc(memberId),
        {'groupCount': FieldValue.increment(1)},
      );
    }
    await batch.commit();

    final created = await doc.get();
    return GroupModel.fromFirestore(created);
  }

  Future<void> updateGroup(GroupModel group) async {
    final memberIds = group.members.map((m) => m.userId).toList();
    await _db.collection('groups').doc(group.id).update({
      ...group.toFirestore(),
      'memberIds': memberIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteGroup(String groupId) =>
      _db.collection('groups').doc(groupId).update({'isArchived': true});

  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _db.collection('groups').doc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc);
  }

  // ─── Expenses ────────────────────────────────────────────────────────────

  Stream<List<ExpenseModel>> watchGroupExpenses(String groupId) {
    return _db
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ExpenseModel.fromFirestore(d)).toList());
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final doc = await _db.collection('expenses').add(expense.toFirestore());

    // Update group totals and member balances
    await _updateGroupBalancesOnAdd(expense);

    final created = await doc.get();
    return ExpenseModel.fromFirestore(created);
  }

  Future<void> updateExpense(
      ExpenseModel oldExpense, ExpenseModel newExpense) async {
    final batch = _db.batch();
    batch.update(
        _db.collection('expenses').doc(newExpense.id), newExpense.toFirestore());
    await batch.commit();

    // Reverse old and apply new balance changes
    await _updateGroupBalancesOnRemove(oldExpense);
    await _updateGroupBalancesOnAdd(newExpense);
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    await _db.collection('expenses').doc(expense.id).delete();
    await _updateGroupBalancesOnRemove(expense);
  }

  Future<void> settleDebt({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    final batch = _db.batch();
    final groupRef = _db.collection('groups').doc(groupId);
    final doc = await groupRef.get();
    final group = GroupModel.fromFirestore(doc);

    final updatedMembers = group.members.map((m) {
      if (m.userId == fromUserId) {
        return m.copyWith(balance: m.balance + amount);
      } else if (m.userId == toUserId) {
        return m.copyWith(balance: m.balance - amount);
      }
      return m;
    }).toList();

    batch.update(groupRef, {
      'members': updatedMembers.map((m) => m.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Record settlement as expense
    final settlement = {
      'groupId': groupId,
      'title': 'Settlement',
      'amount': amount,
      'paidBy': fromUserId,
      'splitType': 'equal',
      'splits': [
        {'userId': toUserId, 'userName': '', 'amount': amount, 'isPaid': true}
      ],
      'category': 'other',
      'date': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'isSettled': true,
      'currencyCode': 'USD',
    };
    batch.set(_db.collection('expenses').doc(), settlement);

    await batch.commit();
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  Future<void> _updateGroupBalancesOnAdd(ExpenseModel expense) async {
    final groupRef = _db.collection('groups').doc(expense.groupId);
    final doc = await groupRef.get();
    final group = GroupModel.fromFirestore(doc);

    final updatedMembers = group.members.map((member) {
      double delta = 0.0;
      if (member.userId == expense.paidBy) {
        // Payer gets credited for total amount
        delta += expense.amount;
      }
      // Each person owes their split amount
      final split = expense.splits
          .where((s) => s.userId == member.userId)
          .firstOrNull;
      if (split != null) {
        delta -= split.amount;
      }
      return member.copyWith(balance: member.balance + delta);
    }).toList();

    await groupRef.update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
      'totalExpenses': FieldValue.increment(expense.amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateGroupBalancesOnRemove(ExpenseModel expense) async {
    final groupRef = _db.collection('groups').doc(expense.groupId);
    final doc = await groupRef.get();
    final group = GroupModel.fromFirestore(doc);

    final updatedMembers = group.members.map((member) {
      double delta = 0.0;
      if (member.userId == expense.paidBy) {
        delta -= expense.amount;
      }
      final split = expense.splits
          .where((s) => s.userId == member.userId)
          .firstOrNull;
      if (split != null) {
        delta += split.amount;
      }
      return member.copyWith(balance: member.balance + delta);
    }).toList();

    await groupRef.update({
      'members': updatedMembers.map((m) => m.toMap()).toList(),
      'totalExpenses': FieldValue.increment(-expense.amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
