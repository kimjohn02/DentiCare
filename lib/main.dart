import 'package:flutter/material.dart';
import 'models/dental_data.dart';
import 'screens/admin_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/appointments_screen.dart';
import 'screens/booking_flow_screen.dart';
import 'screens/clinic_staff_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/dentibot_dialog.dart';
import 'widgets/settings_dialog.dart';

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

  // Appointment Actions
  void _addAppointment(AppointmentRecord record) {
    setState(() {
      _appointments.insert(0, record);
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
        _appointments[idx] = _appointments[idx].copyWith(
          status: newStatus,
          notes: notes,
        );
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
      // Patient Account Tab with Logout option
      Scaffold(
        appBar: AppBar(
          title: const Text('Patient Account & Session',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF003B81),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                _currentUser!.fullName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Role: ${_currentUser!.role} • @${_currentUser!.username}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email Address'),
                      subtitle: Text(_currentUser!.email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: const Text('Account Status'),
                      subtitle: Text(_currentUser!.status),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Registration Date'),
                      subtitle: Text(_currentUser!.registeredDate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out of DentiCare'),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: Container(
          color: const Color(0xFF003B81),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Role Indicator & Demo Switcher
              Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Mode: ',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activeRole,
                        dropdownColor: const Color(0xFF003B81),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white, size: 18),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        items: ['Patient', 'Clinic Staff', 'Administrator']
                            .map((role) {
                          String label = '👤 Patient View';
                          if (role == 'Clinic Staff') label = '🏥 Clinic Staff';
                          if (role == 'Administrator') label = '⚙️ Administrator';

                          return DropdownMenuItem(
                            value: role,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (newRole) {
                          if (newRole != null) {
                            setState(() {
                              _activeRole = newRole;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Action Buttons: Settings & Logout
              Row(
                children: [
                  TextButton.icon(
                    icon:
                        const Icon(Icons.tune, color: Colors.white70, size: 14),
                    label: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => SettingsDialog(
                          isLargeFont: widget.isLargeFont,
                          isDarkMode: widget.isDarkMode,
                          onToggleLargeFont: widget.onToggleLargeFont,
                          onToggleDarkMode: widget.onToggleDarkMode,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Log Out',
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 18),
                    onPressed: _logout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            )
          : (isStaff
              ? ClinicStaffScreen(
                  appointments: _appointments,
                  onAddAppointment: _addAppointment,
                  onUpdateAppointmentStatus: _updateAppointmentStatus,
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
