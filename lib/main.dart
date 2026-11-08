import 'package:flutter/material.dart';
import 'models/dental_data.dart';
import 'screens/admin_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/appointments_screen.dart';
import 'screens/booking_flow_screen.dart';
import 'screens/clinic_staff_screen.dart';
import 'screens/home_screen.dart';
import 'screens/patient_account_view.dart';
import 'widgets/dentibot_dialog.dart';

void main() {
  runApp(const DentiCareApp());
}

class DentiCareApp extends StatefulWidget {
  const DentiCareApp({super.key});

  @override
  State<DentiCareApp> createState() => _DentiCareAppState();
}

class _DentiCareAppState extends State<DentiCareApp> {
  bool _isDarkMode = false;
  bool _isLargeFont = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _toggleLargeFont(bool value) {
    setState(() {
      _isLargeFont = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF003B81);
    const accentCyan = Color(0xFF00A8CC);

    return MaterialApp(
      title: 'DentiCare',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentCyan,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F9FD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: primaryBlue,
          elevation: 0.5,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: const Color(0xFF3B82F6),
          secondary: accentCyan,
          surface: const Color(0xFF1E293B),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF1E293B),
        ),
      ),
      builder: (context, child) {
        // Accessibility: Large font multiplier for elderly & student persona (Figure 14)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_isLargeFont ? 1.22 : 1.0),
          ),
          child: child!,
        );
      },
      home: DentiCareRootShell(
        isDarkMode: _isDarkMode,
        isLargeFont: _isLargeFont,
        onToggleDarkMode: _toggleDarkMode,
        onToggleLargeFont: _toggleLargeFont,
      ),
    );
  }
}

class DentiCareRootShell extends StatefulWidget {
  final bool isDarkMode;
  final bool isLargeFont;
  final ValueChanged<bool> onToggleDarkMode;
  final ValueChanged<bool> onToggleLargeFont;

  const DentiCareRootShell({
    super.key,
    required this.isDarkMode,
    required this.isLargeFont,
    required this.onToggleDarkMode,
    required this.onToggleLargeFont,
  });

  @override
  State<DentiCareRootShell> createState() => _DentiCareRootShellState();
}

class _DentiCareRootShellState extends State<DentiCareRootShell> {
  // Current logged in user (starts with Patient Kim Macpao Lupogan)
  UserAccount? _currentUser = DentalClinicData.sampleUsers[0];
  String _activeRole = 'Patient'; // 'Patient', 'Clinic Staff', 'Administrator'
  int _navIndex = 0; // 0: Home, 1: Book, 2: My Appointments, 3: Account

  // In-memory Shared State
  final List<UserAccount> _users = List.from(DentalClinicData.sampleUsers);
  final List<DentalService> _services = List.from(DentalClinicData.services);
  final List<Dentist> _dentists = List.from(DentalClinicData.dentists);

  final List<AppointmentRecord> _appointments = [
    const AppointmentRecord(
      id: 'apt_init_pending',
      patientName: 'Lupogan, Kim Macpao',
      serviceName: 'Dental Bracing',
      dentistName: 'Dr. Michaela Jordan',
      date: '09/11/2026',
      time: '8:00 AM',
      contact: '0987654321',
      email: 'kim@gmail.com',
      status: 'Pending',
      notes: 'New booking via Patient Web Portal',
    ),
    const AppointmentRecord(
      id: 'apt_init_confirmed',
      patientName: 'Reloba, Joen Paul',
      serviceName: 'Teeth Whitening',
      dentistName: 'Dr. Nathaniel Cruz',
      date: '09/11/2026',
      time: '1:00 PM',
      contact: '0912345678',
      email: 'joen@gmail.com',
      status: 'Confirmed',
      notes: 'Confirmed by phone callback',
    ),
    const AppointmentRecord(
      id: 'apt_init_completed',
      patientName: 'Santos, Maria Elena',
      serviceName: 'Teeth Cleaning',
      dentistName: 'Dr. Michaela Jordan',
      date: '08/20/2026',
      time: '10:00 AM',
      contact: '0922888999',
      email: 'maria.santos@gmail.com',
      status: 'Completed',
      notes: 'Routine plaque removal performed',
    ),
  ];

  // Patient Notifications State
  List<PatientNotification> _notifications =
      List.from(DentalClinicData.sampleNotifications);

  void _markNotificationAsRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      }
    });
  }

  void _markAllNotificationsAsRead() {
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  // Appointment Actions
  void _addAppointment(AppointmentRecord record) {
    setState(() {
      _appointments.insert(0, record);
      _notifications.insert(
        0,
        PatientNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Booking Submitted',
          message:
              'Your request for ${record.serviceName} on ${record.date} at ${record.time} has been submitted for clinic confirmation.',
          timeAgo: 'Just now',
          icon: Icons.bookmark_added_rounded,
          color: const Color(0xFF2563EB),
          isRead: false,
          routeAction: 'bookings',
        ),
      );
      if (_activeRole == 'Patient') {
        _navIndex = 2; // Jump to "My Bookings"
      }
    });
  }

  void _updateAppointmentStatus(String aptId, String newStatus,
      {String? notes}) {
    setState(() {
      final idx = _appointments.indexWhere((a) => a.id == aptId);
      if (idx != -1) {
        final apt = _appointments[idx];
        _appointments[idx] = apt.copyWith(
          status: newStatus,
          notes: notes,
        );

        if (newStatus == 'Confirmed') {
          _notifications.insert(
            0,
            PatientNotification(
              id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Appointment Approved',
              message:
                  'Your visit for ${apt.serviceName} on ${apt.date} at ${apt.time} has been confirmed by the clinic staff.',
              timeAgo: 'Just now',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              isRead: false,
              routeAction: 'bookings',
            ),
          );
        }
      }
    });
  }

  void _cancelAppointment(String aptId) {
    _updateAppointmentStatus(aptId, 'Cancelled',
        notes: 'Cancelled by patient');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment has been cancelled.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Admin Actions
  void _addUser(UserAccount user) {
    setState(() {
      _users.insert(0, user);
    });
  }

  void _updateUser(UserAccount updated) {
    setState(() {
      _currentUser = updated;
      final idx = _users.indexWhere((u) => u.id == updated.id);
      if (idx != -1) {
        _users[idx] = updated;
      }
    });
  }

  void _toggleUserStatus(String userId, String newStatus) {
    setState(() {
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(status: newStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User account status set to: $newStatus'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _addService(DentalService service) {
    setState(() {
      _services.add(service);
    });
  }

  void _updateService(DentalService service) {
    setState(() {
      final idx = _services.indexWhere((s) => s.id == service.id);
      if (idx != -1) {
        _services[idx] = service;
      }
    });
  }

  void _addDentist(Dentist dentist) {
    setState(() {
      _dentists.add(dentist);
    });
  }

  void _logout() {
    setState(() {
      _currentUser = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have been logged out.'),
        backgroundColor: Color(0xFF003B81),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If not logged in, display the Unified Portal Login Gateway
    if (_currentUser == null) {
      return LoginScreen(
        users: _users,
        onLoginSuccess: (user) {
          setState(() {
            _currentUser = user;
            _activeRole = user.role;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${user.fullName} (${user.role})!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
        onNavigateToRegister: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => RegistrationScreen(
                onRegisterSuccess: (newPatient) {
                  _addUser(newPatient);
                  setState(() {
                    _currentUser = newPatient;
                    _activeRole = 'Patient';
                  });
                  Navigator.of(ctx).pop();
                },
                onBackToLogin: () => Navigator.of(ctx).pop(),
              ),
            ),
          );
        },
        onBackToHome: () {
          setState(() {
            _currentUser = DentalClinicData.sampleUsers[0];
            _activeRole = 'Patient';
            _navIndex = 0;
          });
        },
      );
    }

    final isPatient = _activeRole == 'Patient';
    final isStaff = _activeRole == 'Clinic Staff';
    final isAdmin = _activeRole == 'Administrator';

    final patientScreens = [
      DentiCareMainHomeScreen(
        isDarkMode: widget.isDarkMode,
        isLargeFont: widget.isLargeFont,
        onToggleDarkMode: widget.onToggleDarkMode,
        onToggleLargeFont: widget.onToggleLargeFont,
        onNavigateToBooking: () => setState(() => _navIndex = 1),
        onNavigateToAppointments: () => setState(() => _navIndex = 2),
        onNavigateToAuth: () => setState(() => _navIndex = 3),
        notifications: _notifications,
        onMarkAsRead: _markNotificationAsRead,
        onMarkAllAsRead: _markAllNotificationsAsRead,
      ),
      BookingFlowScreen(
        isDarkMode: widget.isDarkMode,
        isLargeFont: widget.isLargeFont,
        onToggleDarkMode: widget.onToggleDarkMode,
        onToggleLargeFont: widget.onToggleLargeFont,
        onAppointmentBooked: _addAppointment,
        services: _services,
        dentists: _dentists,
      ),
      AppointmentsListScreen(
        appointments: _appointments,
        onNavigateToBook: () => setState(() => _navIndex = 1),
        onCancelAppointment: _cancelAppointment,
      ),
      PatientAccountView(
        user: _currentUser!,
        isDarkMode: widget.isDarkMode,
        isLargeFont: widget.isLargeFont,
        onToggleDarkMode: widget.onToggleDarkMode,
        onToggleLargeFont: widget.onToggleLargeFont,
        onLogout: _logout,
        onUpdateUser: _updateUser,
      ),
    ];

    return Scaffold(
      body: isAdmin
          ? AdminScreen(
              users: _users,
              services: _services,
              dentists: _dentists,
              appointments: _appointments,
              onAddUser: _addUser,
              onToggleUserStatus: _toggleUserStatus,
              onAddService: _addService,
              onUpdateService: _updateService,
              onAddDentist: _addDentist,
              onLogout: _logout,
            )
          : (isStaff
              ? ClinicStaffScreen(
                  appointments: _appointments,
                  onAddAppointment: _addAppointment,
                  onUpdateAppointmentStatus: _updateAppointmentStatus,
                  onLogout: _logout,
                )
              : patientScreens[_navIndex]),
      bottomNavigationBar: isPatient
          ? NavigationBar(
              selectedIndex: _navIndex,
              onDestinationSelected: (idx) => setState(() => _navIndex = idx),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: Color(0xFF003B81)),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon:
                      Icon(Icons.add_circle_rounded, color: Color(0xFF003B81)),
                  label: 'Book Now',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon:
                      Icon(Icons.calendar_month, color: Color(0xFF003B81)),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon:
                      Icon(Icons.person, color: Color(0xFF003B81)),
                  label: 'Account',
                ),
              ],
            )
          : null,
      floatingActionButton: isPatient
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              tooltip: 'DentiBot Chatbot',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const DentiBotDialog(),
                );
              },
              child: const Icon(Icons.smart_toy_rounded),
            )
          : null,
    );
  }
}
