import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { volunteer, organization }
enum TaskStatus { open, inProgress, completed, cancelled }
enum ApplicationStatus { pending, accepted, rejected }

DateTime _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

UserRole _asUserRole(String? value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.volunteer,
  );
}

TaskStatus _asTaskStatus(String? value) {
  return TaskStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => TaskStatus.open,
  );
}

ApplicationStatus _asApplicationStatus(String? value) {
  return ApplicationStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => ApplicationStatus.pending,
  );
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final List<String> skills;
  final String? bio;
  final String? orgName;
  final String? orgDescription;
  final String? avatarPath;
  final DateTime joinedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.skills = const [],
    this.bio,
    this.orgName,
    this.orgDescription,
    this.avatarPath,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'skills': skills,
      'bio': bio,
      'orgName': orgName,
      'orgDescription': orgDescription,
      'avatarPath': avatarPath,
      'joinedAt': joinedAt,
    };
  }

  factory AppUser.fromMap({required String id, required Map<String, dynamic> data}) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: _asUserRole(data['role'] as String?),
      skills: List<String>.from(data['skills'] ?? const []),
      bio: data['bio'],
      orgName: data['orgName'],
      orgDescription: data['orgDescription'],
      avatarPath: data['avatarPath'],
      joinedAt: _asDateTime(data['joinedAt']),
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    List<String>? skills,
    String? bio,
    String? orgName,
    String? orgDescription,
    String? avatarPath,
    DateTime? joinedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      orgName: orgName ?? this.orgName,
      orgDescription: orgDescription ?? this.orgDescription,
      avatarPath: avatarPath ?? this.avatarPath,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String organizationId;
  final String organizationName;
  final String category;
  final String location;
  final DateTime date;
  final String duration;
  final int volunteersNeeded;
  final int volunteersApplied;
  final List<String> requiredSkills;
  final TaskStatus status;
  final DateTime postedAt;
  final String imageEmoji;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.organizationId,
    required this.organizationName,
    required this.category,
    required this.location,
    required this.date,
    required this.duration,
    required this.volunteersNeeded,
    required this.volunteersApplied,
    required this.requiredSkills,
    required this.status,
    required this.postedAt,
    required this.imageEmoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'category': category,
      'location': location,
      'date': date,
      'duration': duration,
      'volunteersNeeded': volunteersNeeded,
      'volunteersApplied': volunteersApplied,
      'requiredSkills': requiredSkills,
      'status': status.name,
      'postedAt': postedAt,
      'imageEmoji': imageEmoji,
    };
  }

  factory Task.fromMap({required String id, required Map<String, dynamic> data}) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      category: data['category'] ?? 'Other',
      location: data['location'] ?? '',
      date: _asDateTime(data['date']),
      duration: data['duration'] ?? '',
      volunteersNeeded: (data['volunteersNeeded'] ?? 0) as int,
      volunteersApplied: (data['volunteersApplied'] ?? 0) as int,
      requiredSkills: List<String>.from(data['requiredSkills'] ?? const []),
      status: _asTaskStatus(data['status'] as String?),
      postedAt: _asDateTime(data['postedAt']),
      imageEmoji: data['imageEmoji'] ?? '✨',
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? organizationId,
    String? organizationName,
    String? category,
    String? location,
    DateTime? date,
    String? duration,
    int? volunteersNeeded,
    int? volunteersApplied,
    List<String>? requiredSkills,
    TaskStatus? status,
    DateTime? postedAt,
    String? imageEmoji,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      volunteersNeeded: volunteersNeeded ?? this.volunteersNeeded,
      volunteersApplied: volunteersApplied ?? this.volunteersApplied,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      status: status ?? this.status,
      postedAt: postedAt ?? this.postedAt,
      imageEmoji: imageEmoji ?? this.imageEmoji,
    );
  }

  double get fillRate => volunteersNeeded == 0 ? 0 : volunteersApplied / volunteersNeeded;
  bool get isFull => volunteersApplied >= volunteersNeeded;
}

class TaskApplication {
  final String id;
  final String taskId;
  final String userId;
  final String message;
  final String availability;
  final DateTime appliedAt;
  final ApplicationStatus status;

  TaskApplication({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.message,
    required this.availability,
    required this.appliedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'userId': userId,
      'message': message,
      'availability': availability,
      'appliedAt': appliedAt,
      'status': status.name,
    };
  }

  factory TaskApplication.fromMap({required String id, required Map<String, dynamic> data}) {
    return TaskApplication(
      id: id,
      taskId: data['taskId'] ?? '',
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      availability: data['availability'] ?? '',
      appliedAt: _asDateTime(data['appliedAt']),
      status: _asApplicationStatus(data['status'] as String?),
    );
  }

  TaskApplication copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? message,
    String? availability,
    DateTime? appliedAt,
    ApplicationStatus? status,
  }) {
    return TaskApplication(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      availability: availability ?? this.availability,
      appliedAt: appliedAt ?? this.appliedAt,
      status: status ?? this.status,
    );
  }
}

