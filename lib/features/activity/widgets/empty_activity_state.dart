// lib/core/widgets/empty_activity_state.dart
import 'package:flutter/material.dart';
import 'package:memospace/core/widgets/empty_state.dart';

class EmptyActivityState extends StatelessWidget {
  const EmptyActivityState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.stacked_line_chart,
      title: 'Belum ada aktivitas',
      caption:
          'Semua pembaruan catatan, komentar, dan progres tugas tim akan muncul di sini.',
    );
  }
}
