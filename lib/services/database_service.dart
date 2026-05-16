import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<AppUser> _users = [];
  final List<Task> _tasks = [];
  final List<TaskApplication> _applications = [];
  final Set<String> _favoriteTaskIds = {};
  AppUser? _currentUser;
  bool _initialized = false;
  String? _lastAuthError;

  AppUser? get currentUser => _currentUser;
  String? get lastAuthError => _lastAuthError;

  Future<void> init() async {
    if (_initialized) return;
    await _loadCurrentUser();
    if (_currentUser != null) {
      await _refreshUsers();
      await _refreshTasks();
      await _refreshApplications();
      await _refreshFavorites();
    }
    _initialized = true;
  }

  Future<void> refreshAll() async {
    await _loadCurrentUser();
    if (_currentUser != null) {
      await _refreshUsers();
      await _refreshTasks();
      await _refreshApplications();
      await _refreshFavorites();
    }
  }

  Future<void> _loadCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      _currentUser = null;
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (userDoc.exists) {
        _currentUser = AppUser.fromMap(id: userDoc.id, data: userDoc.data()!);
        _upsertUserCache(_currentUser!);
        return;
      }

      final fallbackUser = AppUser(
        id: fbUser.uid,
        name: fbUser.email?.split('@').first ?? 'User',
        email: fbUser.email ?? '',
        password: '',
        role: UserRole.volunteer,
        joinedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(fbUser.uid).set(fallbackUser.toMap());
      _currentUser = fallbackUser;
      _upsertUserCache(fallbackUser);
    } on FirebaseException {
      _currentUser = AppUser(
        id: fbUser.uid,
        name: fbUser.email?.split('@').first ?? 'User',
        email: fbUser.email ?? '',
        password: '',
        role: UserRole.volunteer,
        joinedAt: DateTime.now(),
      );
      _upsertUserCache(_currentUser!);
    }
  }

  Future<void> _refreshUsers() async {
    final user = _currentUser;
    if (user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(user.id).get();
      if (!doc.exists) return;
      _upsertUserCache(AppUser.fromMap(id: doc.id, data: doc.data()!));
    } on FirebaseException {
      return;
    }
  }

  Future<void> _refreshTasks() async {
    try {
      final snap = await _firestore.collection('tasks').orderBy('postedAt', descending: true).get();
      _tasks
        ..clear()
        ..addAll(snap.docs.map((d) => Task.fromMap(id: d.id, data: d.data())));
    } on FirebaseException {
      return;
    }
  }

  Future<void> _refreshApplications() async {
    final user = _currentUser;
    if (user == null) return;

    try {
      if (user.role == UserRole.volunteer) {
        final snap = await _firestore
            .collection('applications')
            .where('userId', isEqualTo: user.id)
            .get();
        _applications
          ..clear()
          ..addAll(snap.docs.map((d) => TaskApplication.fromMap(id: d.id, data: d.data())));
        return;
      }

      final taskIds = _tasks
          .where((t) => t.organizationId == user.id)
          .map((t) => t.id)
          .toList();
      if (taskIds.isEmpty) {
        final taskSnap = await _firestore
            .collection('tasks')
            .where('organizationId', isEqualTo: user.id)
            .get();
        _tasks
          ..clear()
          ..addAll(taskSnap.docs.map((d) => Task.fromMap(id: d.id, data: d.data())));
      }

      final apps = <TaskApplication>[];
      for (final task in _tasks.where((t) => t.organizationId == user.id)) {
        final snap = await _firestore
            .collection('applications')
            .where('taskId', isEqualTo: task.id)
            .get();
        apps.addAll(snap.docs.map((d) => TaskApplication.fromMap(id: d.id, data: d.data())));
      }
      _applications
        ..clear()
        ..addAll(apps);

      final applicantIds = apps.map((a) => a.userId).toSet();
      await _prefetchUsersByIds(applicantIds);
    } on FirebaseException {
      return;
    }
  }

  Future<void> _refreshFavorites() async {
    _favoriteTaskIds.clear();
    final user = _currentUser;
    if (user == null) return;
    try {
      final snap = await _firestore
          .collection('users')
          .doc(user.id)
          .collection('favorites')
          .get();
      _favoriteTaskIds.addAll(snap.docs.map((d) => d.id));
    } on FirebaseException {
      return;
    }
  }

  Future<AppUser?> login(String email, String password) async {
    try {
      _lastAuthError = null;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await refreshAll();
      return _currentUser;
    } on FirebaseAuthException catch (e) {
      _lastAuthError = e.code.isNotEmpty ? e.code : e.message;
      return null;
    } catch (e) {
      _lastAuthError = e.toString();
      return null;
    }
  }

  Future<GoogleAuthResult?> signInWithGoogle({
    UserRole? role,
    String? orgName,
    String? orgDescription,
  }) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final fbUser = _auth.currentUser;
      if (fbUser == null) return null;

      final userRef = _firestore.collection('users').doc(fbUser.uid);
      final userSnap = await userRef.get();
      if (userSnap.exists) {
        _currentUser = AppUser.fromMap(id: userSnap.id, data: userSnap.data()!);
        _upsertUserCache(_currentUser!);
      } else {
        final displayName = fbUser.displayName ?? googleUser.displayName;
        final name = (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : (fbUser.email?.split('@').first ?? 'User');
        final selectedRole = role ?? UserRole.volunteer;
        final user = AppUser(
          id: fbUser.uid,
          name: name,
          email: fbUser.email ?? googleUser.email,
          password: '',
          role: selectedRole,
          orgName: selectedRole == UserRole.organization ? orgName : null,
          orgDescription: selectedRole == UserRole.organization ? orgDescription : null,
          joinedAt: DateTime.now(),
        );
        await userRef.set(user.toMap());
        _currentUser = user;
        _upsertUserCache(user);
      }

      await refreshAll();
      if (_currentUser == null) return null;
      return GoogleAuthResult(user: _currentUser!, isNewUser: isNewUser);
    } catch (_) {
      return null;
    }
  }

  int getActiveNGOCount() {
    return _tasks.map((t) => t.organizationId).toSet().length;
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    List<String> skills = const [],
    String? orgName,
    String? orgDescription,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = AppUser(
        id: cred.user!.uid,
        name: name,
        email: email,
        password: '',
        role: role,
        skills: skills,
        orgName: orgName,
        orgDescription: orgDescription,
        joinedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      _currentUser = user;
      _upsertUserCache(user);
      await _refreshFavorites();
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _users.clear();
    _tasks.clear();
    _applications.clear();
    _favoriteTaskIds.clear();
    _initialized = false;
  }

  Future<bool> updateUser(AppUser updated) async {
    try {
      await _firestore.collection('users').doc(updated.id).update(updated.toMap());
      _upsertUserCache(updated);
      if (_currentUser?.id == updated.id) {
        _currentUser = updated;
      }

      if (updated.role == UserRole.organization) {
        final orgName = updated.orgName ?? updated.name;
        final query = await _firestore
            .collection('tasks')
            .where('organizationId', isEqualTo: updated.id)
            .get();
        final batch = _firestore.batch();
        for (final doc in query.docs) {
          batch.update(doc.reference, {'organizationName': orgName});
        }
        await batch.commit();
        for (int i = 0; i < _tasks.length; i++) {
          if (_tasks[i].organizationId == updated.id) {
            _tasks[i] = _tasks[i].copyWith(organizationName: orgName);
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Task> getTasks({String? search, String? category, bool onlyOpen = false}) {
    String toSafeLowerCase(String text) {
      return text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
    }

    return _tasks.where((t) {
      if (onlyOpen && t.status != TaskStatus.open) return false;
      if (category != null && category != 'All' && t.category != category) return false;

      if (search != null && search.trim().isNotEmpty) {
        final q = toSafeLowerCase(search.trim());
        final title = toSafeLowerCase(t.title);
        final desc = toSafeLowerCase(t.description);
        final loc = toSafeLowerCase(t.location);

        if (!title.contains(q) && !desc.contains(q) && !loc.contains(q)) return false;
      }
      return true;
    }).toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  List<Task> getTasksByOrg(String orgId) =>
      _tasks.where((t) => t.organizationId == orgId).toList()
        ..sort((a, b) => b.postedAt.compareTo(a.postedAt));

  Task? getTask(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Task> createTask(Task task) async {
    final doc = _firestore.collection('tasks').doc();
    final created = task.copyWith(id: doc.id, postedAt: DateTime.now());
    await doc.set(created.toMap());
    _tasks.insert(0, created);
    return created;
  }

  Future<bool> updateTask(Task updated) async {
    try {
      await _firestore.collection('tasks').doc(updated.id).update(updated.toMap());
      final idx = _tasks.indexWhere((t) => t.id == updated.id);
      if (idx != -1) _tasks[idx] = updated;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final batch = _firestore.batch();
      final taskRef = _firestore.collection('tasks').doc(taskId);
      batch.delete(taskRef);
      final apps = await _firestore
          .collection('applications')
          .where('taskId', isEqualTo: taskId)
          .get();
      for (final doc in apps.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _tasks.removeWhere((t) => t.id == taskId);
      _applications.removeWhere((a) => a.taskId == taskId);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<TaskApplication> getApplicationsForTask(String taskId) =>
      _applications.where((a) => a.taskId == taskId).toList();

  List<TaskApplication> getApplicationsByUser(String userId) =>
      _applications.where((a) => a.userId == userId).toList();

  TaskApplication? getApplicationByUserAndTask(String userId, String taskId) {
    try {
      return _applications.firstWhere((a) => a.userId == userId && a.taskId == taskId);
    } catch (_) {
      return null;
    }
  }

  Future<TaskApplication?> applyForTask({
    required String taskId,
    required String userId,
    required String message,
    required String availability,
  }) async {
    final existing = await _firestore
        .collection('applications')
        .where('taskId', isEqualTo: taskId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return null;

    final appDoc = _firestore.collection('applications').doc();
    final app = TaskApplication(
      id: appDoc.id,
      taskId: taskId,
      userId: userId,
      message: message,
      availability: availability,
      appliedAt: DateTime.now(),
      status: ApplicationStatus.pending,
    );

    final taskRef = _firestore.collection('tasks').doc(taskId);
    await _firestore.runTransaction((tx) async {
      final taskSnap = await tx.get(taskRef);
      if (!taskSnap.exists) throw Exception('Task not found');
      tx.set(appDoc, app.toMap());
      tx.update(taskRef, {'volunteersApplied': FieldValue.increment(1)});
    });

    _applications.add(app);
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks[taskIndex] = task.copyWith(volunteersApplied: task.volunteersApplied + 1);
    }
    return app;
  }

  Future<bool> updateApplicationStatus(String appId, ApplicationStatus status) async {
    try {
      await _firestore.collection('applications').doc(appId).update({'status': status.name});
      final idx = _applications.indexWhere((a) => a.id == appId);
      if (idx != -1) {
        _applications[idx] = _applications[idx].copyWith(status: status);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  AppUser? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Set<String> getFavoriteTaskIds() {
    return Set<String>.from(_favoriteTaskIds);
  }

  bool isFavoriteTask(String taskId) {
    return _favoriteTaskIds.contains(taskId);
  }

  Future<void> toggleFavoriteTask(String taskId) async {
    final user = _currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.id)
        .collection('favorites')
        .doc(taskId);

    if (_favoriteTaskIds.contains(taskId)) {
      await ref.delete();
      _favoriteTaskIds.remove(taskId);
    } else {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
      _favoriteTaskIds.add(taskId);
    }
  }

  void _upsertUserCache(AppUser user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx == -1) {
      _users.add(user);
    } else {
      _users[idx] = user;
    }
  }

  Future<void> _prefetchUsersByIds(Set<String> userIds) async {
    if (userIds.isEmpty) return;
    final ids = userIds.toList();
    const chunkSize = 10;
    for (int i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, (i + chunkSize) > ids.length ? ids.length : i + chunkSize);
      final snap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        _upsertUserCache(AppUser.fromMap(id: doc.id, data: doc.data()));
      }
    }
  }

}

class GoogleAuthResult {
  final AppUser user;
  final bool isNewUser;

  const GoogleAuthResult({required this.user, required this.isNewUser});
}
