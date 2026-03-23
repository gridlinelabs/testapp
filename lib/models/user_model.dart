import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isPremium;
  final int groupCount;
  final String? phoneNumber;
  final String currencyCode;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.isPremium = false,
    this.groupCount = 0,
    this.phoneNumber,
    this.currencyCode = 'USD',
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] ?? false,
      groupCount: data['groupCount'] ?? 0,
      phoneNumber: data['phoneNumber'],
      currencyCode: data['currencyCode'] ?? 'USD',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'isPremium': isPremium,
        'groupCount': groupCount,
        'phoneNumber': phoneNumber,
        'currencyCode': currencyCode,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    bool? isPremium,
    int? groupCount,
    String? phoneNumber,
    String? currencyCode,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        isPremium: isPremium ?? this.isPremium,
        groupCount: groupCount ?? this.groupCount,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        currencyCode: currencyCode ?? this.currencyCode,
      );

  @override
  List<Object?> get props => [
        id, name, email, photoUrl, createdAt,
        isPremium, groupCount, phoneNumber, currencyCode,
      ];
}
