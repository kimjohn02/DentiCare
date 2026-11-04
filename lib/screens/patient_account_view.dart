import 'package:flutter/material.dart';
import '../models/dental_data.dart';
import '../widgets/dentibot_dialog.dart';

class PatientAccountView extends StatelessWidget {
  final UserAccount user;
  final bool isDarkMode;
  final bool isLargeFont;
  final ValueChanged<bool> onToggleDarkMode;
  final ValueChanged<bool> onToggleLargeFont;
  final VoidCallback onLogout;
  final ValueChanged<UserAccount>? onUpdateUser;

  const PatientAccountView({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.isLargeFont,
    required this.onToggleDarkMode,
    required this.onToggleLargeFont,
    required this.onLogout,
    this.onUpdateUser,
  });

  void _showEditContactDialog(BuildContext context) {
    final controller = TextEditingController(text: user.contactNumber);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.phone_outlined, color: Color(0xFF003B81)),
            SizedBox(width: 8),
            Text(
              'Update Contact Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your updated mobile number so clinic staff can reach you regarding appointment confirmations.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Mobile Contact Number',
                hintText: 'e.g. 0987-654-3210',
                prefixIcon: const Icon(Icons.call_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003B81),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newNum = controller.text.trim();
              if (newNum.isEmpty) return;
              Navigator.of(ctx).pop();
              if (onUpdateUser != null) {
                onUpdateUser!(user.copyWith(contactNumber: newNum));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contact number updated to $newNum!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Save Number'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out of DentiCare? You will need to sign in again to manage your appointments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onLogout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          'Patient Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _confirmLogout(context),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003B81), Color(0xFF0A58B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003B81).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor:
                              const Color(0xFF003B81).withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 44,
                            color: Color(0xFF003B81),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patient Portal ID: #DC-${user.id.hashCode.abs().toString().substring(0, 5)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '● ${user.status} Patient Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Section 1: Account Information
            Card(
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Credentials & Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF003B81),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Username',
                      value: '@${user.username}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: user.email,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact Number',
                      value: user.contactNumber,
                      trailing: InkWell(
                        onTap: () => _showEditContactDialog(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003B81).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit_outlined,
                                  size: 13, color: Color(0xFF003B81)),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003B81),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Account Role',
                      value: user.role,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Member Since',
                      value: user.registeredDate,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Accessibility & Display Preferences (HCI Requirement)
            Card(
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accessibility & Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF003B81),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Adjust interface settings for optimal comfort and readability.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(height: 20),

                    // Large Font Size Toggle (Figure 14 in HCI Report)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003B81).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.format_size_rounded,
                            color: Color(0xFF003B81), size: 22),
                      ),
                      title: const Text(
                        'Large Font Size',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Enlarges text for easier reading (Elderly & Student persona)',
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Switch(
                        value: isLargeFont,
                        activeThumbColor: const Color(0xFF003B81),
                        onChanged: onToggleLargeFont,
                      ),
                    ),

                    const Divider(height: 16),

                    // Dark Mode Toggle (Figure 13 in HCI Report)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003B81).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: const Color(0xFF003B81),
                          size: 22,
                        ),
                      ),
                      title: const Text(
                        'Dark Mode Theme',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Reduces screen glare and improves contrast',
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Switch(
                        value: isDarkMode,
                        activeThumbColor: const Color(0xFF003B81),
                        onChanged: onToggleDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 3: Help & DentiBot Quick Launch
            Card(
              elevation: 1.5,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Color(0xFF10B981)),
                ),
                title: const Text(
                  'Ask DentiBot Virtual Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Questions about clinic hours, pricing, or dentists',
                  style: TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const DentiBotDialog(),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF003B81)),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

