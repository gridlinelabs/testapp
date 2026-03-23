import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/typography.dart';
import '../../models/group_model.dart';

class MemberAvatarStack extends StatelessWidget {
  final List<GroupMember> members;
  final double avatarSize;
  final double overlap;
  final int maxVisible;

  const MemberAvatarStack({
    super.key,
    required this.members,
    this.avatarSize = 32,
    this.overlap = 10,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = members.take(maxVisible).toList();
    final extra = members.length - maxVisible;

    return SizedBox(
      width: visible.length * (avatarSize - overlap) + overlap +
          (extra > 0 ? avatarSize : 0),
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: _Avatar(
                member: visible[i],
                size: avatarSize,
                colorIndex: i,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final GroupMember member;
  final double size;
  final int colorIndex;

  const _Avatar({
    required this.member,
    required this.size,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: AppColors.avatarColor(colorIndex),
        image: member.photoUrl != null
            ? DecorationImage(
                image: NetworkImage(member.photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: member.photoUrl == null
          ? Center(
              child: Text(
                member.initials,
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

/// Single large member avatar
class MemberAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final int colorIndex;
  final double size;

  const MemberAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.colorIndex = 0,
    this.size = 40,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.avatarColor(colorIndex),
        image: photoUrl != null
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: photoUrl == null
          ? Center(
              child: Text(
                _initials,
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
