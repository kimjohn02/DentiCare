import 'package:flutter/material.dart';
import '../models/dental_data.dart';

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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _roleTabController;

  final _patientUserCtrl = TextEditingController(text: 'kim_lupogan');
  final _patientPassCtrl = TextEditingController(text: 'password123');

  final _staffUserCtrl = TextEditingController(text: 'receptionist_feiah');
  final _staffPassCtrl = TextEditingController(text: 'staff123');

  final _adminUserCtrl = TextEditingController(text: 'admin_kj');
  final _adminPassCtrl = TextEditingController(text: 'admin123');

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _roleTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _roleTabController.dispose();
    _patientUserCtrl.dispose();
    _patientPassCtrl.dispose();
    _staffUserCtrl.dispose();
    _staffPassCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    super.dispose();
  }

  void _handleLogin(String role) {
    String username = '';
    String password = '';

    if (role == 'Patient') {
      username = _patientUserCtrl.text.trim();
      password = _patientPassCtrl.text.trim();
    } else if (role == 'Clinic Staff') {
      username = _staffUserCtrl.text.trim();
      password = _staffPassCtrl.text.trim();
    } else {
      username = _adminUserCtrl.text.trim();
      password = _adminPassCtrl.text.trim();
    }

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Match with registered users or create session account
    final existingUser = widget.users.firstWhere(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
      orElse: () => UserAccount(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        fullName: role == 'Patient'
            ? 'Lupogan, Kim Macpao'
            : (role == 'Clinic Staff'
                ? 'Feiah O. Macalde (Staff)'
                : 'KJ M. Lupogan (Admin)'),
        email: '$username@denticare.clinic',
        role: role,
        status: 'Active',
        registeredDate: '11/04/2026',
      ),
    );

    if (existingUser.status == 'Suspended') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This account is suspended. Please contact clinic admin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onLoginSuccess(existingUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003B81), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo Badge (Figure 6)
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.favorite,
                          size: 40,
                          color: Color(0xFF003B81),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'DentiCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Dental Clinic Appointment & Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 22),

                    // Role Tabs Selector: Patient vs Staff vs Admin
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TabBar(
                        controller: _roleTabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: const Color(0xFF003B81),
                        unselectedLabelColor: Colors.white70,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(text: 'Patient'),
                          Tab(text: 'Staff'),
                          Tab(text: 'Admin'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab Views with Forms
                    SizedBox(
                      height: 340,
                      child: TabBarView(
                        controller: _roleTabController,
                        children: [
                          _buildPatientLoginForm(),
                          _buildStaffLoginForm(),
                          _buildAdminLoginForm(),
                        ],
                      ),
                    ),

                    // Back to Home Link
                    TextButton.icon(
                      onPressed: widget.onBackToHome,
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white70, size: 16),
                      label: const Text(
                        'Continue as Guest / Back to Home',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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

  // 1. PATIENT LOGIN FORM (Has Login + Register Account)
  Widget _buildPatientLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Patient Username', _patientUserCtrl, Icons.person_outline),
        const SizedBox(height: 14),
        _buildPasswordField('Password', _patientPassCtrl),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _handleLogin('Patient'),
            child: const Text('Log in as Patient',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),

        // REGISTER ACCOUNT (ONLY FOR PATIENTS - Figure 6 & 7)
        Center(
          child: TextButton(
            onPressed: widget.onNavigateToRegister,
            child: RichText(
              text: const TextSpan(
                text: 'New patient? ',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Register Account Here',
                    style: TextStyle(
                      color: Color(0xFF93C5FD),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. CLINIC STAFF LOGIN FORM (LOGIN ONLY - NO REGISTRATION)
  Widget _buildStaffLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notice banner stating staff accounts are managed by Admin
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_person_rounded,
                  color: Color(0xFF10B981), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Staff portal is restricted. Accounts are created and issued by Clinic Administration.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField('Staff Username', _staffUserCtrl, Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildPasswordField('Password', _staffPassCtrl),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _handleLogin('Clinic Staff'),
            child: const Text('Staff Sign In',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // 3. ADMINISTRATOR LOGIN FORM (LOGIN ONLY - NO REGISTRATION)
  Widget _buildAdminLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notice banner stating admin access is restricted
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.purpleAccent, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Administrator governance access only. Registration is disabled for security.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
            'Admin Username', _adminUserCtrl, Icons.security_rounded),
        const SizedBox(height: 12),
        _buildPasswordField('Password', _adminPassCtrl),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _handleLogin('Administrator'),
            child: const Text('Admin Sign In',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 18,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// PATIENT REGISTRATION SCREEN (Figures 7 & 10 from Research Paper)
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

  void _submitRegistration() {
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

    final newPatientAccount = UserAccount(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: _username.text.trim(),
      fullName:
          '${_lastName.text.trim()}, ${_firstName.text.trim()} ${_middleInitial.text.trim()}',
      email: _email.text.trim(),
      role: 'Patient',
      status: 'Active',
      registeredDate: '11/04/2026',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient registration successful! Welcome to DentiCare.'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    widget.onRegisterSuccess(newPatientAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2540),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: const [
                      Text(
                        'Patient Registration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create your patient record for DentiCare appointment booking',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 1: Account Information (Figure 7)
                const Text(
                  'Account Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Username', _username)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildInputField('Password', _password,
                            isPassword: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Email', _email)),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 2: Personal Information (Figure 7)
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildInputField('First Name', _firstName)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: _buildInputField('M.I.', _middleInitial),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Last Name', _lastName)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Birthday',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _birthday,
                            style: const TextStyle(fontSize: 13),
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'MM/DD/YYYY',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_month, size: 18),
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
                                  horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sex',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSex,
                                isExpanded: true,
                                items: ['Female', 'Male', 'Prefer not to say']
                                    .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s,
                                            style: const TextStyle(fontSize: 13))))
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
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildInputField('Contact Number', _contactNumber),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Back and Register Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: widget.onBackToLogin,
                      child: const Text('Back to Login'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: _submitRegistration,
                      child: const Text('Complete Registration',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter $label',
            hintStyle: const TextStyle(fontSize: 11),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
