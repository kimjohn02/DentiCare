import 'package:flutter/material.dart';
import '../models/dental_data.dart';

class AdminScreen extends StatefulWidget {
  final List<UserAccount> users;
  final List<DentalService> services;
  final List<Dentist> dentists;
  final List<AppointmentRecord> appointments;
  final Function(UserAccount) onAddUser;
  final Function(String userId, String newStatus) onToggleUserStatus;
  final Function(DentalService) onAddService;
  final Function(DentalService) onUpdateService;
  final Function(Dentist) onAddDentist;
  final VoidCallback? onLogout;

  const AdminScreen({
    super.key,
    required this.users,
    required this.services,
    required this.dentists,
    required this.appointments,
    required this.onAddUser,
    required this.onToggleUserStatus,
    required this.onAddService,
    required this.onUpdateService,
    required this.onAddDentist,
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
    super.dispose();
  }

  // Add User / Staff Dialog
  void _showAddUserDialog() {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String roleVal = 'Clinic Staff';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.person_add_rounded, color: Color(0xFF003B81)),
                SizedBox(width: 8),
                Text('Create New Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: roleVal,
                      decoration: const InputDecoration(labelText: 'Assigned Role'),
                      items: ['Patient', 'Clinic Staff', 'Administrator']
                          .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => roleVal = v);
                      },
                    ),
                  ],
                ),
              ),
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
                  if (usernameCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                  final newUser = UserAccount(
                    id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                    username: usernameCtrl.text.trim(),
                    fullName: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty
                        ? '${usernameCtrl.text.trim()}@denticare.clinic'
                        : emailCtrl.text.trim(),
                    contactNumber: '0917-000-0000',
                    role: roleVal,
                    status: 'Active',
                    registeredDate: '11/04/2026',
                  );
                  widget.onAddUser(newUser);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Account for ${newUser.fullName} created!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Create User'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Add Service Dialog
  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '1 hour');
    final costCtrl = TextEditingController(text: 'P500.00 - P1,000.00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.add_business_rounded, color: Color(0xFF003B81)),
            SizedBox(width: 8),
            Text('Add Dental Procedure',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Procedure Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: durationCtrl,
                  decoration: const InputDecoration(labelText: 'Estimated Duration'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: costCtrl,
                  decoration: const InputDecoration(labelText: 'Price Range (PHP)'),
                ),
              ],
            ),
          ),
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
              if (nameCtrl.text.isEmpty) return;
              final newSrv = DentalService(
                id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                duration: durationCtrl.text.trim(),
                cost: costCtrl.text.trim(),
                icon: Icons.medical_services_rounded,
              );
              widget.onAddService(newSrv);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service "${newSrv.name}" added to clinic catalog!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Save Service'),
          ),
        ],
      ),
    );
  }

  // Add Dentist Dialog
  void _showAddDentistDialog() {
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController(text: '5 years of experience');
    final specCtrl = TextEditingController(text: 'General Dentistry\nPediatric Dentistry');
    final qualCtrl = TextEditingController(text: 'Doctor of Dental Medicine (DMD)');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.badge_rounded, color: Color(0xFF003B81)),
            SizedBox(width: 8),
            Text('Register Doctor to Roster',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Doctor Name (e.g. Dr. Jane Doe)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expCtrl,
                  decoration: const InputDecoration(labelText: 'Years of Experience'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: specCtrl,
                  decoration: const InputDecoration(labelText: 'Specializations'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: qualCtrl,
                  decoration: const InputDecoration(labelText: 'Degrees / Qualifications'),
                ),
              ],
            ),
          ),
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
            child: const Text('Add Dentist'),
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
          if (widget.onLogout != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
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

    return Column(
      children: [
        // Controls Header
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search username, full name, or email...',
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (v) => setState(() => _userSearchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedRoleFilter,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Role',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: ['All', 'Patient', 'Clinic Staff', 'Administrator']
                          .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedRoleFilter = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B81),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Account / Staff'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // User List
        Expanded(
          child: filteredUsers.isEmpty
              ? const Center(
                  child: Text('No user accounts found matching query.',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, i) {
                    final u = filteredUsers[i];
                    final isActive = u.status == 'Active';

                    Color roleColor = Colors.blue;
                    if (u.role == 'Administrator') roleColor = Colors.purple;
                    if (u.role == 'Clinic Staff') roleColor = const Color(0xFF10B981);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleColor.withValues(alpha: 0.15),
                          child: Icon(
                            u.role == 'Administrator'
                                ? Icons.admin_panel_settings
                                : (u.role == 'Clinic Staff'
                                    ? Icons.badge
                                    : Icons.person),
                            color: roleColor,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(u.fullName,
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u.role,
                                style: TextStyle(
                                    color: roleColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                            '@${u.username} • ${u.email} • 📞 ${u.contactNumber}\nRegistered: ${u.registeredDate} • Status: ${u.status}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'toggle') {
                              widget.onToggleUserStatus(
                                  u.id, isActive ? 'Suspended' : 'Active');
                            } else if (action == 'reset') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Password reset link dispatched to ${u.email}'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(isActive
                                  ? 'Suspend Account'
                                  : 'Activate Account'),
                            ),
                            const PopupMenuItem(
                              value: 'reset',
                              child: Text('Reset Password'),
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
  // TAB 2: DENTAL SERVICES CATALOG
  // -------------------------------------------------------------
  Widget _buildServicesCatalogTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Clinical Services & Pricing List',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                ),
                onPressed: _showAddServiceDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Procedure'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: widget.services.length,
            itemBuilder: (context, i) {
              final srv = widget.services[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (srv.imageAsset != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    srv.imageAsset!,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Icon(srv.icon,
                                        color: const Color(0xFF003B81),
                                        size: 24),
                                  ),
                                )
                              else
                                Icon(srv.icon,
                                    color: const Color(0xFF003B81), size: 24),
                              const SizedBox(width: 10),
                              Text(
                                srv.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(height: 8),
                      Text(srv.description,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Duration: ${srv.duration}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Clinic Doctors',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                ),
                onPressed: _showAddDentistDialog,
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add Doctor'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: widget.dentists.length,
            itemBuilder: (context, i) {
              final doc = widget.dentists[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF003B81).withValues(alpha: 0.12),
                    child: Icon(doc.avatarIcon, color: const Color(0xFF003B81)),
                  ),
                  title: Text(doc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${doc.experience}\nSpecialization: ${doc.specialization.replaceAll('\n', ', ')}\nDegree: ${doc.qualification.replaceAll('\n', ', ')}'),
                  isThreeLine: true,
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

          // 2 Metrics Cards in each line (Icon Left, Text Center, Value Right)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                    'Total Bookings',
                    '$totalBookings',
                    Icons.calendar_month_rounded,
                    const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                    'Registered Users',
                    '${widget.users.length}',
                    Icons.people_rounded,
                    const Color(0xFF10B981)),
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
                    Colors.purple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                    'Cancellation Rate',
                    '$cancelRate%',
                    Icons.trending_down_rounded,
                    Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Breakdown Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Appointments Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  _buildProgressRow(
                      'Confirmed Schedule', confirmedCount, totalBookings,
                      const Color(0xFF10B981)),
                  const SizedBox(height: 10),
                  _buildProgressRow(
                      'In Treatment / Chair', inTreatmentCount, totalBookings,
                      const Color(0xFF2563EB)),
                  const SizedBox(height: 10),
                  _buildProgressRow(
                      'Completed Procedures', completedCount, totalBookings,
                      Colors.purple),
                  const SizedBox(height: 10),
                  _buildProgressRow(
                      'Cancelled Visits', cancelledCount, totalBookings,
                      Colors.red),
                ],
              ),
            ),
          ),
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
      String title, String value, IconData icon, Color color) {
    return Container(
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
            Text('$count ($total)',
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

