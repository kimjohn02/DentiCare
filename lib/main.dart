import 'package:flutter/material.dart';
import 'models/dental_data.dart';
import 'screens/auth_screens.dart';
import 'screens/appointments_screen.dart';
import 'screens/booking_flow_screen.dart';
import 'screens/home_screen.dart';
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
  int _navIndex = 0; // 0: Home, 1: Book, 2: My Appointments, 3: Account

  // In-memory Appointments state (pre-populated with sample from Figure 11)
  final List<AppointmentRecord> _appointments = [
    const AppointmentRecord(
      id: 'apt_init_1',
      patientName: 'Lupogan, Kim Macpao',
      serviceName: 'Dental Bracing',
      dentistName: 'Dr. Michaela Jordan',
      date: '09/11/2026',
      time: '8:00 AM',
      contact: '0987654321',
      email: 'kim@gmail.com',
      status: 'Confirmed',
    ),
    const AppointmentRecord(
      id: 'apt_init_2',
      patientName: 'Lupogan, Kim Macpao',
      serviceName: 'Teeth Cleaning',
      dentistName: 'Dr. Nathaniel Cruz',
      date: '08/15/2026',
      time: '10:30 AM',
      contact: '0987654321',
      email: 'kim@gmail.com',
      status: 'Completed',
    ),
  ];

  void _addAppointment(AppointmentRecord record) {
    setState(() {
      _appointments.insert(0, record);
      _navIndex = 2; // Jump to "My Appointments" tab to view it!
    });
  }

  void _cancelAppointment(String aptId) {
    setState(() {
      final idx = _appointments.indexWhere((a) => a.id == aptId);
      if (idx != -1) {
        final existing = _appointments[idx];
        _appointments[idx] = AppointmentRecord(
          id: existing.id,
          patientName: existing.patientName,
          serviceName: existing.serviceName,
          dentistName: existing.dentistName,
          date: existing.date,
          time: existing.time,
          contact: existing.contact,
          email: existing.email,
          status: 'Cancelled',
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment has been cancelled.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
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
      ),
      AppointmentsListScreen(
        appointments: _appointments,
        onNavigateToBook: () => setState(() => _navIndex = 1),
        onCancelAppointment: _cancelAppointment,
      ),
      LoginScreen(
        onLoginSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back, Kim Macpao Lupogan!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          setState(() => _navIndex = 0);
        },
        onNavigateToRegister: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => RegistrationScreen(
                onRegisterSuccess: () {
                  Navigator.of(ctx).pop();
                },
                onBackToLogin: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          );
        },
        onBackToHome: () => setState(() => _navIndex = 0),
      ),
    ];

    return Scaffold(
      body: screens[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _navIndex = idx;
          });
        },
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
            selectedIcon: Icon(Icons.person, color: Color(0xFF003B81)),
            label: 'Account',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
