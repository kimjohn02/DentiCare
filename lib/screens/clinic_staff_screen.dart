import 'package:flutter/material.dart';
import '../models/dental_data.dart';

class ClinicStaffScreen extends StatefulWidget {
  final List<AppointmentRecord> appointments;
  final Function(AppointmentRecord) onAddAppointment;
  final Function(String id, String newStatus, {String? notes})
      onUpdateAppointmentStatus;
  final VoidCallback? onLogout;

  const ClinicStaffScreen({
    super.key,
    required this.appointments,
    required this.onAddAppointment,
    required this.onUpdateAppointmentStatus,
    this.onLogout,
  });

  @override
  State<ClinicStaffScreen> createState() => _ClinicStaffScreenState();
}

class _ClinicStaffScreenState extends State<ClinicStaffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Schedule Filters
  String _selectedDoctorFilter = 'All Dentists';
  String _selectedStatusFilter = 'All';
  final String _scheduleDate = '09/11/2026';

  // Patient Records Search
  String _patientSearchQuery = '';
  final List<PatientProfile> _patients = List.from(DentalClinicData.samplePatients);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Quick Walk-In Booking Dialog
  void _showWalkInDialog() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    DentalService selectedSrv = DentalClinicData.services[0];
    Dentist selectedDoc = DentalClinicData.dentists[1];
    String dateStr = _scheduleDate;
    String timeStr = '11:30 AM';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.person_add_alt_1_rounded,
                    color: Color(0xFF003B81)),
                SizedBox(width: 10),
                Text('New Walk-In Booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Patient Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contactCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<DentalService>(
                      initialValue: selectedSrv,
                      decoration: const InputDecoration(labelText: 'Dental Service'),
                      items: DentalClinicData.services.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.name, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSrv = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<Dentist>(
                      initialValue: selectedDoc,
                      decoration: const InputDecoration(labelText: 'Assigned Dentist'),
                      items: DentalClinicData.dentists.map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text(d.name, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDoc = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: dateStr,
                            decoration: const InputDecoration(labelText: 'Date'),
                            onChanged: (v) => dateStr = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: timeStr,
                            decoration: const InputDecoration(labelText: 'Time'),
                            onChanged: (v) => timeStr = v,
                          ),
                        ),
                      ],
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
                  if (nameCtrl.text.trim().isEmpty) return;
                  final walkInApt = AppointmentRecord(
                    id: 'walkin_${DateTime.now().millisecondsSinceEpoch}',
                    patientName: nameCtrl.text.trim(),
                    serviceName: selectedSrv.name,
                    dentistName: selectedDoc.name,
                    date: dateStr,
                    time: timeStr,
                    contact: contactCtrl.text.trim().isEmpty
                        ? 'Walk-in'
                        : contactCtrl.text.trim(),
                    email: 'walkin@clinic.local',
                    status: 'Confirmed',
                    notes: 'Registered as clinic walk-in by Staff',
                  );
                  widget.onAddAppointment(walkInApt);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Walk-in patient added to schedule!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Book & Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        widget.appointments.where((a) => a.status == 'Pending').length;
    final confirmedCount =
        widget.appointments.where((a) => a.status == 'Confirmed').length;
    final inTreatmentCount =
        widget.appointments.where((a) => a.status == 'In Treatment').length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Clinic Staff Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'DentiCare Administrative Desk',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Log Out of Staff Portal',
              onPressed: widget.onLogout,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF003B81),
          indicatorColor: const Color(0xFF003B81),
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.inbox_rounded),
              ),
              text: 'Approval Queue ($pendingCount)',
            ),
            Tab(
              icon: const Icon(Icons.calendar_month_rounded),
              text: 'Daily Schedule',
            ),
            Tab(
              icon: const Icon(Icons.folder_shared_rounded),
              text: 'Patient Records',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // KPI Quick Metrics Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFEFF6FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricChip(
                    'Pending Review', '$pendingCount', const Color(0xFFF59E0B)),
                _buildMetricChip(
                    'Confirmed Visits', '$confirmedCount', const Color(0xFF10B981)),
                _buildMetricChip(
                    'In Chair Now', '$inTreatmentCount', const Color(0xFF2563EB)),
              ],
            ),
          ),

          // Main Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildApprovalQueueTab(),
                _buildDailyScheduleTab(),
                _buildPatientRecordsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF003B81),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Walk-in Patient'),
        onPressed: _showWalkInDialog,
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 1: PENDING APPROVAL QUEUE
  // -------------------------------------------------------------
  Widget _buildApprovalQueueTab() {
    final pendingList =
        widget.appointments.where((a) => a.status == 'Pending').toList();

    if (pendingList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_outline_rounded,
                  size: 64, color: Color(0xFF10B981)),
              SizedBox(height: 16),
              Text(
                'Queue is Clear!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'No pending online appointment requests awaiting staff approval.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingList.length,
      itemBuilder: (context, index) {
        final apt = pendingList[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      apt.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003B81),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Awaiting Approval',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Service: ${apt.serviceName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Requested Dentist: ${apt.dentistName}',
                    style: const TextStyle(color: Colors.black87)),
                Text('Slot: ${apt.date} at ${apt.time}',
                    style: const TextStyle(color: Colors.black87)),
                Text('Contact: ${apt.contact} • ${apt.email}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),

                // Approval Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Decline'),
                      onPressed: () {
                        widget.onUpdateAppointmentStatus(
                            apt.id, 'Cancelled',
                            notes: 'Declined by clinic staff');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appointment request declined.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve & Confirm'),
                      onPressed: () {
                        widget.onUpdateAppointmentStatus(
                            apt.id, 'Confirmed',
                            notes: 'Approved by desk receptionist');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Appointment approved! Patient notified via SMS/Email.'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 2: DAILY SCHEDULE & CLINIC QUEUE
  // -------------------------------------------------------------
  Widget _buildDailyScheduleTab() {
    // Filter appointments
    final filtered = widget.appointments.where((a) {
      if (_selectedDoctorFilter != 'All Dentists' &&
          a.dentistName != _selectedDoctorFilter) {
        return false;
      }
      if (_selectedStatusFilter != 'All' &&
          a.status != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filter Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDoctorFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Doctor',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        'All Dentists',
                        'Dr. Michaela Jordan',
                        'Dr. Nathaniel Cruz',
                        'Any Available Dentist',
                      ]
                          .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d,
                                  style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDoctorFilter = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter Status',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        'All',
                        'Pending',
                        'Confirmed',
                        'In Treatment',
                        'Completed',
                        'Cancelled',
                      ]
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatusFilter = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Filtered Schedule List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No appointments match current filters.',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final apt = filtered[i];

                    Color statusColor = Colors.grey;
                    if (apt.status == 'Pending') statusColor = const Color(0xFFF59E0B);
                    if (apt.status == 'Confirmed') statusColor = const Color(0xFF10B981);
                    if (apt.status == 'In Treatment') statusColor = const Color(0xFF2563EB);
                    if (apt.status == 'Completed') statusColor = Colors.purple;
                    if (apt.status == 'Cancelled') statusColor = Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 16, color: Color(0xFF003B81)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${apt.time} • ${apt.date}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    apt.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              apt.patientName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text('${apt.serviceName} | Doctor: ${apt.dentistName}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            if (apt.notes != null) ...[
                              const SizedBox(height: 4),
                              Text('Notes: ${apt.notes}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic)),
                            ],
                            const Divider(height: 16),

                            // Queue Progression Flow Buttons
                            Wrap(
                              spacing: 8,
                              children: [
                                if (apt.status == 'Confirmed')
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.chair_alt_rounded,
                                        size: 14),
                                    label: const Text('Call to Chair',
                                        style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      widget.onUpdateAppointmentStatus(
                                          apt.id, 'In Treatment');
                                    },
                                  ),
                                if (apt.status == 'In Treatment')
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.check_circle,
                                        size: 14),
                                    label: const Text('Finish Procedure',
                                        style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      widget.onUpdateAppointmentStatus(
                                          apt.id, 'Completed');
                                    },
                                  ),
                                TextButton.icon(
                                  icon: const Icon(Icons.note_add_outlined,
                                      size: 14),
                                  label: const Text('Add Note',
                                      style: TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    _showAddNoteDialog(context, apt.id);
                                  },
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

  void _showAddNoteDialog(BuildContext context, String aptId) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Treatment / Clinic Note'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter clinical note (e.g. Tooth #14 cavity filling completed)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteCtrl.text.isNotEmpty) {
                widget.onUpdateAppointmentStatus(aptId, 'Confirmed',
                    notes: noteCtrl.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: PATIENT DIRECTORY & CHARTS
  // -------------------------------------------------------------
  Widget _buildPatientRecordsTab() {
    final filteredPatients = _patients.where((p) {
      final q = _patientSearchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.contact.contains(q);
    }).toList();

    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.all(14),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search patients by name or contact number...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (val) {
              setState(() {
                _patientSearchQuery = val;
              });
            },
          ),
        ),

        // Patient Cards List
        Expanded(
          child: filteredPatients.isEmpty
              ? const Center(
                  child: Text('No patient records found matching query.',
                      style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, i) {
                    final patient = filteredPatients[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFF003B81).withValues(alpha: 0.1),
                          child: const Icon(Icons.person,
                              color: Color(0xFF003B81)),
                        ),
                        title: Text(patient.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'DOB: ${patient.birthday} • Sex: ${patient.sex} • Blood: ${patient.bloodType}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(patient.contact),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(patient.email),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          color: Colors.red, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Allergies / Flags: ${patient.allergies}',
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Treatment History & Procedures:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                ...patient.treatmentHistory.map((t) => Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check,
                                              size: 14,
                                              color: Color(0xFF10B981)),
                                          const SizedBox(width: 6),
                                          Text(t,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

