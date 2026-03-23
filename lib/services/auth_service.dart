import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email & Password ────────────────────────────────────────────────────

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final userModel = UserModel(
      id: credential.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    await _saveUserToFirestore(userModel);
    return userModel;
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchOrCreateUser(credential.user!);
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────

  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return _fetchOrCreateUser(userCredential.user!);
  }

  // ─── Password Reset ──────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ─── Sign Out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── User Profile ────────────────────────────────────────────────────────

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchUser(user.uid);
  }

  Future<UserModel?> _fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> _fetchOrCreateUser(User user) async {
    final existing = await _fetchUser(user.uid);
    if (existing != null) return existing;

    final userModel = UserModel(
      id: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    await _saveUserToFirestore(userModel);
    return userModel;
  }

  Future<void> _saveUserToFirestore(UserModel user) =>
      _firestore.collection('users').doc(user.id).set(user.toFirestore());

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (name != null) await user.updateDisplayName(name);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updates);
    }
  }

  // ─── User lookup by email (for adding to groups) ─────────────────────────

  Future<UserModel?> findUserByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return UserModel.fromFirestore(query.docs.first);
  }
}
