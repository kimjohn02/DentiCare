import 'package:flutter/material.dart';
import '../models/dental_data.dart';
import '../widgets/dentibot_dialog.dart';
import '../widgets/settings_dialog.dart';

class BookingFlowScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool isLargeFont;
  final ValueChanged<bool> onToggleDarkMode;
  final ValueChanged<bool> onToggleLargeFont;
  final Function(AppointmentRecord) onAppointmentBooked;
  final List<DentalService>? services;
  final List<Dentist>? dentists;

  const BookingFlowScreen({
    super.key,
    required this.isDarkMode,
    required this.isLargeFont,
    required this.onToggleDarkMode,
    required this.onToggleLargeFont,
    required this.onAppointmentBooked,
    this.services,
    this.dentists,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0; // 0: Service, 1: Dentist, 2: Date/Time, 3: Summary

  // Booking Form State
  late DentalService _selectedService;
  late Dentist _selectedDentist;
  String _selectedDate = '09/11/2026';
  AppointmentSlot? _selectedSlot = DentalClinicData.availableSlots[0];

  @override
  void initState() {
    super.initState();
    final sList = widget.services ?? DentalClinicData.services;
    final dList = widget.dentists ?? DentalClinicData.dentists;
    _selectedService = sList.isNotEmpty ? sList[0] : DentalClinicData.services[0];
    _selectedDentist = dList.length > 1 ? dList[1] : dList[0];
  }

  // Patient Info State (Matches documented persona: Kim Macpao Lupogan)
  final TextEditingController _nameController =
      TextEditingController(text: 'Lupogan, Kim Macpao');
  final TextEditingController _contactController =
      TextEditingController(text: '0987654321');
  final TextEditingController _emailController =
      TextEditingController(text: 'kim@gmail.com');

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 2 && _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available appointment time slot.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _confirmAndSubmit() {
    // Validate inputs
    if (_nameController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all patient information fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newRecord = AppointmentRecord(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      patientName: _nameController.text.trim(),
      serviceName: _selectedService.name,
      dentistName: _selectedDentist.name,
      date: _selectedDate,
      time: _selectedSlot?.time ?? '8:00 AM',
      contact: _contactController.text.trim(),
      email: _emailController.text.trim(),
      status: 'Pending',
      notes: 'Submitted via Patient Booking Wizard',
    );

    widget.onAppointmentBooked(newRecord);

    // Show confirmation modal (Figure 12)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildConfirmationDialog(ctx),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Appointment has been submitted!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003B81),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your email or SMS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Confirmation sent to: ${_emailController.text.trim()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  setState(() {
                    _currentStep = 0; // Reset wizard to first step
                  });
                },
                child: const Text(
                  'Okay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.favorite,
                  color: Color(0xFF003B81),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DentiCare',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Accessibility / Settings Trigger (Figure 14)
          IconButton(
            tooltip: 'Accessibility & Font Settings',
            icon: const Icon(Icons.format_size_rounded),
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
          // Dark Mode Toggle Switch (Figure 8 & 13)
          Row(
            children: [
              const Text('Dark Mode', style: TextStyle(fontSize: 11)),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: widget.isDarkMode,
                  activeThumbColor: const Color(0xFF003B81),
                  onChanged: widget.onToggleDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Heading
            Text(
              'Appointment Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF003B81),
              ),
            ),
            const SizedBox(height: 12),

            // Stepper Progress Indicator (Figures 8, 9, 10, 11)
            _buildStepperHeader(),
            const SizedBox(height: 20),

            // Active Step Content
            if (_currentStep == 0) _buildStep0ServiceSelection(),
            if (_currentStep == 1) _buildStep1DentistSelection(),
            if (_currentStep == 2) _buildStep2DateTimeSelection(),
            if (_currentStep == 3) _buildStep3AppointmentSummary(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Stepper Header
  Widget _buildStepperHeader() {
    final steps = [
      'Select Service',
      'Select Dentist',
      'Select Date and Time',
      'Confirmation',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isSelected = _currentStep == index;
          final isCompleted = _currentStep > index;

          Color badgeColor;
          Color textColor;
          if (isCompleted) {
            badgeColor = const Color(0xFF10B981); // Green completed
            textColor = Colors.white;
          } else if (isSelected) {
            badgeColor = const Color(0xFFF59E0B); // Amber active
            textColor = Colors.white;
          } else {
            badgeColor = Colors.grey.shade300;
            textColor = Colors.black54;
          }

          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                Text(
                  steps[index],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: isSelected || isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // STEP 0: Dental Service Selection (Figure 8)
  Widget _buildStep0ServiceSelection() {
    final isDark = widget.isDarkMode;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Select a service',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DentalService>(
                        value: _selectedService,
                        isExpanded: true,
                        items: (widget.services ?? DentalClinicData.services)
                            .map((srv) {
                          return DropdownMenuItem<DentalService>(
                            value: srv,
                            child: Text(srv.name),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _selectedService = newVal;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Service Detail Card & Illustration
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedService.name} Description',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedService.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                            'Duration', _selectedService.duration),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailRow(
                            'Estimated Cost', _selectedService.cost),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Dental Service Real Treatment Photo Box (Matches Figure 8)
            Center(
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedService.imageAsset != null
                    ? Image.asset(
                        _selectedService.imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF003B81).withValues(alpha: 0.08),
                          child: Icon(
                            _selectedService.icon,
                            size: 54,
                            color: const Color(0xFF003B81),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF003B81).withValues(alpha: 0.08),
                        child: Icon(
                          _selectedService.icon,
                          size: 54,
                          color: const Color(0xFF003B81),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B81),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _nextStep,
                icon: const Text('Next'),
                label: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Dentist Selection (Polished Specialist Profile)
  Widget _buildStep1DentistSelection() {
    final isDark = widget.isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Select a dentist',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Dentist>(
                        value: _selectedDentist,
                        isExpanded: true,
                        items: (widget.dentists ?? DentalClinicData.dentists)
                            .map((dentist) {
                          return DropdownMenuItem<Dentist>(
                            value: dentist,
                            child: Row(
                              children: [
                                if (dentist.imageAsset != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      dentist.imageAsset!,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Icon(dentist.avatarIcon,
                                      size: 20, color: const Color(0xFF003B81)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dentist.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _selectedDentist = newVal;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Dentist Specialist Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Header with Avatar & Verified Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 76,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF003B81), Color(0xFF2563EB)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF003B81)
                                      .withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _selectedDentist.imageAsset != null
                                ? Image.asset(
                                    _selectedDentist.imageAsset!,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(
                                      _selectedDentist.avatarIcon,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  )
                                : Icon(
                                    _selectedDentist.avatarIcon,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedDentist.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003B81),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDentist.id == 'any'
                                  ? 'Assigned On Clinic Duty'
                                  : 'Doctor of Dental Medicine (DMD)',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 16, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                const Text(
                                  '4.9',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• 120+ clinical visits',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Key Metrics Strip (Experience & License)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF003B81)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.work_history_rounded,
                                    size: 15, color: Color(0xFF003B81)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Experience',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      _selectedDentist.experience,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.verified_user_rounded,
                                    size: 15, color: Color(0xFF10B981)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Certification',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const Text(
                                      'PRC Certified',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Specialization Pills
                  Text(
                    'SPECIALIZATIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedDentist.specialization
                        .split('\n')
                        .map((spec) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003B81)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF003B81)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      size: 12, color: Color(0xFF003B81)),
                                  const SizedBox(width: 5),
                                  Text(
                                    spec.trim(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003B81),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  // Qualifications & Credentials
                  Text(
                    'CREDENTIALS & AFFILIATIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.military_tech_rounded,
                            size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDentist.qualification
                                .replaceAll('\n', ' • '),
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey.shade200
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Navigation Buttons (Back & Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _prevStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: const Text('Next'),
                  label: const Icon(Icons.arrow_forward_rounded, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B81),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Time and Date Selection (Figure 10)
  Widget _buildStep2DateTimeSelection() {
    final isDark = widget.isDarkMode;

    // Filter available slots by chosen dentist if a specific dentist is picked
    final filteredSlots = _selectedDentist.id == 'any'
        ? DentalClinicData.availableSlots
        : DentalClinicData.availableSlots
            .where((s) => s.dentistName == _selectedDentist.name)
            .toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time and Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Date Picker Row & Selected Chips
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text('Date: $_selectedDate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B81),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate =
                            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                      });
                    }
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Time Selected: ${_selectedSlot?.time ?? 'None'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF003B81),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Available Slots Table (Matches Figure 10)
            const Text(
              'Available Schedules',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            if (filteredSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No open slots for ${_selectedDentist.name} on this date.\nTry selecting "Any Available Dentist".',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.8),
                    3: FlexColumnWidth(1.8),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B81),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(9),
                          topRight: Radius.circular(9),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Dentist',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Date',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Time',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Action',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    // Data Rows
                    ...filteredSlots.map((slot) {
                      final isChosen = _selectedSlot?.id == slot.id;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isChosen
                              ? const Color(0xFFDCFCE7)
                              : Colors.transparent,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(slot.dentistName,
                                style: const TextStyle(fontSize: 11)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(slot.date,
                                style: const TextStyle(fontSize: 11)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(slot.time,
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isChosen
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                minimumSize: const Size(50, 32),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedSlot = slot;
                                });
                              },
                              child: Text(
                                isChosen ? 'Selected' : 'Select',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Navigation Buttons (Back & Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _prevStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: const Text('Next'),
                  label: const Icon(Icons.arrow_forward_rounded, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B81),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: Appointment Summary & Validation (Polished Digital Pass)
  Widget _buildStep3AppointmentSummary() {
    final isDark = widget.isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header with Icon Badge
            Center(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003B81).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Color(0xFF003B81),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appointment Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B81),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please review your booking details before confirming.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // SECTION 1: Schedule & Treatment
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_available_rounded,
                          size: 16, color: Color(0xFF003B81)),
                      const SizedBox(width: 6),
                      Text(
                        'SCHEDULE & TREATMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Service Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF003B81).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF003B81).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_selectedService.icon,
                                size: 14, color: const Color(0xFF003B81)),
                            const SizedBox(width: 5),
                            Text(
                              _selectedService.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003B81),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Dentist Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dentist:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _selectedDentist.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 10),
                  // Date & Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date & Time:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(text: '$_selectedDate  •  '),
                              TextSpan(
                                text: _selectedSlot?.time ?? '8:00 AM',
                                style: const TextStyle(
                                  color: Color(0xFF003B81),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SECTION 2: Patient Information
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded,
                              size: 16, color: Color(0xFF003B81)),
                          const SizedBox(width: 6),
                          Text(
                            'PATIENT INFORMATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _showEditPatientDetailsDialog,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  size: 13, color: Color(0xFFF59E0B)),
                              SizedBox(width: 3),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCleanReviewRow(
                    Icons.person_outline_rounded,
                    'Name:',
                    _nameController.text.trim().isEmpty
                        ? 'Lupogan, Kim Macpao'
                        : _nameController.text.trim(),
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildCleanReviewRow(
                    Icons.phone_outlined,
                    'Contact:',
                    _contactController.text.trim().isEmpty
                        ? '0987654321'
                        : _contactController.text.trim(),
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildCleanReviewRow(
                    Icons.mail_outline_rounded,
                    'Email:',
                    _emailController.text.trim().isEmpty
                        ? 'kim@gmail.com'
                        : _emailController.text.trim(),
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SECTION 3: Estimated Cost & Notice Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A2F)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Fee: ${_selectedService.cost}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Payment will be settled upon arrival at the clinic reception.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons (Outlined Edit Details + Elevated Confirm)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit_note_rounded,
                        color: Color(0xFFF59E0B)),
                    label: Text(
                      'Edit Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Green Confirm
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text(
                      'Confirm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: _confirmAndSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPatientDetailsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Color(0xFF003B81)),
              SizedBox(width: 8),
              Text(
                'Edit Patient Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003B81),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003B81),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCleanReviewRow(
      IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003B81))),
        ],
      ),
    );
  }

  Widget _buildDentistInfoLine(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

