import 'package:flutter/material.dart';

class DentiBotDialog extends StatefulWidget {
  const DentiBotDialog({super.key});

  @override
  State<DentiBotDialog> createState() => _DentiBotDialogState();
}

class _DentiBotDialogState extends State<DentiBotDialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text':
          'Good morning! I am DentiBot, your virtual clinic assistant. How can I assist you with your appointment today?',
    },
  ];

  final List<String> _quickQuestions = [
    'How do I book an appointment?',
    'How much does Dental Bracing cost?',
    'What are the clinic hours?',
    'Can I choose any available dentist?',
  ];

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': query});
    });
    _messageController.clear();

    // Determine bot response
    String reply = '';
    final lower = query.toLowerCase();
    if (lower.contains('book') || lower.contains('how')) {
      reply =
          'To book an appointment, simply follow our 4-step wizard: Select your Service, pick a Dentist, choose an available Date/Time slot, review your Summary, and Confirm!';
    } else if (lower.contains('brac') || lower.contains('cost') || lower.contains('price')) {
      reply =
          'Dental Bracing ranges between P500.00 and P800.00 per consultation/adjustment. Routine cleaning starts from P600.00.';
    } else if (lower.contains('hour') || lower.contains('time')) {
      reply =
          'Our clinic is open Monday to Saturday from 8:00 AM to 7:00 PM. Urgent dental inquiries can call our emergency hotline.';
    } else if (lower.contains('dentist') || lower.contains('doctor')) {
      reply =
          'You can choose Dr. Grace Cabilles (Orthodontics), Dr. Joana Plewa (Pediatric Dentistry), Dr. Ryan Luza (Endodontics & Surgery), Dr. Niere Lupmac (Periodontics), or select "Any Available Dentist" for faster booking.';
    } else {
      reply =
          'Thank you for reaching out! You can follow the step-by-step guidance on your screen to proceed with your booking, or tap one of the suggested FAQs below.';
    }

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'bot', 'text': reply});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Bot Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF003B81),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Color(0xFF003B81),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DentiBot Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Online • Answers FAQs & booking help',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Message History
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isBot = msg['sender'] == 'bot';
                  return Align(
                    alignment:
                        isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: isBot
                            ? (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFEBF3FC))
                            : const Color(0xFF003B81),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isBot
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.white,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Quick Questions Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _quickQuestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return ActionChip(
                    label: Text(
                      _quickQuestions[i],
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: () => _sendMessage(_quickQuestions[i]),
                    backgroundColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Input Row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your question here...',
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF003B81),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

