import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// Stream of the current user's groups
final userGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(firestoreServiceProvider).watchUserGroups(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// Selected group for detail view
final selectedGroupIdProvider = StateProvider<String?>((ref) => null);

final selectedGroupProvider = StreamProvider<GroupModel?>((ref) {
  final groupId = ref.watch(selectedGroupIdProvider);
  if (groupId == null) return Stream.value(null);
  return ref
      .watch(firestoreServiceProvider)
      .watchUserGroups('')
      .map((groups) => groups.where((g) => g.id == groupId).firstOrNull);
});

/// Group creation/management notifier
class GroupsNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  GroupsNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<GroupModel?> createGroup(GroupModel group) async {
    state = const AsyncValue.loading();
    GroupModel? created;
    state = await AsyncValue.guard(() async {
      created = await _firestoreService.createGroup(group);
    });
    return created;
  }

  Future<void> updateGroup(GroupModel group) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _firestoreService.updateGroup(group));
  }

  Future<void> deleteGroup(String groupId) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => _firestoreService.deleteGroup(groupId));
  }
}

final groupsNotifierProvider =
    StateNotifierProvider<GroupsNotifier, AsyncValue<void>>((ref) {
  return GroupsNotifier(ref.watch(firestoreServiceProvider));
});

/// Freemium check: max 3 groups for free users
final canCreateGroupProvider = Provider<bool>((ref) {
  final groups = ref.watch(userGroupsProvider).valueOrNull ?? [];
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user?.isPremium == true) return true;
  return groups.length < 3;
});
