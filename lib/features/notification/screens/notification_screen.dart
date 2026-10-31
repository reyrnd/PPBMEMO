import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data tiruan notifikasi masuk berdasarkan struktur data di berkas TSX
    final notifications = [
      {
        'icon': Icons.people_alt_rounded,
        'title': 'Workspace invitation',
        'text': 'Raka invited you to join Brand Sprint.',
        'time': '2m',
        'unread': true,
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'title': 'New reply',
        'text': 'Jade replied to your comment in Launch plan.',
        'time': '1h',
        'unread': true,
      },
      {
        'icon': Icons.check_circle_outline_rounded,
        'title': 'Task completed',
        'text': 'Ardi completed Update style guide.',
        'time': '3h',
        'unread': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header – rounded back button matching App.tsx DetailHeader
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Material(
                    color: AppTheme.whiteBackgroundField,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [AppTheme.shadowSoft],
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppTheme.ink, size: 19),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppTheme.ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 4.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final bool isUnread = item['unread'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.whiteBackgroundField,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppTheme.shadowSoft],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Kotak Ikon Kategori Notifikasi
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: AppTheme.muted,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 2. Konten Teks Notifikasi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['text'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 3. Indikator Waktu & Dot Bulat Unread (Caramel Color)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item['time'] as String,
                              style: const TextStyle(
                                  fontSize: 9, color: AppTheme.faint),
                            ),
                            const SizedBox(height: 12),
                            if (isUnread)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.caramel,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}