import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated Booqly logo widget.
/// Combines entry scale animation, continuous float, and shimmer sweep.
class BooqlyLogo extends StatefulWidget {
  const BooqlyLogo({
    super.key,
    this.size = 100,
    this.animate = true,
  });

  final double size;
  final bool animate;

  @override
  State<BooqlyLogo> createState() => _BooqlyLogoState();
}

class _BooqlyLogoState extends State<BooqlyLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _shimmerCtrl;

  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _float;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _scale = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.elasticOut,
    );
    _opacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
    _shimmer = _shimmerCtrl;

    if (widget.animate) {
      _entryCtrl.forward().then((_) {
        _floatCtrl.repeat(reverse: true);
        _shimmerCtrl.repeat();
      });
    } else {
      _entryCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: Listenable.merge([_scale, _float, _shimmer]),
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _float.value),
            child: Transform.scale(
              scale: _scale.value,
              child: _LogoBody(
                size: widget.size,
                shimmerProgress: _shimmer.value,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoBody extends StatelessWidget {
  const _LogoBody({
    required this.size,
    required this.shimmerProgress,
    required this.isDark,
  });

  final double size;
  final double shimmerProgress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.55 : 0.35),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.05,
          ),
          // Deep shadow
          BoxShadow(
            color: const Color(0xFF4C1D95).withValues(alpha: 0.4),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _LogoPainter(
          shimmerProgress: shimmerProgress,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.shimmerProgress, required this.isDark});

  final double shimmerProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.width * 0.28);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    // ── Background gradient ───────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFF7C3AED),
          Color(0xFF5B21B6),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // ── 3-D top-left highlight ────────────────────────────────────────────────
    final hlPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, hlPaint);

    // ── Shimmer sweep ─────────────────────────────────────────────────────────
    final shimmerX = size.width * (shimmerProgress * 2.4 - 0.7);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        shimmerX - size.width * 0.4,
        0,
        size.width * 0.8,
        size.height,
      ));

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, shimmerPaint);
    canvas.restore();

    // ── Calendar card ────────────────────────────────────────────────────────
    _drawCalendarCard(canvas, size);

    // ── Sparkle stars ────────────────────────────────────────────────────────
    _drawSparkle(canvas, size, Offset(size.width * 0.15, size.height * 0.18), size.width * 0.035);
    _drawSparkle(canvas, size, Offset(size.width * 0.82, size.height * 0.22), size.width * 0.025);
    _drawSparkle(canvas, size, Offset(size.width * 0.78, size.height * 0.75), size.width * 0.028);
  }

  void _drawCalendarCard(Canvas canvas, Size size) {
    final s = size.width;
    final cardLeft = s * 0.18;
    final cardTop = s * 0.20;
    final cardRight = s * 0.82;
    final cardBottom = s * 0.80;
    final cardRect = Rect.fromLTRB(cardLeft, cardTop, cardRight, cardBottom);
    final cardRR = RRect.fromRectAndRadius(cardRect, Radius.circular(s * 0.10));

    // Card background (semi-white glass)
    final cardPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20);
    canvas.drawRRect(cardRR, cardPaint);

    // Card top bar (header)
    final headerRect = Rect.fromLTRB(cardLeft, cardTop, cardRight, cardTop + s * 0.16);
    final headerRR = RRect.fromLTRBAndCorners(
      headerRect.left, headerRect.top, headerRect.right, headerRect.bottom,
      topLeft: Radius.circular(s * 0.10),
      topRight: Radius.circular(s * 0.10),
    );
    final headerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30);
    canvas.drawRRect(headerRR, headerPaint);

    // Two small "binding dots" at top of card
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(cardLeft + s * 0.14, cardTop), s * 0.028, dotPaint);
    canvas.drawCircle(Offset(cardRight - s * 0.14, cardTop), s * 0.028, dotPaint);

    // Grid lines (calendar cells)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = s * 0.012;
    // Horizontal
    final gridTop = cardTop + s * 0.18;
    final rowH = (cardBottom - gridTop) / 3;
    for (int i = 1; i < 3; i++) {
      final y = gridTop + rowH * i;
      canvas.drawLine(Offset(cardLeft + s * 0.06, y), Offset(cardRight - s * 0.06, y), gridPaint);
    }
    // Vertical
    final colW = (cardRight - cardLeft) / 4;
    for (int i = 1; i < 4; i++) {
      final x = cardLeft + colW * i;
      canvas.drawLine(Offset(x, gridTop), Offset(x, cardBottom - s * 0.06), gridPaint);
    }

    // Checkmark circle
    _drawCheckmark(canvas, size, Offset(s * 0.50, s * 0.55), s * 0.17);
  }

  void _drawCheckmark(Canvas canvas, Size size, Offset center, double radius) {
    final s = size.width;

    // Circle glow
    final glowPaint = Paint()
      ..color = const Color(0xFFA78BFA).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * 1.2, glowPaint);

    // Circle fill
    final circlePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, circlePaint);

    // Circle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018;
    canvas.drawCircle(center, radius, borderPaint);

    // Checkmark path
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(center.dx - radius * 0.42, center.dy + radius * 0.02)
      ..lineTo(center.dx - radius * 0.05, center.dy + radius * 0.40)
      ..lineTo(center.dx + radius * 0.48, center.dy - radius * 0.36);
    canvas.drawPath(path, checkPaint);
  }

  void _drawSparkle(Canvas canvas, Size size, Offset center, double r) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path = Path();
    const arms = 4;
    for (int i = 0; i < arms * 2; i++) {
      final angle = (i * math.pi) / arms;
      final len = i.isEven ? r : r * 0.35;
      final x = center.dx + math.cos(angle) * len;
      final y = center.dy + math.sin(angle) * len;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Center dot
    canvas.drawCircle(center, r * 0.22, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.shimmerProgress != shimmerProgress || old.isDark != isDark;
}
