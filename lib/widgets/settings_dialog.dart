import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  final bool isLargeFont;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleLargeFont;
  final ValueChanged<bool> onToggleDarkMode;

  const SettingsDialog({
    super.key,
    required this.isLargeFont,
    required this.isDarkMode,
    required this.onToggleLargeFont,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune_rounded, color: Color(0xFF003B81)),
                      SizedBox(width: 10),
                      Text(
                        'Display & Accessibility',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Large Font Option (Figure 14 in HCI Report)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.format_size_rounded,
                      color: Color(0xFF003B81)),
                ),
                title: const Text(
                  'Large Font Size',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Enlarge interface text for easier reading',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Switch(
                  value: isLargeFont,
                  activeThumbColor: const Color(0xFF003B81),
                  onChanged: (val) {
                    onToggleLargeFont(val);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Dark Mode Option (Figure 13 in HCI Report)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003B81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFF003B81),
                  ),
                ),
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Reduce glare and improve contrast',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  activeThumbColor: const Color(0xFF003B81),
                  onChanged: (val) {
                    onToggleDarkMode(val);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Close / Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B81),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Apply & Close',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

