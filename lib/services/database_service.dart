import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _seedData();
  }

  final List<AppUser> _users = [];
  final List<Task> _tasks = [];
  final List<TaskApplication> _applications = [];
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final user = _users.firstWhere((u) => u.email == email && u.password == password);
      _currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
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
    await Future.delayed(const Duration(milliseconds: 600));
    if (_users.any((u) => u.email == email)) return null;
    final user = AppUser(
      id: 'user_${_users.length + 1}',
      name: name,
      email: email,
      password: password,
      role: role,
      skills: skills,
      orgName: orgName,
      orgDescription: orgDescription,
      joinedAt: DateTime.now(),
    );
    _users.add(user);
    _currentUser = user;
    return user;
  }

  void logout() => _currentUser = null;

  Future<bool> updateUser(AppUser updated) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _users.indexWhere((u) => u.id == updated.id);
    if (idx == -1) return false;
    _users[idx] = updated;
    _currentUser = updated;
    return true;
  }

  List<Task> getTasks({String? search, String? category, bool onlyOpen = false}) {
    return _tasks.where((t) {
      if (onlyOpen && t.status != TaskStatus.open) return false;
      if (category != null && category != 'All' && t.category != category) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        if (!t.title.toLowerCase().contains(q) && !t.description.toLowerCase().contains(q) && !t.location.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  List<Task> getTasksByOrg(String orgId) => _tasks.where((t) => t.organizationId == orgId).toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt));

  Task? getTask(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Task> createTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final t = task.copyWith(id: 'task_${_tasks.length + 1}', postedAt: DateTime.now());
    _tasks.insert(0, t);
    return t;
  }

  Future<bool> updateTask(Task updated) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return false;
    _tasks[idx] = updated;
    return true;
  }

  Future<bool> deleteTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _tasks.removeWhere((t) => t.id == taskId);
    _applications.removeWhere((a) => a.taskId == taskId);
    return true;
  }

  List<TaskApplication> getApplicationsForTask(String taskId) => _applications.where((a) => a.taskId == taskId).toList();

  List<TaskApplication> getApplicationsByUser(String userId) => _applications.where((a) => a.userId == userId).toList();

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
    await Future.delayed(const Duration(milliseconds: 500));
    if (getApplicationByUserAndTask(userId, taskId) != null) return null;
    final app = TaskApplication(
      id: 'app_${_applications.length + 1}',
      taskId: taskId,
      userId: userId,
      message: message,
      availability: availability,
      appliedAt: DateTime.now(),
      status: ApplicationStatus.pending,
    );
    _applications.add(app);
    return app;
  }

  Future<bool> updateApplicationStatus(String appId, ApplicationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _applications.indexWhere((a) => a.id == appId);
    if (idx == -1) return false;
    _applications[idx] = _applications[idx].copyWith(status: status);
    return true;
  }

  AppUser? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  void _seedData() {
    final ngo1 = AppUser(
      id: 'org_1',
      name: 'Ayşe Kaya',
      email: 'temiz@deniz.org',
      password: 'Text!123',
      role: UserRole.organization,
      orgName: 'Temiz Deniz Derneği',
      orgDescription: 'We organize coastal and marine clean-up events across Turkey to protect our seas.',
      joinedAt: DateTime.now().subtract(const Duration(days: 400)),
    );
    final ngo2 = AppUser(
      id: 'org_2',
      name: 'Mehmet Demir',
      email: 'patiler@kurtarma.org',
      password: 'Text!123',
      role: UserRole.organization,
      orgName: 'Patiler Kurtarma Derneği',
      orgDescription: 'Animal rescue and shelter support organization active in Istanbul and Ankara.',
      joinedAt: DateTime.now().subtract(const Duration(days: 300)),
    );
    final ngo3 = AppUser(
      id: 'org_3',
      name: 'Fatma Şahin',
      email: 'cocuk@egitim.org',
      password: 'Text!123',
      role: UserRole.organization,
      orgName: 'Çocuk Eğitim Vakfı',
      orgDescription: 'Providing free education and tutoring for underprivileged children.',
      joinedAt: DateTime.now().subtract(const Duration(days: 200)),
    );

    final vol1 = AppUser(
      id: 'vol_1',
      name: 'Emre Yıldız',
      email: 'emre@test.com',
      password: 'Text!123',
      role: UserRole.volunteer,
      skills: ['Photography', 'Social Media', 'Physical Work'],
      bio: 'Passionate about environmental causes and outdoor activities.',
      joinedAt: DateTime.now().subtract(const Duration(days: 150)),
    );
    final vol2 = AppUser(
      id: 'vol_2',
      name: 'Zeynep Arslan',
      email: 'zeynep@test.com',
      password: 'Text!123',
      role: UserRole.volunteer,
      skills: ['Teaching', 'Childcare', 'Event Planning'],
      bio: 'Teacher by profession, volunteer by heart.',
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
    );

    _users.addAll([ngo1, ngo2, ngo3, vol1, vol2]);

    // Tasks
    _tasks.addAll([
      Task(
        id: 'task_1',
        title: 'Sarıyer Beach Clean-Up',
        description:
            'Join us for a morning beach clean-up at Sarıyer coast. We will collect plastic waste and debris along 2km of shoreline. Gloves and bags provided. Great opportunity to meet like-minded people and make a real difference!',
        organizationId: 'org_1',
        organizationName: 'Temiz Deniz Derneği',
        category: 'Environment',
        location: 'Sarıyer, Istanbul',
        date: DateTime.now().add(const Duration(days: 7)),
        duration: '4 hours',
        volunteersNeeded: 20,
        volunteersApplied: 8,
        requiredSkills: ['Physical Work'],
        status: TaskStatus.open,
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
        imageEmoji: '🌊',
      ),
      Task(
        id: 'task_2',
        title: 'Animal Shelter Assistance',
        description:
            'Help us care for rescued dogs and cats at our Istanbul shelter. Activities include feeding, grooming, socializing animals, and assisting with adoption events. Animal lovers welcome — no experience needed, just a big heart!',
        organizationId: 'org_2',
        organizationName: 'Patiler Kurtarma Derneği',
        category: 'Animals',
        location: 'Kadıköy, Istanbul',
        date: DateTime.now().add(const Duration(days: 3)),
        duration: '3 hours',
        volunteersNeeded: 10,
        volunteersApplied: 6,
        requiredSkills: ['Childcare'],
        status: TaskStatus.open,
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
        imageEmoji: '🐾',
      ),
      Task(
        id: 'task_3',
        title: 'Free Math Tutoring — Middle School',
        description:
            'We need volunteer tutors to provide free math lessons to middle school students from low-income families. Sessions are held every Saturday morning for 2 hours. Experience in teaching or education preferred.',
        organizationId: 'org_3',
        organizationName: 'Çocuk Eğitim Vakfı',
        category: 'Education',
        location: 'Beyoğlu, Istanbul',
        date: DateTime.now().add(const Duration(days: 5)),
        duration: '2 hours/week',
        volunteersNeeded: 8,
        volunteersApplied: 3,
        requiredSkills: ['Teaching'],
        status: TaskStatus.open,
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
        imageEmoji: '📚',
      ),
      Task(
        id: 'task_4',
        title: 'Food Bank Distribution',
        description:
            'Assist with sorting and distributing food packages at our weekly food bank. We serve over 200 families each week and need helping hands for packing, organizing, and distribution logistics.',
        organizationId: 'org_1',
        organizationName: 'Temiz Deniz Derneği',
        category: 'Social',
        location: 'Fatih, Istanbul',
        date: DateTime.now().add(const Duration(days: 10)),
        duration: '5 hours',
        volunteersNeeded: 15,
        volunteersApplied: 4,
        requiredSkills: ['Physical Work', 'Event Planning'],
        status: TaskStatus.open,
        postedAt: DateTime.now().subtract(const Duration(days: 4)),
        imageEmoji: '🍱',
      ),
      Task(
        id: 'task_5',
        title: 'Photography for NGO Event',
        description:
            'We are looking for a volunteer photographer to document our annual gala dinner. This is a great opportunity to build your portfolio while supporting a great cause. Professional equipment preferred.',
        organizationId: 'org_3',
        organizationName: 'Çocuk Eğitim Vakfı',
        category: 'Arts & Media',
        location: 'Şişli, Istanbul',
        date: DateTime.now().add(const Duration(days: 14)),
        duration: '6 hours',
        volunteersNeeded: 2,
        volunteersApplied: 1,
        requiredSkills: ['Photography', 'Social Media'],
        status: TaskStatus.open,
        postedAt: DateTime.now().subtract(const Duration(days: 5)),
        imageEmoji: '📸',
      ),
      Task(
        id: 'task_6',
        title: 'Park Reforestation Day',
        description:
            'Help us plant 500 trees at Polonezköy Nature Park. Shovels and saplings provided. Wear comfortable clothes and bring water. Lunch will be served. A great family-friendly activity!',
        organizationId: 'org_1',
        organizationName: 'Temiz Deniz Derneği',
        category: 'Environment',
        location: 'Beykoz, Istanbul',
        date: DateTime.now().add(const Duration(days: 21)),
        duration: '6 hours',
        volunteersNeeded: 50,
        volunteersApplied: 22,
        requiredSkills: ['Physical Work'],
        status: TaskStatus.open,
        postedAt: DateTime.now().subtract(const Duration(days: 6)),
        imageEmoji: '🌳',
      ),
      Task(
        id: 'task_7',
        title: 'Stray Cat Vaccination Drive',
        description:
            'Assist veterinarians during a free vaccination and neutering campaign for stray cats in Üsküdar. Tasks include handling cats, record keeping, and community outreach.',
        organizationId: 'org_2',
        organizationName: 'Patiler Kurtarma Derneği',
        category: 'Animals',
        location: 'Üsküdar, Istanbul',
        date: DateTime.now().subtract(const Duration(days: 5)),
        duration: '8 hours',
        volunteersNeeded: 12,
        volunteersApplied: 12,
        requiredSkills: [],
        status: TaskStatus.completed,
        postedAt: DateTime.now().subtract(const Duration(days: 20)),
        imageEmoji: '🐱',
      ),
    ]);

    _applications.add(
      TaskApplication(
        id: 'app_seed_1',
        taskId: 'task_1',
        userId: 'vol_1',
        message: 'I am very passionate about keeping our seas clean. I can help!',
        availability: 'Weekends and mornings',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: ApplicationStatus.pending,
      ),
    );
  }
}
