import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum GroupCategory { home, trip, food, event, couple, other }

class GroupMember extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final double balance; // Positive = owed to this user, Negative = owes

  const GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.balance = 0.0,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) => GroupMember(
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        photoUrl: map['photoUrl'],
        balance: (map['balance'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'balance': balance,
      };

  GroupMember copyWith({double? balance}) => GroupMember(
        userId: userId,
        name: name,
        email: email,
        photoUrl: photoUrl,
        balance: balance ?? this.balance,
      );

  @override
  List<Object?> get props => [userId, name, email, photoUrl, balance];
}

class GroupModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final GroupCategory category;
  final String createdBy;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double totalExpenses;
  final String currencyCode;
  final String? imageUrl;
  final bool isArchived;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.updatedAt,
    this.totalExpenses = 0.0,
    this.currencyCode = 'USD',
    this.imageUrl,
    this.isArchived = false,
  });

  String get categoryEmoji => switch (category) {
        GroupCategory.home => '🏠',
        GroupCategory.trip => '✈️',
        GroupCategory.food => '🍕',
        GroupCategory.event => '🎉',
        GroupCategory.couple => '💑',
        GroupCategory.other => '💼',
      };

  String get categoryLabel => switch (category) {
        GroupCategory.home => 'Home',
        GroupCategory.trip => 'Trip',
        GroupCategory.food => 'Food',
        GroupCategory.event => 'Event',
        GroupCategory.couple => 'Couple',
        GroupCategory.other => 'Other',
      };

  int get memberCount => members.length;

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      category: GroupCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => GroupCategory.other,
      ),
      createdBy: data['createdBy'] ?? '',
      members: (data['members'] as List<dynamic>? ?? [])
          .map((m) => GroupMember.fromMap(m as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      totalExpenses: (data['totalExpenses'] ?? 0.0).toDouble(),
      currencyCode: data['currencyCode'] ?? 'USD',
      imageUrl: data['imageUrl'],
      isArchived: data['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'category': category.name,
        'createdBy': createdBy,
        'members': members.map((m) => m.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'totalExpenses': totalExpenses,
        'currencyCode': currencyCode,
        'imageUrl': imageUrl,
        'isArchived': isArchived,
      };

  GroupModel copyWith({
    String? name,
    String? description,
    GroupCategory? category,
    List<GroupMember>? members,
    DateTime? updatedAt,
    double? totalExpenses,
    String? imageUrl,
    bool? isArchived,
  }) =>
      GroupModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        createdBy: createdBy,
        members: members ?? this.members,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        totalExpenses: totalExpenses ?? this.totalExpenses,
        currencyCode: currencyCode,
        imageUrl: imageUrl ?? this.imageUrl,
        isArchived: isArchived ?? this.isArchived,
      );

  @override
  List<Object?> get props => [
        id, name, description, category, createdBy,
        members, createdAt, totalExpenses, currencyCode,
      ];
}
