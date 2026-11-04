import 'package:flutter/material.dart';
import '../models/dental_data.dart';

class AppointmentsListScreen extends StatefulWidget {
  final List<AppointmentRecord> appointments;
  final VoidCallback onNavigateToBook;
  final Function(String appointmentId) onCancelAppointment;

  const AppointmentsListScreen({
    super.key,
    required this.appointments,
    required this.onNavigateToBook,
    required this.onCancelAppointment,
  });

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final confirmed =
        widget.appointments.where((a) => a.status == 'Confirmed').toList();
    final cancelled =
        widget.appointments.where((a) => a.status == 'Cancelled').toList();
    final completed =
        widget.appointments.where((a) => a.status == 'Completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF003B81),
          indicatorColor: const Color(0xFF003B81),
          tabs: [
            Tab(text: 'Upcoming (${confirmed.length})'),
            Tab(text: 'History (${completed.length})'),
            Tab(text: 'Cancelled (${cancelled.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList(confirmed, isUpcoming: true),
          _buildAppointmentList(completed, isUpcoming: false),
          _buildAppointmentList(cancelled, isUpcoming: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF003B81),
        foregroundColor: Colors.white,
        onPressed: widget.onNavigateToBook,
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentRecord> list,
      {required bool isUpcoming}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No appointments found in this category',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (isUpcoming) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: widget.onNavigateToBook,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Schedule Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B81),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final apt = list[index];
        final isConfirmed = apt.status == 'Confirmed';

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
                    Expanded(
                      child: Text(
                        apt.serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003B81),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? const Color(0xFFDCFCE7)
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        apt.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isConfirmed
                              ? const Color(0xFF166534)
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(apt.dentistName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('${apt.date} at ${apt.time}'),
                  ],
                ),
                if (isUpcoming) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Reschedule'),
                        onPressed: widget.onNavigateToBook,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.cancel_outlined,
                            size: 16, color: Colors.red),
                        label: const Text('Cancel',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _showCancelDialog(context, apt.id);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, String aptId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
            'Are you sure you want to cancel this scheduled appointment? You will be able to rebook at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.onCancelAppointment(aptId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }
}

