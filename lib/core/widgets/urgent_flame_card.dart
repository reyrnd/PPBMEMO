import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../features/memo/models/memo.dart';

/// Status efek visual kartu memo di Kanban, Canvas, maupun Home
enum MemoCardVisualState {
  normal,
  completedFresh, // Selesai -> efek adem & segar (hijau mint/emerald beranimasi)
  warningYellow,  // Jarak 2-3 hari sebelum deadline -> warning kuning beranimasi
  urgentFire,     // H-1 (besok), Hari ini, atau Terlewat (overdue) -> efek api merah Discord Nitro
}

class UrgentFlameHelper {
  /// Menghitung selisih hari dari hari ini ke dueDate (negatif jika sudah lewat)
  static int? daysUntilDue(String rawDate) {
    final trimmed = rawDate.trim();
    if (trimmed.isEmpty) return null;
    final target = DateTime.tryParse(trimmed);
    if (target == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(target.year, target.month, target.day);
    return dueDay.difference(today).inDays;
  }

  /// Menentukan state visual kartu memo:
  /// - Jika selesai ('done' atau progress >= 1.0) -> completedFresh (Adem & Segar)
  /// - Jika belum selesai & dueDate <= 1 hari (Hari ini, Besok, atau Lewat) -> urgentFire (Api Merah)
  /// - Jika belum selesai & dueDate 2 s/d 3 hari lagi -> warningYellow (Warning Kuning Beranimasi)
  /// - Selain itu -> normal
  static MemoCardVisualState getVisualState(
    Memo memo, {
    String? overrideStatus,
  }) {
    final status = (overrideStatus ?? memo.status).toLowerCase();
    final isDone = status == 'done' ||
        (memo.progress != null && memo.progress! >= 1.0 && memo.checklist.isNotEmpty);
    if (isDone) {
      return MemoCardVisualState.completedFresh;
    }

    final diffDays = daysUntilDue(memo.dueDate);
    if (diffDays == null) return MemoCardVisualState.normal;

    if (diffDays <= 1) {
      return MemoCardVisualState.urgentFire;
    } else if (diffDays <= 3) {
      return MemoCardVisualState.warningYellow;
    }
    return MemoCardVisualState.normal;
  }

  /// True jika tugas belum selesai dan due date sudah dekat (<= 3 hari: baik fire maupun warning kuning)
  static bool isApproachingOrOverdue(Memo memo, {String? overrideStatus}) {
    final state = getVisualState(memo, overrideStatus: overrideStatus);
    return state == MemoCardVisualState.urgentFire ||
        state == MemoCardVisualState.warningYellow;
  }

  /// Kompatibilitas dengan kode pemanggil sebelumnya
  static bool isUrgent(Memo memo, {String? overrideStatus}) {
    return getVisualState(memo, overrideStatus: overrideStatus) ==
        MemoCardVisualState.urgentFire;
  }

  /// Label status untuk ditampilkan pada badge kartu
  static String statusLabel(Memo memo, {String? overrideStatus}) {
    final state = getVisualState(memo, overrideStatus: overrideStatus);
    if (state == MemoCardVisualState.completedFresh) {
      return 'SELESAI · TUNTAS';
    }

    final diffDays = daysUntilDue(memo.dueDate);
    if (diffDays == null) return 'DEADLINE DEKAT';

    if (diffDays < 0) {
      return 'TERLEWAT (${diffDays.abs()} HARI)';
    } else if (diffDays == 0) {
      return 'DEADLINE HARI INI!';
    } else if (diffDays == 1) {
      return 'BESOK (1 HARI LAGI)';
    } else {
      return 'WARNING · $diffDays HARI LAGI';
    }
  }
}

/// Container kartu beranimasi yang otomatis menyesuaikan efek:
/// - [MemoCardVisualState.urgentFire]: Efek api merah-emas menyala ala Discord Nitro
/// - [MemoCardVisualState.warningYellow]: Efek warning kuning-amber berdenyut dengan kilau cahaya
/// - [MemoCardVisualState.completedFresh]: Efek adem & segar hijau emerald-mint dengan gelembung sejuk
class UrgentFlameCard extends StatefulWidget {
  final Widget child;
  final MemoCardVisualState visualState;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const UrgentFlameCard({
    super.key,
    required this.child,
    this.visualState = MemoCardVisualState.urgentFire,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.width,
  });

  @override
  State<UrgentFlameCard> createState() => _UrgentFlameCardState();
}

class _UrgentFlameCardState extends State<UrgentFlameCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;
        final pulse = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);

        switch (widget.visualState) {
          case MemoCardVisualState.completedFresh:
            return _buildFreshCalmContainer(phase, pulse, child!);
          case MemoCardVisualState.warningYellow:
            return _buildWarningYellowContainer(phase, pulse, child!);
          case MemoCardVisualState.urgentFire:
          case MemoCardVisualState.normal:
            return _buildFireContainer(phase, pulse, child!);
        }
      },
      child: widget.child,
    );
  }

  Widget _buildFireContainer(double phase, double pulse, Widget child) {
    return Container(
      width: widget.width,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B070B), // Deep nitro obsidian crimson
            Color(0xFF7F1D1D), // Rich ruby red
            Color(0xFFB91C1C), // Flame crimson
            Color(0xFFEA580C), // Blazing ember orange
          ],
          stops: [0.0, 0.42, 0.78, 1.0],
        ),
        border: Border.all(
          color: Color.lerp(
            const Color(0xFFF97316),
            const Color(0xFFFACC15),
            pulse,
          )!,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444)
                .withValues(alpha: 0.28 + 0.16 * pulse),
            blurRadius: 16 + 6 * pulse,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DiscordFlamePainter(phase: phase),
              ),
            ),
            Padding(
              padding: widget.padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningYellowContainer(double phase, double pulse, Widget child) {
    return Container(
      width: widget.width,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFBEB), // Warm cream
            Color(0xFFFEF3C7), // Soft sun yellow
            Color(0xFFFDE68A), // Golden amber
            Color(0xFFFCD34D), // Rich warning gold
          ],
          stops: [0.0, 0.38, 0.75, 1.0],
        ),
        border: Border.all(
          color: Color.lerp(
            const Color(0xFFF59E0B),
            const Color(0xFFD97706),
            pulse,
          )!,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B)
                .withValues(alpha: 0.20 + 0.14 * pulse),
            blurRadius: 14 + 5 * pulse,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WarningAmberPainter(phase: phase),
              ),
            ),
            Padding(
              padding: widget.padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreshCalmContainer(double phase, double pulse, Widget child) {
    return Container(
      width: widget.width,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FDF4), // Soothing mint-white
            Color(0xFFDCFCE7), // Fresh leaf mist
            Color(0xFFCCFBF1), // Cool aqua breeze
            Color(0xFFA7F3D0), // Soft emerald glow
          ],
          stops: [0.0, 0.4, 0.75, 1.0],
        ),
        border: Border.all(
          color: Color.lerp(
            const Color(0xFF34D399),
            const Color(0xFF10B981),
            pulse,
          )!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981)
                .withValues(alpha: 0.14 + 0.08 * pulse),
            blurRadius: 12 + 4 * pulse,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FreshCalmPainter(phase: phase),
              ),
            ),
            Padding(
              padding: widget.padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge status di bagian atas kartu sesuai [MemoCardVisualState]
class UrgentFlameBadge extends StatelessWidget {
  final String dueDate;
  final MemoCardVisualState visualState;

  const UrgentFlameBadge({
    super.key,
    required this.dueDate,
    this.visualState = MemoCardVisualState.urgentFire,
  });

  @override
  Widget build(BuildContext context) {
    if (visualState == MemoCardVisualState.completedFresh) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF059669).withValues(alpha: 0.35),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              size: 11,
              color: Color(0xFF047857),
            ),
            SizedBox(width: 4),
            Text(
              'SELESAI · TUNTAS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: Color(0xFF065F46),
              ),
            ),
          ],
        ),
      );
    }

    final diffDays = UrgentFlameHelper.daysUntilDue(dueDate) ?? 0;

    if (visualState == MemoCardVisualState.warningYellow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF78350F).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD97706).withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 11,
              color: Color(0xFFB45309),
            ),
            const SizedBox(width: 4),
            Text(
              'WARNING · $diffDays HARI LAGI',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: Color(0xFF78350F),
              ),
            ),
          ],
        ),
      );
    }

    // Urgent Fire
    final label = diffDays < 0
        ? 'OVERDUE (${diffDays.abs()}H)'
        : (diffDays == 0 ? 'DEADLINE HARI INI!' : 'BESOK (1 HARI LAGI)');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEDD5), Color(0xFFFDE68A)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.45),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 11,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: Color(0xFF991B1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscordFlamePainter extends CustomPainter {
  final double phase;

  _DiscordFlamePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.25),
          const Color(0xFFEF4444).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            w * 0.85,
            h * 0.15 + math.sin(phase * 2 * math.pi) * 6,
          ),
          radius: w * 0.45,
        ),
      );
    canvas.drawCircle(Offset(w * 0.85, h * 0.15), w * 0.45, auraPaint);

    final backFlamePath = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 6) {
      final normX = x / w;
      final wave1 = math.sin((normX * 3.5 + phase) * 2 * math.pi) * 10;
      final wave2 = math.cos((normX * 6.0 - phase * 2) * 2 * math.pi) * 6;
      final y = h - 26 + wave1 + wave2;
      backFlamePath.lineTo(x, y);
    }
    backFlamePath
      ..lineTo(w, h)
      ..close();

    final backFlamePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF6B00).withValues(alpha: 0.18),
          const Color(0xFFEF4444).withValues(alpha: 0.42),
        ],
      ).createShader(Rect.fromLTWH(0, h - 48, w, 48));
    canvas.drawPath(backFlamePath, backFlamePaint);

    final frontFlamePath = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 5) {
      final normX = x / w;
      final tongue = math.sin((normX * 5.0 - phase) * 2 * math.pi) * 8 +
          math.sin((normX * 9.0 + phase * 2) * 2 * math.pi) * 4;
      final y = h - 14 + tongue;
      frontFlamePath.lineTo(x, y);
    }
    frontFlamePath
      ..lineTo(w, h)
      ..close();

    final frontFlamePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFACC15).withValues(alpha: 0.16),
          const Color(0xFFF97316).withValues(alpha: 0.38),
        ],
      ).createShader(Rect.fromLTWH(0, h - 32, w, 32));
    canvas.drawPath(frontFlamePath, frontFlamePaint);

    final emberSeeds = [
      (0.14, 0.0, 2.2),
      (0.28, 0.35, 1.8),
      (0.46, 0.65, 2.5),
      (0.62, 0.18, 1.7),
      (0.77, 0.52, 2.3),
      (0.88, 0.82, 1.9),
      (0.35, 0.88, 1.5),
      (0.70, 0.08, 2.1),
    ];

    for (final seed in emberSeeds) {
      final baseX = seed.$1 * w;
      final offsetPhase = (phase + seed.$2) % 1.0;
      final radius = seed.$3;

      final y = h - (offsetPhase * h * 0.85);
      final sway = math.sin((offsetPhase * 2 + seed.$1) * 2 * math.pi) * 7;
      final alpha = (1.0 - offsetPhase).clamp(0.0, 1.0) * 0.65;

      final emberPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFDE047),
          const Color(0xFFFB923C),
          offsetPhase,
        )!.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

      canvas.drawCircle(Offset(baseX + sway, y), radius, emberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiscordFlamePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _WarningAmberPainter extends CustomPainter {
  final double phase;

  _WarningAmberPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Animated golden wave at bottom
    final wavePath = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 6) {
      final normX = x / w;
      final y = h -
          18 +
          math.sin((normX * 2.5 + phase) * 2 * math.pi) * 6 +
          math.cos((normX * 4.0 - phase) * 2 * math.pi) * 3;
      wavePath.lineTo(x, y);
    }
    wavePath
      ..lineTo(w, h)
      ..close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.14),
          const Color(0xFFD97706).withValues(alpha: 0.28),
        ],
      ).createShader(Rect.fromLTWH(0, h - 32, w, 32));
    canvas.drawPath(wavePath, wavePaint);

    // Floating amber shimmer dots
    final sparks = [
      (0.18, 0.1, 2.0),
      (0.45, 0.5, 2.4),
      (0.72, 0.25, 1.9),
      (0.86, 0.75, 2.2),
    ];
    for (final s in sparks) {
      final p = (phase + s.$2) % 1.0;
      final x = s.$1 * w + math.sin(p * 2 * math.pi) * 5;
      final y = h - p * h * 0.75;
      final alpha = (1.0 - p) * 0.45;
      final paint = Paint()
        ..color = const Color(0xFFD97706).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), s.$3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WarningAmberPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _FreshCalmPainter extends CustomPainter {
  final double phase;

  _FreshCalmPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gentle soothing aqua-mint wave at bottom
    final wavePath = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 6) {
      final normX = x / w;
      final y = h -
          16 +
          math.sin((normX * 2.0 + phase) * 2 * math.pi) * 5;
      wavePath.lineTo(x, y);
    }
    wavePath
      ..lineTo(w, h)
      ..close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.10),
          const Color(0xFF059669).withValues(alpha: 0.22),
        ],
      ).createShader(Rect.fromLTWH(0, h - 28, w, 28));
    canvas.drawPath(wavePath, wavePaint);

    // Floating fresh dew bubbles
    final bubbles = [
      (0.20, 0.15, 3.0),
      (0.52, 0.60, 2.5),
      (0.78, 0.30, 3.2),
      (0.88, 0.80, 2.2),
    ];
    for (final b in bubbles) {
      final p = (phase + b.$2) % 1.0;
      final x = b.$1 * w + math.cos(p * 2 * math.pi) * 4;
      final y = h - p * h * 0.7;
      final alpha = (1.0 - p) * 0.35;
      final paint = Paint()
        ..color = const Color(0xFF059669).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), b.$3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FreshCalmPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
