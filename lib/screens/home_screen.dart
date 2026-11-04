import 'package:flutter/material.dart';
import '../models/dental_data.dart';
import '../widgets/dentibot_dialog.dart';
import '../widgets/settings_dialog.dart';

class DentiCareMainHomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToBooking;
  final VoidCallback onNavigateToAppointments;
  final VoidCallback onNavigateToAuth;
  final bool isLargeFont;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleLargeFont;
  final ValueChanged<bool> onToggleDarkMode;

  const DentiCareMainHomeScreen({
    super.key,
    required this.onNavigateToBooking,
    required this.onNavigateToAppointments,
    required this.onNavigateToAuth,
    required this.isLargeFont,
    required this.isDarkMode,
    required this.onToggleLargeFont,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF003B81),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Accessibility / Text Size',
            icon: const Icon(Icons.format_size_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => SettingsDialog(
                  isLargeFont: isLargeFont,
                  isDarkMode: isDarkMode,
                  onToggleLargeFont: onToggleLargeFont,
                  onToggleDarkMode: onToggleDarkMode,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Sign In / Account',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: onNavigateToAuth,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner (Matches Figures 1, 4, 5)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003B81), Color(0xFF0B63D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003B81).withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DentiCare',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Book with ease',
                    style: TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'DentiCare provides trusted dental services focused on comfort, quality, and patient well-being. We are dedicated to helping you maintain a healthy smile through professional and personalized care.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // "Book Now!" Yellow CTA Button (Figure 1 & 4 & 5)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B), // Warm amber/yellow
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: onNavigateToBooking,
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: const Text(
                      'Book Now!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Links / Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'Schedule Visit',
                    subtitle: 'Choose service & doctor',
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: onNavigateToBooking,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    context,
                    title: 'My Bookings',
                    subtitle: 'View active appointments',
                    icon: Icons.list_alt_rounded,
                    color: const Color(0xFF10B981),
                    onTap: onNavigateToAppointments,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Clinical Dental Services Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Dental Treatments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: onNavigateToBooking,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...DentalClinicData.services.map((srv) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF003B81).withValues(alpha: 0.1),
                    child: Icon(srv.icon, color: const Color(0xFF003B81)),
                  ),
                  title: Text(
                    srv.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${srv.duration} • Estimated: ${srv.cost}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003B81),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                    ),
                    onPressed: onNavigateToBooking,
                    child: const Text('Select', style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            }),

            const SizedBox(height: 18),

            // DentiBot Assistant Banner (Figure 15)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF10B981),
                    child: Icon(Icons.smart_toy_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help Booking?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Chat with DentiBot for clinic guidelines & FAQs.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const DentiBotDialog(),
                      );
                    },
                    child: const Text('Ask DentiBot'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 18,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

