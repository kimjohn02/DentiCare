import 'package:flutter/material.dart';
import '../models/dental_data.dart';

class AdminScreen extends StatefulWidget {
  final List<UserAccount> users;
  final List<DentalService> services;
  final List<Dentist> dentists;
  final List<AppointmentRecord> appointments;
  final Function(UserAccount) onAddUser;
  final Function(UserAccount)? onUpdateUser;
  final Function(String userId)? onDeleteUser;
  final Function(String userId, String newStatus) onToggleUserStatus;
  final Function(DentalService) onAddService;
  final Function(DentalService) onUpdateService;
  final Function(String serviceId)? onDeleteService;
  final Function(Dentist) onAddDentist;
  final Function(Dentist)? onUpdateDentist;
  final Function(String dentistId)? onDeleteDentist;
  final bool? isLargeFont;
  final ValueChanged<bool>? onToggleLargeFont;
  final VoidCallback? onLogout;

  const AdminScreen({
    super.key,
    required this.users,
    required this.services,
    required this.dentists,
    required this.appointments,
    required this.onAddUser,
    this.onUpdateUser,
    this.onDeleteUser,
    required this.onToggleUserStatus,
    required this.onAddService,
    required this.onUpdateService,
    this.onDeleteService,
    required this.onAddDentist,
    this.onUpdateDentist,
    this.onDeleteDentist,
    this.isLargeFont,
    this.onToggleLargeFont,
    this.onLogout,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  // User Management State
  String _selectedRoleFilter = 'All';
  String _userSearchQuery = '';
  final TextEditingController _userSearchCtrl = TextEditingController();

  // Services Management State
  String _selectedServiceCategory = 'All';
  String _serviceSearchQuery = '';
  final TextEditingController _serviceSearchCtrl = TextEditingController();

  // Dentist Management State
  String _dentistSearchQuery = '';
  final TextEditingController _dentistSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _currentIndex != _tabController.index) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchCtrl.dispose();
    _serviceSearchCtrl.dispose();
    _dentistSearchCtrl.dispose();
    super.dispose();
  }

  // Add User / Staff Dialog
  void _showAddUserDialog() {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '0917-');
    final emailCtrl = TextEditingController();
    String roleVal = 'Patient';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_rounded,
                      color: Color(0xFF003B81), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Create New Account',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text(
                        'Register a new patient, clinic staff, or administrator',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // Assigned Role Dropdown
                    DropdownButtonFormField<String>(
                      value: roleVal,
                      decoration: InputDecoration(
                        labelText: 'Assigned Role',
                        prefixIcon: Icon(
                          roleVal == 'Administrator'
                              ? Icons.admin_panel_settings_rounded
                              : (roleVal == 'Clinic Staff'
                                  ? Icons.badge_rounded
                                  : Icons.person_rounded),
                          color: roleVal == 'Administrator'
                              ? const Color(0xFF7C3AED)
                              : (roleVal == 'Clinic Staff'
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF003B81)),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Patient',
                          child: Row(
                            children: const [
                              Icon(Icons.person_outline,
                                  size: 16, color: Color(0xFF003B81)),
                              SizedBox(width: 8),
                              Text('Patient (Walk-in or App User)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Clinic Staff',
                          child: Row(
                            children: const [
                              Icon(Icons.badge_outlined,
                                  size: 16, color: Color(0xFF059669)),
                              SizedBox(width: 8),
                              Text('Clinic Staff (Front Desk / Reception)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Administrator',
                          child: Row(
                            children: const [
                              Icon(Icons.shield_outlined,
                                  size: 16, color: Color(0xFF7C3AED)),
                              SizedBox(width: 8),
                              Text('Administrator (Full Governance)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => roleVal = v);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Full Name Input
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. Maria Santos',
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Username Input
                    TextField(
                      controller: usernameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'e.g. maria_santos',
                        prefixIcon: const Icon(Icons.alternate_email_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Contact / Mobile Number Input
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Contact / Mobile Number',
                        hintText: '09XX-XXX-XXXX',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Email Address Input
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: roleVal == 'Patient'
                            ? 'e.g. maria.santos@gmail.com'
                            : 'e.g. maria.santos@denticare.clinic',
                        prefixIcon: const Icon(Icons.mail_outline_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Create Account',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter the user\'s Full Name.'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                    return;
                  }
                  final now = DateTime.now();
                  final dateStr =
                      '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
                  final rawUsername = usernameCtrl.text.trim().isEmpty
                      ? nameCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')
                      : usernameCtrl.text.trim().replaceAll('@', '');
                  final phone = phoneCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim() == '0917-'
                      ? '0917-888-1234'
                      : phoneCtrl.text.trim();
                  final email = emailCtrl.text.trim().isEmpty
                      ? (roleVal == 'Patient'
                          ? '$rawUsername@gmail.com'
                          : '$rawUsername@denticare.clinic')
                      : emailCtrl.text.trim();

                  final newUser = UserAccount(
                    id: 'usr_${now.millisecondsSinceEpoch}',
                    username: rawUsername,
                    fullName: nameCtrl.text.trim(),
                    email: email,
                    contactNumber: phone,
                    role: roleVal,
                    status: 'Active',
                    registeredDate: dateStr,
                  );
                  widget.onAddUser(newUser);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '$roleVal account for "${newUser.fullName}" created successfully!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Edit User / Staff Dialog
  void _showEditUserDialog(UserAccount u) {
    final nameCtrl = TextEditingController(text: u.fullName);
    final phoneCtrl = TextEditingController(text: u.contactNumber);
    final emailCtrl = TextEditingController(text: u.email);
    String roleVal = u.role;
    String statusVal = u.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.manage_accounts_rounded,
                      color: Color(0xFF003B81), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Edit User Account',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'Modify details for @${u.username}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // Assigned Role Dropdown
                    DropdownButtonFormField<String>(
                      value: roleVal,
                      decoration: InputDecoration(
                        labelText: 'Assigned Role',
                        prefixIcon: Icon(
                          roleVal == 'Administrator'
                              ? Icons.admin_panel_settings_rounded
                              : (roleVal == 'Clinic Staff'
                                  ? Icons.badge_rounded
                                  : Icons.person_rounded),
                          color: roleVal == 'Administrator'
                              ? const Color(0xFF7C3AED)
                              : (roleVal == 'Clinic Staff'
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF003B81)),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Patient',
                          child: Row(
                            children: const [
                              Icon(Icons.person_outline,
                                  size: 16, color: Color(0xFF003B81)),
                              SizedBox(width: 8),
                              Text('Patient (Walk-in or App User)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Clinic Staff',
                          child: Row(
                            children: const [
                              Icon(Icons.badge_outlined,
                                  size: 16, color: Color(0xFF059669)),
                              SizedBox(width: 8),
                              Text('Clinic Staff (Front Desk / Reception)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Administrator',
                          child: Row(
                            children: const [
                              Icon(Icons.shield_outlined,
                                  size: 16, color: Color(0xFF7C3AED)),
                              SizedBox(width: 8),
                              Text('Administrator (Full Governance)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => roleVal = v);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: statusVal,
                      decoration: InputDecoration(
                        labelText: 'Account Status',
                        prefixIcon: Icon(
                          statusVal == 'Active'
                              ? Icons.check_circle_rounded
                              : Icons.block_rounded,
                          color: statusVal == 'Active'
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Active',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: Color(0xFF16A34A)),
                              SizedBox(width: 8),
                              Text('Active (Full Access)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF166534))),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Suspended',
                          child: Row(
                            children: [
                              Icon(Icons.block_rounded,
                                  size: 16, color: Color(0xFFDC2626)),
                              SizedBox(width: 8),
                              Text('Suspended (Restricted Access)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF991B1B))),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => statusVal = v);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Full Name Input
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Contact / Mobile Number Input
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Contact / Mobile Number',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Email Address Input
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.mail_outline_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final updated = u.copyWith(
                    fullName: nameCtrl.text.trim(),
                    contactNumber: phoneCtrl.text.trim().isEmpty
                        ? u.contactNumber
                        : phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty
                        ? u.email
                        : emailCtrl.text.trim(),
                    role: roleVal,
                    status: statusVal,
                  );
                  widget.onUpdateUser?.call(updated);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Account details for "${updated.fullName}" updated successfully!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // View User Profile & Booking History Dialog
  void _showUserDetailsDialog(UserAccount u) {
    final bool isActive = u.status == 'Active';
    final Color roleColor = u.role == 'Administrator'
        ? const Color(0xFF7C3AED)
        : (u.role == 'Clinic Staff'
            ? const Color(0xFF059669)
            : const Color(0xFF003B81));
    final Color roleBg = u.role == 'Administrator'
        ? const Color(0xFFF5F3FF)
        : (u.role == 'Clinic Staff'
            ? const Color(0xFFECFDF5)
            : const Color(0xFFEFF6FF));
    final IconData roleIcon = u.role == 'Administrator'
        ? Icons.admin_panel_settings_rounded
        : (u.role == 'Clinic Staff'
            ? Icons.badge_rounded
            : Icons.person_rounded);

    // Find linked patient appointments
    final patientAppts = widget.appointments.where((a) {
      final pName = a.patientName.toLowerCase().trim();
      final uName = u.fullName.toLowerCase().trim();
      return pName == uName ||
          pName.contains(uName) ||
          uName.contains(pName) ||
          a.id.toLowerCase().contains(u.username.toLowerCase());
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: roleBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: roleColor.withValues(alpha: 0.3)),
              ),
              child: Icon(roleIcon, color: roleColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.fullName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${u.username} • Registered ${u.registeredDate}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon:
                  const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                // Badges row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleBg,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: roleColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        u.role,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFECACA),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            u.status,
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Contact Information Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded,
                              size: 16, color: Color(0xFF003B81)),
                          const SizedBox(width: 8),
                          const Text('Email:',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              u.email,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 16, color: Color(0xFF003B81)),
                          const SizedBox(width: 8),
                          const Text('Mobile:',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              u.contactNumber,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Clinical Appointment Records (for Patients)
                if (u.role == 'Patient') ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.event_note_rounded,
                          size: 18, color: Color(0xFF003B81)),
                      const SizedBox(width: 6),
                      const Text(
                        'Clinical Appointments & Visits',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003B81).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${patientAppts.length} Record(s)',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003B81)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (patientAppts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 28, color: Colors.grey.shade400),
                            const SizedBox(height: 6),
                            Text(
                              'No clinical appointment history found.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Patient can book via mobile app or receptionist intake.',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...patientAppts.map((a) {
                      final Color statusColor = a.status == 'Confirmed'
                          ? const Color(0xFF10B981)
                          : (a.status == 'In Treatment'
                              ? const Color(0xFF003B81)
                              : (a.status == 'Completed'
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFFEF4444)));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.medical_services_outlined,
                                  color: statusColor, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.serviceName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${a.dentistName} • ${a.date} at ${a.time}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                a.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003B81),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit Account',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showEditUserDialog(u);
            },
          ),
        ],
      ),
    );
  }

  // Delete User Confirmation Dialog
  void _confirmDeleteUser(UserAccount u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Delete Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Text(
            'Are you sure you want to permanently delete the account for "${u.fullName}" (@${u.username})? This user will no longer be able to log in or access clinic records.',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            label: const Text('Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              widget.onDeleteUser?.call(u.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // Add Service Dialog
  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '1 hour');
    final costCtrl = TextEditingController(text: 'P500.00 - P1,000.00');
    String categoryVal = 'Preventive';
    String doctorVal = widget.dentists.isNotEmpty
        ? widget.dentists.first.name
        : 'Any Available Specialist';
    bool isAvailableVal = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_business_rounded,
                      color: Color(0xFF003B81), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Add Dental Service',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text(
                        'Register a new procedure, duration, and patient pricing',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // Category Selection
                    DropdownButtonFormField<String>(
                      value: categoryVal,
                      decoration: InputDecoration(
                        labelText: 'Clinical Category',
                        prefixIcon: const Icon(Icons.category_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Preventive',
                            child: Text('Preventive & Prophylaxis')),
                        DropdownMenuItem(
                            value: 'Orthodontics',
                            child: Text('Orthodontics & Alignment')),
                        DropdownMenuItem(
                            value: 'Cosmetic',
                            child: Text('Cosmetic & Whitening')),
                        DropdownMenuItem(
                            value: 'Restorative',
                            child: Text('Restorative & Implants')),
                        DropdownMenuItem(
                            value: 'Oral Surgery',
                            child: Text('Oral Surgery & Extraction')),
                        DropdownMenuItem(
                            value: 'General', child: Text('General Dentistry')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => categoryVal = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Assigned Doctor
                    DropdownButtonFormField<String>(
                      value: doctorVal,
                      decoration: InputDecoration(
                        labelText: 'Assigned Specialist Doctor',
                        prefixIcon: const Icon(Icons.person_pin_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'Any Available Specialist',
                          child: Text(
                            'Any Available Specialist (General Pool)',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...widget.dentists.map((d) {
                          return DropdownMenuItem(
                            value: d.name,
                            child: Text(
                              '${d.name} (${d.specialization})',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => doctorVal = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Procedure Name
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Procedure Name',
                        hintText: 'e.g. Tooth Extraction',
                        prefixIcon: const Icon(Icons.medical_services_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Clinical Description
                    TextField(
                      controller: descCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Clinical Description',
                        hintText:
                            'Brief explanation of clinical treatment steps...',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 36),
                          child: Icon(Icons.notes_rounded,
                              color: Color(0xFF003B81), size: 20),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    TextField(
                      controller: durationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Estimated Duration',
                        hintText: 'e.g. 45 mins to 1 hour',
                        helperText:
                            'Standard chair-time expected for this treatment',
                        helperStyle: const TextStyle(fontSize: 11),
                        prefixIcon: const Icon(Icons.schedule_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cost
                    TextField(
                      controller: costCtrl,
                      decoration: InputDecoration(
                        labelText: 'Price Range (PHP)',
                        hintText: 'e.g. P600.00 - P1,200.00',
                        helperText:
                            'Displayed on patient booking estimate card',
                        helperStyle: const TextStyle(fontSize: 11),
                        prefixIcon: const Icon(Icons.payments_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Availability Status Card
                    Container(
                      decoration: BoxDecoration(
                        color: isAvailableVal
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAvailableVal
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFDE68A),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvailableVal
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available for Patient Booking',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailableVal
                                        ? const Color(0xFF166534)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAvailableVal
                                      ? 'Active & visible in patient booking catalog'
                                      : 'Paused (Temporarily unavailable for booking)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isAvailableVal
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isAvailableVal,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (v) =>
                                setDialogState(() => isAvailableVal = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Service',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;
                  final newSrv = DentalService(
                    id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    cost: costCtrl.text.trim(),
                    icon: Icons.medical_services_rounded,
                    category: categoryVal,
                    isAvailable: isAvailableVal,
                    assignedDoctor: doctorVal,
                  );
                  widget.onAddService(newSrv);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Service "${newSrv.name}" added to clinic catalog!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Edit Service Dialog
  void _showEditServiceDialog(DentalService service) {
    final nameCtrl = TextEditingController(text: service.name);
    final descCtrl = TextEditingController(text: service.description);
    final durationCtrl = TextEditingController(text: service.duration);
    final costCtrl = TextEditingController(text: service.cost);
    String categoryVal = service.category;
    String doctorVal = service.assignedDoctor ?? 'Any Available Specialist';
    bool isAvailableVal = service.isAvailable;

    // Check if the current assignedDoctor exists in the roster or general pool
    final availableDoctorOptions = [
      'Any Available Specialist',
      ...widget.dentists.map((d) => d.name),
    ];
    if (!availableDoctorOptions.contains(doctorVal)) {
      doctorVal = 'Any Available Specialist';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: service.imageAsset != null
                      ? Image.asset(
                          service.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(service.icon,
                              color: const Color(0xFF003B81), size: 22),
                        )
                      : Icon(service.icon,
                          color: const Color(0xFF003B81), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Edit Dental Service',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'Update procedure details, doctor assignment & pricing',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // Category Selection
                    DropdownButtonFormField<String>(
                      value: categoryVal,
                      decoration: InputDecoration(
                        labelText: 'Clinical Category',
                        prefixIcon: const Icon(Icons.category_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Preventive',
                            child: Text('Preventive & Prophylaxis')),
                        DropdownMenuItem(
                            value: 'Orthodontics',
                            child: Text('Orthodontics & Alignment')),
                        DropdownMenuItem(
                            value: 'Cosmetic',
                            child: Text('Cosmetic & Whitening')),
                        DropdownMenuItem(
                            value: 'Restorative',
                            child: Text('Restorative & Implants')),
                        DropdownMenuItem(
                            value: 'Oral Surgery',
                            child: Text('Oral Surgery & Extraction')),
                        DropdownMenuItem(
                            value: 'General', child: Text('General Dentistry')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => categoryVal = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Assigned Specialist Doctor
                    DropdownButtonFormField<String>(
                      value: doctorVal,
                      decoration: InputDecoration(
                        labelText: 'Assigned Specialist Doctor',
                        prefixIcon: const Icon(Icons.person_pin_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'Any Available Specialist',
                          child: Text(
                            'Any Available Specialist (General Pool)',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...widget.dentists.map((d) {
                          return DropdownMenuItem(
                            value: d.name,
                            child: Text(
                              '${d.name} (${d.specialization})',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => doctorVal = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Procedure Name
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Procedure Name',
                        prefixIcon: const Icon(Icons.medical_services_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description (Expanded minLines: 3, maxLines: 5)
                    TextField(
                      controller: descCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Clinical Description',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 36),
                          child: Icon(Icons.notes_rounded,
                              color: Color(0xFF003B81), size: 20),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    TextField(
                      controller: durationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Estimated Duration',
                        helperText:
                            'Standard chair-time expected for this treatment',
                        helperStyle: const TextStyle(fontSize: 11),
                        prefixIcon: const Icon(Icons.schedule_rounded,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cost
                    TextField(
                      controller: costCtrl,
                      decoration: InputDecoration(
                        labelText: 'Price Range (PHP)',
                        helperText:
                            'Displayed on patient booking estimate card',
                        helperStyle: const TextStyle(fontSize: 11),
                        prefixIcon: const Icon(Icons.payments_outlined,
                            color: Color(0xFF003B81), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF003B81), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Availability Status Card
                    Container(
                      decoration: BoxDecoration(
                        color: isAvailableVal
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAvailableVal
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFDE68A),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvailableVal
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available for Patient Booking',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailableVal
                                        ? const Color(0xFF166534)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAvailableVal
                                      ? 'Active & visible in patient booking catalog'
                                      : 'Paused (Temporarily unavailable for booking)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isAvailableVal
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isAvailableVal,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (v) =>
                                setDialogState(() => isAvailableVal = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (nameCtrl.text.isEmpty) return;
                  final updatedSrv = service.copyWith(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    cost: costCtrl.text.trim(),
                    category: categoryVal,
                    isAvailable: isAvailableVal,
                    assignedDoctor: doctorVal,
                  );
                  widget.onUpdateService(updatedSrv);
                  setState(() {});
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Procedure "${updatedSrv.name}" updated successfully!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Delete Service Confirmation
  void _confirmDeleteService(DentalService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Remove Procedure',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${service.name}" from the clinic services catalog?\n\nExisting appointments booked under this procedure will remain intact.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.onDeleteService?.call(service.id);
              setState(() {});
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Procedure "${service.name}" removed from catalog.'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
            child: const Text('Remove Procedure'),
          ),
        ],
      ),
    );
  }

  // Add Dentist Dialog
  void _showAddDentistDialog() {
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController(text: '5 years of experience');
    final specCtrl =
        TextEditingController(text: 'General Dentistry\nPediatric Dentistry');
    final qualCtrl =
        TextEditingController(text: 'Doctor of Dental Medicine (DMD)');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF003B81).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.badge_rounded,
                  color: Color(0xFF003B81), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Register Doctor to Roster',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(
                    'Add clinical doctor, credentials, and practice areas',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Doctor Name',
                    hintText: 'e.g. Dr. Jane Doe',
                    prefixIcon: const Icon(Icons.person_rounded,
                        color: Color(0xFF003B81), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: expCtrl,
                  decoration: InputDecoration(
                    labelText: 'Years of Experience',
                    hintText: 'e.g. 6 years of experience',
                    prefixIcon: const Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFF003B81), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: specCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Specializations (comma separated)',
                    hintText: 'Orthodontics, Cosmetic Dentistry, Surgery',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(Icons.medical_services_outlined,
                          color: Color(0xFF003B81), size: 20),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: qualCtrl,
                  decoration: InputDecoration(
                    labelText: 'Degree & Qualifications',
                    hintText:
                        'Doctor of Dental Medicine (DMD), PRC Lic. Verified',
                    prefixIcon: const Icon(Icons.school_rounded,
                        color: Color(0xFF003B81), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003B81),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Register Doctor',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final newDoc = Dentist(
                id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                experience: expCtrl.text.trim(),
                specialization: specCtrl.text.trim(),
                qualification: qualCtrl.text.trim(),
                avatarIcon: Icons.medical_services_rounded,
              );
              widget.onAddDentist(newDoc);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${newDoc.name} registered to clinic!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Edit Dentist Dialog
  void _showEditDentistDialog(Dentist doc) {
    final nameCtrl = TextEditingController(text: doc.name);
    final expCtrl = TextEditingController(text: doc.experience);
    final specCtrl = TextEditingController(text: doc.specialization);
    final qualCtrl = TextEditingController(text: doc.qualification);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF003B81).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_square,
                  color: Color(0xFF003B81), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Edit Doctor Profile',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(
                    'Update credentials, experience, and practice domains',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Doctor Name',
                    prefixIcon: const Icon(Icons.person_rounded,
                        color: Color(0xFF003B81), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: expCtrl,
                  decoration: InputDecoration(
                    labelText: 'Years of Experience',
                    prefixIcon: const Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFF003B81), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: specCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Specializations (comma separated)',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(Icons.medical_services_outlined,
                          color: Color(0xFF003B81), size: 20),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: qualCtrl,
                  decoration: InputDecoration(
                    labelText: 'Degree & Qualifications',
                    prefixIcon: const Icon(Icons.school_rounded,
                        color: Color(0xFF003B81), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF003B81), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003B81),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Save Changes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final updatedDoc = doc.copyWith(
                name: nameCtrl.text.trim(),
                experience: expCtrl.text.trim(),
                specialization: specCtrl.text.trim(),
                qualification: qualCtrl.text.trim(),
              );
              widget.onUpdateDentist?.call(updatedDoc);
              setState(() {});
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Doctor "${updatedDoc.name}" profile updated successfully!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Delete Dentist Confirmation Dialog
  void _confirmDeleteDentist(Dentist doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Remove Doctor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${doc.name}" from the active clinic roster?\n\nExisting patient appointment records will remain intact.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.onDeleteDentist?.call(doc.id);
              setState(() {});
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Doctor "${doc.name}" removed from clinic roster.'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
            child: const Text('Remove Doctor'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Administrator Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'System Supervision & Governance',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (widget.onToggleLargeFont != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Tooltip(
                message: (widget.isLargeFont ?? false)
                    ? 'Switch to Standard Font Size (100%)'
                    : 'Switch to Large Font Size (122% for Accessibility)',
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: (widget.isLargeFont ?? false)
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    foregroundColor: (widget.isLargeFont ?? false)
                        ? const Color(0xFF003B81)
                        : const Color(0xFF475569),
                    side: BorderSide(
                      color: (widget.isLargeFont ?? false)
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                  icon: Icon(
                    (widget.isLargeFont ?? false)
                        ? Icons.text_increase_rounded
                        : Icons.format_size_rounded,
                    size: 16,
                  ),
                  label: Text(
                    (widget.isLargeFont ?? false)
                        ? 'Font: Large'
                        : 'Font: Normal',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () {
                    final newVal = !(widget.isLargeFont ?? false);
                    widget.onToggleLargeFont?.call(newVal);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(newVal
                            ? 'Accessibility: Large font enabled (122% scale)'
                            : 'Standard font size restored (100% scale)'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF003B81),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (widget.onLogout != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: widget.onLogout,
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserManagementTab(),
          _buildServicesCatalogTab(),
          _buildDentistRosterTab(),
          _buildAnalyticsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
            _tabController.animateTo(idx);
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded,
                color: Color(0xFF003B81)),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_information_outlined),
            selectedIcon: Icon(Icons.medical_information_rounded,
                color: Color(0xFF003B81)),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon:
                Icon(Icons.people_rounded, color: Color(0xFF003B81)),
            label: 'Dentists',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon:
                Icon(Icons.insights_rounded, color: Color(0xFF003B81)),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: USER ACCOUNTS MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildUserManagementTab() {
    final filteredUsers = widget.users.where((u) {
      if (_selectedRoleFilter != 'All' && u.role != _selectedRoleFilter) {
        return false;
      }
      final q = _userSearchQuery.toLowerCase();
      return u.username.toLowerCase().contains(q) ||
          u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();

    final totalCount = widget.users.length;
    final patientCount =
        widget.users.where((u) => u.role == 'Patient').length;
    final staffCount =
        widget.users.where((u) => u.role == 'Clinic Staff').length;
    final adminCount =
        widget.users.where((u) => u.role == 'Administrator').length;

    return Column(
      children: [
        // Controls Header Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Add Button Row (Aligned & Equal Height)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _userSearchCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search,
                              size: 20, color: Color(0xFF003B81)),
                          hintText: 'Search username, full name, or email...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF003B81), width: 1.5),
                          ),
                          suffixIcon: _userSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _userSearchCtrl.clear();
                                    setState(() => _userSearchQuery = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) => setState(() => _userSearchQuery = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF003B81),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                      onPressed: _showAddUserDialog,
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text(
                        'Add New Account',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Fast Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRoleFilterChip('All', 'All ($totalCount)'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip('Patient', 'Patients ($patientCount)'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip('Clinic Staff', 'Staff ($staffCount)'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip(
                        'Administrator', 'Admins ($adminCount)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // User List
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded,
                          size: 54, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        'No user accounts found matching query.',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, i) {
                    final u = filteredUsers[i];
                    final isActive = u.status == 'Active';

                    Color roleColor = const Color(0xFF003B81); // Patient Navy
                    Color roleBg = const Color(0xFFEFF6FF);
                    Color roleBorder = const Color(0xFFBFDBFE);
                    IconData roleIcon = Icons.person_rounded;

                    if (u.role == 'Administrator') {
                      roleColor = const Color(0xFF7C3AED); // Royal Purple
                      roleBg = const Color(0xFFF5F3FF);
                      roleBorder = const Color(0xFFDDD6FE);
                      roleIcon = Icons.admin_panel_settings_rounded;
                    } else if (u.role == 'Clinic Staff') {
                      roleColor = const Color(0xFF059669); // Emerald Green
                      roleBg = const Color(0xFFECFDF5);
                      roleBorder = const Color(0xFFA7F3D0);
                      roleIcon = Icons.badge_rounded;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showUserDetailsDialog(u),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: roleColor, width: 4.5),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Avatar, Name/Username, Role & Status Badges, Menu
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Avatar Box
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: roleBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: roleBorder),
                                      ),
                                      child: Icon(roleIcon,
                                          color: roleColor, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    // Name & Username
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            u.fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF0F172A),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '@${u.username}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Role Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: roleBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: roleBorder),
                                      ),
                                      child: Text(
                                        u.role,
                                        style: TextStyle(
                                          color: roleColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Status Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? const Color(0xFFF0FDF4)
                                            : const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isActive
                                              ? const Color(0xFFBBF7D0)
                                              : const Color(0xFFFECACA),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isActive
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFDC2626),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            u.status,
                                            style: TextStyle(
                                              color: isActive
                                                  ? const Color(0xFF166534)
                                                  : const Color(0xFFDC2626),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // More Actions Menu
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      onSelected: (action) {
                                        if (action == 'details') {
                                          _showUserDetailsDialog(u);
                                        } else if (action == 'edit') {
                                          _showEditUserDialog(u);
                                        } else if (action == 'toggle') {
                                          widget.onToggleUserStatus(
                                              u.id,
                                              isActive
                                                  ? 'Suspended'
                                                  : 'Active');
                                        } else if (action == 'reset') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Password reset link dispatched to ${u.email}'),
                                              backgroundColor:
                                                  const Color(0xFF10B981),
                                            ),
                                          );
                                        } else if (action == 'delete') {
                                          _confirmDeleteUser(u);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'details',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility_outlined,
                                                  size: 18,
                                                  color: Color(0xFF003B81)),
                                              SizedBox(width: 8),
                                              Text('View Profile & Visits'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined,
                                                  size: 18,
                                                  color: Color(0xFF003B81)),
                                              SizedBox(width: 8),
                                              Text('Edit Account Details'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'toggle',
                                          child: Row(
                                            children: [
                                              Icon(
                                                isActive
                                                    ? Icons.block_rounded
                                                    : Icons
                                                        .check_circle_outline_rounded,
                                                size: 18,
                                                color: isActive
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text(isActive
                                                  ? 'Suspend Account'
                                                  : 'Activate Account'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'reset',
                                          child: Row(
                                            children: [
                                              Icon(Icons.lock_reset_rounded,
                                                  size: 18),
                                              SizedBox(width: 8),
                                              Text('Reset Password'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline_rounded,
                                                  size: 18,
                                                  color: Color(0xFFEF4444)),
                                              SizedBox(width: 8),
                                              Text('Delete Account',
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xFFEF4444))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Divider(height: 1, color: Colors.grey.shade100),
                                const SizedBox(height: 8),
                                // Bottom Row: Email, Contact, Registration Date
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.email_outlined,
                                            size: 14,
                                            color: Colors.grey.shade500),
                                        const SizedBox(width: 5),
                                        Text(
                                          u.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_outlined,
                                            size: 14,
                                            color: Colors.grey.shade500),
                                        const SizedBox(width: 5),
                                        Text(
                                          u.contactNumber,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today_outlined,
                                            size: 13,
                                            color: Colors.grey.shade500),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Registered ${u.registeredDate}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoleFilterChip(String roleKey, String label) {
    final isSelected = _selectedRoleFilter == roleKey;
    return InkWell(
      onTap: () => setState(() => _selectedRoleFilter = roleKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF003B81)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF003B81)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: DENTAL SERVICES CATALOG
  // -------------------------------------------------------------
  Widget _buildServiceCategoryChip(String catKey, String label) {
    final isSelected = _selectedServiceCategory == catKey;
    return InkWell(
      onTap: () => setState(() => _selectedServiceCategory = catKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF003B81) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF003B81)
                : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF003B81).withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesCatalogTab() {
    final filteredServices = widget.services.where((srv) {
      final matchesCategory = _selectedServiceCategory == 'All' ||
          srv.category.toLowerCase() == _selectedServiceCategory.toLowerCase();
      if (!matchesCategory) return false;
      if (_serviceSearchQuery.isEmpty) return true;
      final q = _serviceSearchQuery.toLowerCase().trim();
      return srv.name.toLowerCase().contains(q) ||
          srv.description.toLowerCase().contains(q) ||
          srv.duration.toLowerCase().contains(q) ||
          srv.cost.toLowerCase().contains(q) ||
          srv.category.toLowerCase().contains(q);
    }).toList();

    int countCat(String c) => widget.services
        .where((s) => s.category.toLowerCase() == c.toLowerCase())
        .length;

    return Column(
      children: [
        // Controls Header Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar and + Add Service button (equal height 44px)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _serviceSearchCtrl,
                        onChanged: (v) =>
                            setState(() => _serviceSearchQuery = v),
                        decoration: InputDecoration(
                          hintText:
                              'Search procedure name, keyword, or duration...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.search_rounded,
                              size: 20, color: Colors.grey.shade600),
                          suffixIcon: _serviceSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18),
                                  onPressed: () {
                                    _serviceSearchCtrl.clear();
                                    setState(() => _serviceSearchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003B81),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                      onPressed: _showAddServiceDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add Service',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildServiceCategoryChip(
                        'All', 'All (${widget.services.length})'),
                    const SizedBox(width: 8),
                    _buildServiceCategoryChip('Preventive',
                        'Preventive (${countCat('Preventive')})'),
                    const SizedBox(width: 8),
                    _buildServiceCategoryChip(
                        'Cosmetic', 'Cosmetic (${countCat('Cosmetic')})'),
                    const SizedBox(width: 8),
                    _buildServiceCategoryChip('Orthodontics',
                        'Orthodontics (${countCat('Orthodontics')})'),
                    const SizedBox(width: 8),
                    _buildServiceCategoryChip('Restorative',
                        'Restorative (${countCat('Restorative')})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Service Cards List
        Expanded(
          child: filteredServices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No clinical services found for "$_serviceSearchQuery"',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset filters'),
                        onPressed: () {
                          _serviceSearchCtrl.clear();
                          setState(() {
                            _serviceSearchQuery = '';
                            _selectedServiceCategory = 'All';
                          });
                        },
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, i) {
                    final srv = filteredServices[i];

                    // Find assigned doctor by specialty
                    String assignedDoctor = 'Dr. Grace Cabilles';
                    if (srv.category == 'Preventive') {
                      assignedDoctor = 'Dr. Joana Plewa';
                    } else if (srv.category == 'Restorative') {
                      assignedDoctor = 'Dr. Ryan Luza';
                    } else if (srv.category == 'Cosmetic') {
                      assignedDoctor = 'Dr. Niere Lupmac';
                    }

                    // Count active bookings
                    final bookingCount = widget.appointments
                        .where((a) =>
                            a.serviceName.toLowerCase().trim() ==
                            srv.name.toLowerCase().trim())
                        .length;

                    // Category color
                    Color catColor = const Color(0xFF003B81);
                    Color catBg = const Color(0xFFEFF6FF);
                    if (srv.category == 'Preventive') {
                      catColor = const Color(0xFF059669);
                      catBg = const Color(0xFFECFDF5);
                    } else if (srv.category == 'Cosmetic') {
                      catColor = const Color(0xFFD97706);
                      catBg = const Color(0xFFFFFBEB);
                    } else if (srv.category == 'Restorative') {
                      catColor = const Color(0xFF7C3AED);
                      catBg = const Color(0xFFF5F3FF);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: srv.isAvailable
                              ? Colors.grey.shade200
                              : const Color(0xFFFDE68A),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: srv.isAvailable
                                  ? const Color(0xFF003B81)
                                  : const Color(0xFFF59E0B),
                              width: 4.5,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Thumbnail, Name, Category chip, Availability toggle, Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (srv.imageAsset != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      srv.imageAsset!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF003B81)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(srv.icon,
                                            color: const Color(0xFF003B81),
                                            size: 22),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003B81)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(srv.icon,
                                        color: const Color(0xFF003B81),
                                        size: 22),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              srv.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF0F172A),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: catBg,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: catColor.withValues(
                                                      alpha: 0.3)),
                                            ),
                                            child: Text(
                                              srv.category,
                                              style: TextStyle(
                                                color: catColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      // Availability Toggle Pill
                                      InkWell(
                                        onTap: () {
                                          final newAvail = !srv.isAvailable;
                                          widget.onUpdateService(
                                              srv.copyWith(isAvailable: newAvail));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Service "${srv.name}" is now ${newAvail ? "Active & Available for Booking" : "Paused (Temporarily Unavailable)"}',
                                              ),
                                              backgroundColor: newAvail
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFF59E0B),
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: srv.isAvailable
                                                ? const Color(0xFFF0FDF4)
                                                : const Color(0xFFFFFBEB),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: srv.isAvailable
                                                  ? const Color(0xFFBBF7D0)
                                                  : const Color(0xFFFDE68A),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: srv.isAvailable
                                                      ? const Color(0xFF16A34A)
                                                      : const Color(0xFFD97706),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                srv.isAvailable
                                                    ? 'Available for Booking'
                                                    : 'Paused (Maintenance)',
                                                style: TextStyle(
                                                  color: srv.isAvailable
                                                      ? const Color(0xFF166534)
                                                      : const Color(0xFFB45309),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              Icon(
                                                Icons.swap_horiz_rounded,
                                                size: 12,
                                                color: srv.isAvailable
                                                    ? const Color(0xFF166534)
                                                    : const Color(0xFFB45309),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF86EFAC)),
                                  ),
                                  child: Text(
                                    srv.cost,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF166534),
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              srv.description,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.35),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),

                            // Bottom Row: Duration, Assigned Doctor, Booking Count & Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 14,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.schedule,
                                              size: 15, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Duration: ${srv.duration}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.person_pin_rounded,
                                              size: 15,
                                              color: Color(0xFF003B81)),
                                          const SizedBox(width: 4),
                                          Text(
                                            assignedDoctor,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF003B81),
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$bookingCount booking(s)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF003B81),
                                        backgroundColor:
                                            const Color(0xFFEFF6FF),
                                        side: const BorderSide(
                                            color: Color(0xFFBFDBFE),
                                            width: 1.2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(Icons.edit_square,
                                          size: 15,
                                          color: Color(0xFF003B81)),
                                      label: const Text(
                                        'Edit Details',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () =>
                                          _showEditServiceDialog(srv),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFFDC2626),
                                        side: const BorderSide(
                                            color: Color(0xFFFECACA),
                                            width: 1.2),
                                        backgroundColor:
                                            const Color(0xFFFEF2F2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 15),
                                      label: const Text(
                                        'Delete',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () =>
                                          _confirmDeleteService(srv),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: DENTIST PROFILES MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildDentistRosterTab() {
    final filteredDocs = widget.dentists.where((d) {
      if (_dentistSearchQuery.isEmpty) return true;
      final q = _dentistSearchQuery.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.specialization.toLowerCase().contains(q) ||
          d.qualification.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Controls Header Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Registered Clinic Doctors',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003B81)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filteredDocs.length} doctors',
                              style: const TextStyle(
                                color: Color(0xFF003B81),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Manage specialist rosters, credentials, and practice domains',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search & Add Doctor Row (Equal 44px Height)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _dentistSearchCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search,
                              size: 20, color: Color(0xFF003B81)),
                          hintText: 'Search doctor by name or specialty...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF003B81), width: 1.5),
                          ),
                          suffixIcon: _dentistSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _dentistSearchCtrl.clear();
                                    setState(() => _dentistSearchQuery = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) =>
                            setState(() => _dentistSearchQuery = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF003B81),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                      onPressed: _showAddDentistDialog,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text(
                        'Add Doctor',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Doctors List
        Expanded(
          child: filteredDocs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No doctors match your search query.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, i) {
                    final doc = filteredDocs[i];
                    final isAny = doc.id == 'doc_any' ||
                        doc.name.contains('Any Available');

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: Colors.grey.shade200, width: 1.2),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Avatar, Name, Badges
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isAny
                                        ? Colors.grey.shade100
                                        : const Color(0xFF003B81)
                                            .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    doc.avatarIcon,
                                    color: isAny
                                        ? Colors.grey.shade700
                                        : const Color(0xFF003B81),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            doc.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          if (isAny)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFFBFDBFE)),
                                              ),
                                              child: const Text(
                                                '🤖 System Auto-Assign',
                                                style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Color(0xFF003B81)),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        doc.qualification
                                            .replaceAll('\n', ', '),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isAny) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      doc.experience,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF003B81)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.circle,
                                            size: 6,
                                            color: Color(0xFF166534)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Active',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF166534)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Specialization Chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: doc.specialization
                                  .split(RegExp(r'[,\n]'))
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .map(
                                    (spec) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Text(
                                        spec,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),

                            // Bottom Row Actions
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isAny
                                          ? Icons.smart_toy_outlined
                                          : Icons.verified_user_outlined,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isAny
                                          ? 'Default system pool for bookings'
                                          : 'Verified Practice Specialist',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF003B81),
                                        backgroundColor:
                                            const Color(0xFFEFF6FF),
                                        side: const BorderSide(
                                            color: Color(0xFFBFDBFE),
                                            width: 1.2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(Icons.edit_square,
                                          size: 14,
                                          color: Color(0xFF003B81)),
                                      label: const Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () =>
                                          _showEditDentistDialog(doc),
                                    ),
                                    if (!isAny) ...[
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFFDC2626),
                                          side: const BorderSide(
                                              color: Color(0xFFFECACA),
                                              width: 1.2),
                                          backgroundColor:
                                              const Color(0xFFFEF2F2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 7),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                        ),
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 14),
                                        label: const Text(
                                          'Remove',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () =>
                                            _confirmDeleteDentist(doc),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: CLINIC ANALYTICS & SUPERVISION
  // -------------------------------------------------------------
  Widget _buildAnalyticsTab() {
    final totalBookings = widget.appointments.length;
    final confirmedCount =
        widget.appointments.where((a) => a.status == 'Confirmed').length;
    final inTreatmentCount =
        widget.appointments.where((a) => a.status == 'In Treatment').length;
    final completedCount =
        widget.appointments.where((a) => a.status == 'Completed').length;
    final cancelledCount =
        widget.appointments.where((a) => a.status == 'Cancelled').length;

    final cancelRate = totalBookings > 0
        ? ((cancelledCount / totalBookings) * 100).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Performance & Clinic Metrics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 14),

          // 2 Metrics Cards in each line (Clickable with full breakdowns)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Bookings',
                  '$totalBookings',
                  Icons.calendar_month_rounded,
                  const Color(0xFF2563EB),
                  onTap: () => _showAppointmentsSummaryDialog(
                      'All Clinic Bookings', widget.appointments),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  'Registered Users',
                  '${widget.users.length}',
                  Icons.people_rounded,
                  const Color(0xFF10B981),
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                      _tabController.animateTo(0);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Completed Visits',
                  '$completedCount',
                  Icons.task_alt_rounded,
                  Colors.purple,
                  onTap: () {
                    final completed = widget.appointments
                        .where((a) => a.status == 'Completed')
                        .toList();
                    _showAppointmentsSummaryDialog(
                        'Completed Procedures', completed);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  'Cancellation Rate',
                  '$cancelRate%',
                  Icons.trending_down_rounded,
                  Colors.red,
                  onTap: () {
                    final cancelled = widget.appointments
                        .where((a) => a.status == 'Cancelled')
                        .toList();
                    _showAppointmentsSummaryDialog(
                        'Cancelled Appointments Audit', cancelled);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Weekly Patient Traffic Bar Graph
          _buildWeeklyBarChart(),
          const SizedBox(height: 18),

          // 2. Appointment Status & Fulfillment Donut/Pie Chart
          _buildAppointmentStatusPieCard(
              totalBookings, confirmedCount, inTreatmentCount, completedCount, cancelledCount),
          const SizedBox(height: 20),

          // Revenue & Audit Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF003B81),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Colors.amber, size: 36),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Clinic Revenue',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        'P18,400.00 - P26,500.00',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Audit Validated',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon at the left side
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                radius: 15,
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 6),
              // Text in the center
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              // Numeric value at the right side
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentsSummaryDialog(
      String title, List<AppointmentRecord> list) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF003B81).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics_outlined,
                  color: Color(0xFF003B81), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No records found for this metric.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (c, i) {
                    final appt = list[i];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(appt.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${appt.patientName} • ${appt.date} at ${appt.time} • ${appt.dentistName}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: appt.status == 'Confirmed'
                              ? const Color(0xFFDCFCE7)
                              : (appt.status == 'Completed'
                                  ? const Color(0xFFF3E8FF)
                                  : (appt.status == 'Cancelled'
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFEFF6FF))),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          appt.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: appt.status == 'Confirmed'
                                ? const Color(0xFF166534)
                                : (appt.status == 'Completed'
                                    ? Colors.purple
                                    : (appt.status == 'Cancelled'
                                        ? Colors.red
                                        : const Color(0xFF1E40AF))),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    // Colors, proportions and solid flat styling matched exactly to user's sample template
    final List<Map<String, dynamic>> weekData = [
      {
        'day': 'Mon',
        'count': 7,
        'ratio': 0.82,
        'color': const Color(0xFF0077B6),
        'isPeak': false
      },
      {
        'day': 'Tue',
        'count': 9,
        'ratio': 1.00,
        'color': const Color(0xFF00B4D8), // Highest / vibrant cyan peak
        'isPeak': true
      },
      {
        'day': 'Wed',
        'count': 8,
        'ratio': 0.88,
        'color': const Color(0xFF0077B6),
        'isPeak': false
      },
      {
        'day': 'Thu',
        'count': 4,
        'ratio': 0.46,
        'color': const Color(0xFF0096C7),
        'isPeak': false
      },
      {
        'day': 'Fri',
        'count': 3,
        'ratio': 0.30,
        'color': const Color(0xFF48CAE4),
        'isPeak': false
      },
      {
        'day': 'Sat',
        'count': 2,
        'ratio': 0.22,
        'color': const Color(0xFF90E0EF),
        'isPeak': false
      },
      {
        'day': 'Sun',
        'count': 1,
        'ratio': 0.10,
        'color': const Color(0xFFCAF0F8),
        'isPeak': false
      },
    ];

    const double maxBarHeight = 100.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Weekly Patient Traffic',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Booking distribution across clinic operating days',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 14, color: Color(0xFF003B81)),
                      SizedBox(width: 4),
                      Text(
                        'Peak: Tuesday (9)',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003B81)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bar graph container with baseline
            Container(
              height: 165,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekData.map((item) {
                  final int count = item['count'] as int;
                  final String day = item['day'] as String;
                  final double ratio = item['ratio'] as double;
                  final Color barColor = item['color'] as Color;
                  final bool isPeak = item['isPeak'] as bool;
                  final double barH =
                      (ratio * maxBarHeight).clamp(10.0, maxBarHeight);

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$day Traffic: $count patient visits ${isPeak ? "(Peak Day)" : ""}'),
                          backgroundColor: barColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count badge above bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPeak
                                ? const Color(0xFF00B4D8)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPeak ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Flat solid bar matching sample template
                        Container(
                          width: 34,
                          height: barH,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.06),
                              width: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Day Label
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isPeak ? FontWeight.bold : FontWeight.w600,
                            color: isPeak
                                ? const Color(0xFF0077B6)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            // Baseline line
            Container(
              height: 1.5,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: Colors.grey),
                    SizedBox(width: 5),
                    Text('Current Week Cycle',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const Text(
                  'Average: 4.7 visits / day',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B81)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStatusPieCard(int total, int confirmed,
      int inTreatment, int completed, int cancelled) {
    final double confPct = total > 0 ? (confirmed / total) * 100 : 0;
    final double inTrPct = total > 0 ? (inTreatment / total) * 100 : 0;
    final double compPct = total > 0 ? (completed / total) * 100 : 0;
    final double cancPct = total > 0 ? (cancelled / total) * 100 : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Appointment Status & Fulfillment',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Proportional breakdown by patient visit state',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$total Total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(120, 120),
                        painter: DonutChartPainter(
                          values: [
                            confirmed.toDouble(),
                            inTreatment.toDouble(),
                            completed.toDouble(),
                            cancelled.toDouble(),
                          ],
                          colors: const [
                            Color(0xFF10B981),
                            Color(0xFF2563EB),
                            Color(0xFF8B5CF6),
                            Color(0xFFEF4444),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003B81),
                            ),
                          ),
                          const Text(
                            'Bookings',
                            style:
                                TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPieLegendRow('Confirmed', confirmed, confPct,
                          const Color(0xFF10B981)),
                      const SizedBox(height: 8),
                      _buildPieLegendRow('In Treatment', inTreatment, inTrPct,
                          const Color(0xFF2563EB)),
                      const SizedBox(height: 8),
                      _buildPieLegendRow('Completed', completed, compPct,
                          const Color(0xFF8B5CF6)),
                      const SizedBox(height: 8),
                      _buildPieLegendRow('Cancelled', cancelled, cancPct,
                          const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildProgressRow('Confirmed Schedule', confirmed, total,
                const Color(0xFF10B981)),
            const SizedBox(height: 8),
            _buildProgressRow('In Treatment / Chair', inTreatment, total,
                const Color(0xFF2563EB)),
            const SizedBox(height: 8),
            _buildProgressRow('Completed Procedures', completed, total,
                const Color(0xFF8B5CF6)),
            const SizedBox(height: 8),
            _buildProgressRow(
                'Cancelled Visits', cancelled, total, const Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieLegendRow(
      String label, int count, double pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(
      String label, int count, int total, Color color) {
    final double ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text('$count',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, v) => sum + v);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (total == 0) {
      final emptyPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    double startAngle = -3.1415926535897932 / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweepAngle = (values[i] / total) * 2 * 3.1415926535897932;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

      final effectiveGap = values.where((v) => v > 0).length > 1 ? 0.06 : 0.0;
      canvas.drawArc(
        rect,
        startAngle + effectiveGap,
        sweepAngle - (effectiveGap * 2),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

