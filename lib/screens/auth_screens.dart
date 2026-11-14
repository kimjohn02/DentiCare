import 'package:flutter/material.dart';
import '../models/dental_data.dart';
import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  final List<UserAccount> users;
  final Function(UserAccount user) onLoginSuccess;
  final VoidCallback onNavigateToRegister;
  final VoidCallback onBackToHome;

  const LoginScreen({
    super.key,
    required this.users,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
    required this.onBackToHome,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController(text: 'kim_lupogan');
  final _passwordCtrl = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 1. Fast-path check for built-in administrative / staff demo accounts
    final matchingLocalUsers = widget.users.where(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );

    if (matchingLocalUsers.isNotEmpty &&
        (username.toLowerCase() == 'admin' ||
            username.toLowerCase() == 'staff' ||
            username.toLowerCase() == 'dr_grace')) {
      final user = matchingLocalUsers.first;
      if (user.status == 'Suspended') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('This account is suspended. Please contact clinic admin.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      widget.onLoginSuccess(user);
      return;
    }

    // 2. Authenticate with real Firebase
    setState(() => _isLoading = true);
    try {
      final firebaseUser = await DentiFirebaseService.loginUser(
        usernameOrEmail: username,
        password: password,
      );

      if (firebaseUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${firebaseUser.fullName}!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        widget.onLoginSuccess(firebaseUser);
        return;
      }
    } catch (e) {
      debugPrint('Firebase login exception: $e');
      // If user is offline or not found in Firebase, check local mock accounts
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    // 3. Fallback matching with local user list for offline demo
    if (matchingLocalUsers.isNotEmpty) {
      final user = matchingLocalUsers.first;
      if (user.status == 'Suspended') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('This account is suspended. Please contact clinic admin.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      widget.onLoginSuccess(user);
      return;
    }

    // 4. Fallback role detection based on username keywords
    String inferredRole = 'Patient';
    final lower = username.toLowerCase();
    if (lower.contains('admin')) {
      inferredRole = 'Administrator';
    } else if (lower.contains('staff') ||
        lower.contains('desk') ||
        lower.contains('nurse') ||
        lower.contains('receptionist')) {
      inferredRole = 'Clinic Staff';
    }

    final fallbackUser = UserAccount(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      fullName: inferredRole == 'Patient'
          ? username
          : (inferredRole == 'Clinic Staff'
              ? 'Clinic Staff Member'
              : 'System Administrator'),
      email: '$username@denticare.clinic',
      contactNumber: '0987-654-3210',
      role: inferredRole,
      status: 'Active',
      registeredDate: '11/04/2026',
    );

    widget.onLoginSuccess(fallbackUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // White Floating Card matching template
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clinic Logo (Enlarged for bold brand presence)
                        SizedBox(
                          width: 180,
                          height: 150,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.health_and_safety_rounded,
                              size: 72,
                              color: Color(0xFF003B81),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Username Field
                        _buildTextField(
                          label: 'Username',
                          controller: _usernameCtrl,
                          icon: Icons.person_outline,
                          hintText: 'Enter your username',
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        _buildPasswordField(
                          label: 'Password',
                          controller: _passwordCtrl,
                        ),
                        const SizedBox(height: 22),

                        // Sign In Button matching template style
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003B81),
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.login_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Prominent Register Link for Patients
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                              InkWell(
                                onTap: widget.onNavigateToRegister,
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Text(
                                    'Register Here',
                                    style: TextStyle(
                                      color: Color(0xFF003B81),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF003B81),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back to Guest / Home Link
                  TextButton.icon(
                    onPressed: widget.onBackToHome,
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF64748B), size: 16),
                    label: const Text(
                      'Continue as Guest / Back to Home',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Text Input styled identically to user's sample template
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F4FA),
            hintText: hintText ?? 'Enter $label',
            hintStyle:
                const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            prefixIcon:
                Icon(icon, size: 18, color: const Color(0xFF64748B)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF003B81), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Password Input with eye toggle styled identically to user's sample template
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: _obscurePassword,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F4FA),
            hintText: hintText ?? 'Enter password',
            hintStyle:
                const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            prefixIcon:
                const Icon(Icons.lock_outline, size: 18, color: Color(0xFF64748B)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: const Color(0xFF64748B),
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF003B81), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// PATIENT REGISTRATION SCREEN (Figures 7 & 10 from Research Paper)
// Styled to match the clean white card template
// -----------------------------------------------------------------
class RegistrationScreen extends StatefulWidget {
  final Function(UserAccount user) onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegistrationScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onBackToLogin,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _middleInitial = TextEditingController();
  final _lastName = TextEditingController();
  final _birthday = TextEditingController();
  final _contactNumber = TextEditingController();
  String _selectedSex = 'Female';
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _email.dispose();
    _firstName.dispose();
    _middleInitial.dispose();
    _lastName.dispose();
    _birthday.dispose();
    _contactNumber.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (_username.text.isEmpty ||
        _password.text.isEmpty ||
        _email.text.isEmpty ||
        _firstName.text.isEmpty ||
        _lastName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_email.text.contains('@') || !_email.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fullName = _middleInitial.text.trim().isNotEmpty
        ? '${_lastName.text.trim()}, ${_firstName.text.trim()} ${_middleInitial.text.trim()}'
        : '${_lastName.text.trim()}, ${_firstName.text.trim()}';

    try {
      final userAccount = await DentiFirebaseService.registerPatient(
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        fullName: fullName,
        contactNumber: _contactNumber.text.trim().isNotEmpty
            ? _contactNumber.text.trim()
            : '0987-654-3210',
        birthday: _birthday.text.trim(),
        sex: _selectedSex,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient registration successful! Welcome to DentiCare.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      if (userAccount != null) {
        widget.onRegisterSuccess(userAccount);
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.contains('email-already-in-use')) {
        errorMsg = 'This email is already registered. Please login instead.';
      } else if (errorMsg.contains('weak-password')) {
        errorMsg = 'Password is too weak. Please use at least 6 characters.';
      } else if (errorMsg.contains('invalid-email')) {
        errorMsg = 'The email address format is invalid.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Error: $errorMsg'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003B81)
                                  .withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.app_registration_rounded,
                              size: 32,
                              color: Color(0xFF003B81),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Patient Registration',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Create your patient record for DentiCare appointment booking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Account Information (Figure 7)
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined,
                            size: 18, color: Color(0xFF003B81)),
                        SizedBox(width: 6),
                        Text(
                          'Account Information',
                          style: TextStyle(
                            color: Color(0xFF003B81),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    const SizedBox(height: 4),
                    _buildInputField(
                      'Username',
                      _username,
                      hintText: 'Enter desired username',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      'Email Address',
                      _email,
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      'Password',
                      _password,
                      hintText: 'Enter secure password',
                      isPassword: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Personal Information (Figure 7)
                    Row(
                      children: const [
                        Icon(Icons.person_outline_rounded,
                            size: 18, color: Color(0xFF003B81)),
                        SizedBox(width: 6),
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            color: Color(0xFF003B81),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    const SizedBox(height: 4),
                    // First Name & M.I.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            'First Name',
                            _firstName,
                            hintText: 'First name',
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 72,
                          child: _buildInputField(
                            'M.I.',
                            _middleInitial,
                            hintText: 'M.I.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      'Last Name',
                      _lastName,
                      hintText: 'Enter last name',
                    ),
                    const SizedBox(height: 12),
                    // Birthday & Sex in clean 2-column row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Birthday',
                                style: TextStyle(
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _birthday,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0F172A)),
                                readOnly: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF0F4FA),
                                  hintText: 'MM/DD/YYYY',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 12),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_month,
                                        size: 18, color: Color(0xFF64748B)),
                                    onPressed: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2005, 5, 15),
                                        firstDate: DateTime(1940),
                                        lastDate: DateTime.now(),
                                      );
                                      if (d != null) {
                                        _birthday.text =
                                            '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
                                      }
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 11),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF003B81), width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sex',
                                style: TextStyle(
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedSex,
                                    isExpanded: true,
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF64748B),
                                        size: 20),
                                    items: [
                                      'Female',
                                      'Male',
                                    ]
                                        .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF0F172A)))))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _selectedSex = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      'Contact Number',
                      _contactNumber,
                      hintText: '0987-654-3210',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003B81),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitRegistration,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle_outline, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Complete Registration',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        onPressed: widget.onBackToLogin,
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    String? hintText,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F4FA),
            hintText: hintText ?? 'Enter $label',
            hintStyle:
                const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: const Color(0xFF64748B))
                : null,
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF003B81), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
