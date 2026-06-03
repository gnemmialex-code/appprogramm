import 'dart:math';

import 'package:flutter/material.dart';

/// Maps every sub-theme id to a **distinct decorative motif**. Motifs are
/// chosen to evoke each sub-theme's concept, and are guaranteed unique *within*
/// each domain — so as you flick between a domain's sub-themes, the animated
/// header background morphs into a genuinely different scene each time.
const Map<String, String> _subThemeMotif = {
  // ── psychologie ──
  'biais': 'neurons',
  'emotions': 'bubbles',
  'estime': 'mirror',
  'resilience': 'shield',
  'attachement': 'links',
  'motivation': 'target',
  'memoire': 'orbits',
  'pleine-conscience': 'lotus',
  'identite': 'petals',
  // ── anxiete ──
  'anxiete-sociale': 'links',
  'stress-burnout': 'flame',
  'phobies': 'spiral',
  'perf': 'rays',
  'ruminations': 'orbits',
  'panique': 'bolt',
  'anxiete-nuit': 'stars',
  'hyperactivite': 'heartbeat',
  // ── productivite ──
  'gestion-temps': 'clock',
  'procrastination': 'waves',
  'focus': 'target',
  'energie': 'bolt',
  'organisation': 'checklist',
  'priorisation': 'trophy',
  'creativite': 'bubbles',
  'teletravail': 'bars',
  'projet': 'streaks',
  // ── sport ──
  'course': 'streaks',
  'muscu': 'bars',
  'yoga': 'lotus',
  'cardio': 'heartbeat',
  'arts-martiaux': 'bolt',
  'natation': 'waves',
  'cyclisme': 'orbits',
  'maison': 'checklist',
  'recuperation': 'petals',
  // ── nutrition ──
  'perte-poids': 'bars',
  'prise-masse': 'rays',
  'vegan': 'petals',
  'sport-nutrition': 'bolt',
  'intuitif': 'bubbles',
  'sucre': 'spiral',
  'microbiome': 'orbits',
  'jejun': 'clock',
  'anti-inflam': 'lotus',
  // ── relations ──
  'couple': 'hearts',
  'amitie': 'links',
  'pro': 'orbits',
  'famille': 'bubbles',
  'limites': 'shield',
  'rupture': 'waves',
  'confiance-rel': 'spiral',
  'seduction': 'petals',
  'cnv': 'stars',
  // ── sommeil ──
  'insomnie': 'waves',
  'rythme': 'orbits',
  'rituel-soir': 'flame',
  'sieste': 'bubbles',
  'perf-sommeil': 'trophy',
  'reves': 'stars',
  'detox-ecran': 'bars',
  'environnement': 'lotus',
  // ── confiance ──
  'timidite': 'petals',
  'prise-parole': 'rays',
  'confiance-pro': 'bars',
  'assertivite': 'bolt',
  'image-corpo': 'mirror',
  'imposteur': 'spiral',
  'leadership': 'trophy',
  'independance': 'streaks',
  // ── bien-etre ──
  'meditation': 'lotus',
  'relaxation': 'waves',
  'detox-digitale': 'bars',
  'energie-vitale': 'bolt',
  'respiration': 'heartbeat',
  'douleur': 'petals',
  'ancrage': 'target',
  'lacher-prise': 'bubbles',
  // ── apprentissage ──
  'lecture-rapide': 'streaks',
  'memoire-palais': 'neurons',
  'eloquence': 'rays',
  'langues': 'links',
  'ecriture': 'waves',
  'pensee-critique': 'spiral',
  'methode-etude': 'checklist',
  'revision': 'orbits',
  // ── business ──
  'entrepreneuriat': 'streaks',
  'marketing': 'rays',
  'vente': 'trophy',
  'management': 'links',
  'negociation': 'shield',
  'carriere': 'bars',
  'reseau': 'orbits',
  'prise-decision': 'target',
  // ── finance ──
  'budget': 'bars',
  'epargne': 'checklist',
  'investissement': 'streaks',
  'mindset-argent': 'spiral',
  'dettes': 'waves',
  'revenus': 'bolt',
  'independance-fin': 'trophy',
  'immobilier': 'shield',
  // ── spiritualite ──
  'meditation-profonde': 'lotus',
  'journal': 'waves',
  'gratitude': 'petals',
  'alignement': 'target',
  'sens-vie': 'stars',
  'pleine-presence': 'bubbles',
  'silence': 'orbits',
  'rituels': 'flame',
  // ── creativite-arts ──
  'dessin': 'streaks',
  'musique': 'bars',
  'ecriture-creative': 'waves',
  'photographie': 'mirror',
  'peinture': 'petals',
  'improvisation': 'bubbles',
  'inspiration': 'rays',
  'artisanat': 'checklist',
  // ── habitudes ──
  'routine-matinale': 'rays',
  'routine-soir': 'stars',
  'organisation-maison': 'checklist',
  'minimalisme': 'bubbles',
  'habitudes-saines': 'orbits',
  'desencombrement': 'bars',
  'equilibre-vie': 'waves',
  'ecologie-quotidien': 'petals',
};

/// Fallback motif per domain when a sub-theme id isn't mapped.
const Map<String, String> _domainDefaultMotif = {
  'psychologie': 'neurons',
  'anxiete': 'stars',
  'productivite': 'bars',
  'sport': 'streaks',
  'nutrition': 'petals',
  'relations': 'hearts',
  'sommeil': 'stars',
  'confiance': 'rays',
  'bien-etre': 'lotus',
  'apprentissage': 'neurons',
  'business': 'trophy',
  'finance': 'bars',
  'spiritualite': 'lotus',
  'creativite-arts': 'petals',
  'habitudes': 'checklist',
};

/// Resolves the motif for the active [subThemeId] within [domainId].
String resolveDecorMotif(String domainId, String subThemeId) =>
    _subThemeMotif[subThemeId] ?? _domainDefaultMotif[domainId] ?? 'bubbles';

/// A distinctive **animated decorative background**, unique to each sub-theme.
/// Rendered only behind that domain's detail header. The [seed] adds gentle
/// per-sub-theme variation and the scene cross-fades when [motif] changes.
class DomainDecor extends StatefulWidget {
  final String motif;
  final Color color;
  final int seed;

  const DomainDecor({
    super.key,
    required this.motif,
    required this.color,
    this.seed = 0,
  });

  @override
  State<DomainDecor> createState() => _DomainDecorState();
}

class _DomainDecorState extends State<DomainDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Light tint of the domain colour reads well over the darker hero gradient.
    final decorColor = Color.lerp(widget.color, Colors.white, 0.68)!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: RepaintBoundary(
        key: ValueKey('${widget.motif}-${widget.seed}'),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _DecorPainter(
              motif: widget.motif,
              t: _c.value,
              color: decorColor,
              seed: widget.seed,
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorPainter extends CustomPainter {
  final String motif;
  final double t; // 0..1, loops
  final Color color;
  final Random rnd;

  _DecorPainter({
    required this.motif,
    required this.t,
    required this.color,
    required int seed,
  }) : rnd = Random(seed * 2654435761 & 0x7fffffff);

  static const _tau = pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final p = Paint()..isAntiAlias = true;
    switch (motif) {
      case 'neurons':
        _neurons(canvas, size, p);
      case 'bubbles':
        _bubbles(canvas, size, p);
      case 'mirror':
        _mirror(canvas, size, p);
      case 'target':
        _target(canvas, size, p);
      case 'bars':
        _bars(canvas, size, p);
      case 'streaks':
        _streaks(canvas, size, p);
      case 'petals':
        _petals(canvas, size, p);
      case 'hearts':
        _hearts(canvas, size, p);
      case 'stars':
        _stars(canvas, size, p);
      case 'rays':
        _rays(canvas, size, p);
      case 'spiral':
        _spiral(canvas, size, p);
      case 'flame':
        _flame(canvas, size, p);
      case 'bolt':
        _bolt(canvas, size, p);
      case 'waves':
        _waves(canvas, size, p);
      case 'checklist':
        _checklist(canvas, size, p);
      case 'orbits':
        _orbits(canvas, size, p);
      case 'links':
        _links(canvas, size, p);
      case 'lotus':
        _lotus(canvas, size, p);
      case 'clock':
        _clock(canvas, size, p);
      case 'heartbeat':
        _heartbeat(canvas, size, p);
      case 'shield':
        _shield(canvas, size, p);
      case 'trophy':
        _trophy(canvas, size, p);
      default:
        _bubbles(canvas, size, p);
    }
  }

  Color _a(double v) => color.withValues(alpha: v.clamp(0, 1));

  // ── neurons ────────────────────────────────────────────────────────────────
  void _neurons(Canvas c, Size s, Paint p) {
    const n = 13;
    final pts = _nodes(s, n, 7);
    final line = Paint()..strokeWidth = 1;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final d = (pts[i] - pts[j]).distance;
        if (d < 95) {
          c.drawLine(pts[i], pts[j], line..color = _a(0.12 * (1 - d / 95)));
        }
      }
    }
    for (var i = 0; i < n; i++) {
      c.drawCircle(
        pts[i],
        2 + (sin(t * _tau + i) * 0.5 + 0.5) * 2.6,
        p..color = _a(0.55),
      );
    }
  }

  // ── links (chained rings) ────────────────────────────────────────────────
  void _links(Canvas c, Size s, Paint p) {
    const n = 9;
    final pts = _nodes(s, n, 9);
    final line = Paint()..strokeWidth = 1.4;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final d = (pts[i] - pts[j]).distance;
        if (d < 105) {
          c.drawLine(pts[i], pts[j], line..color = _a(0.12 * (1 - d / 105)));
        }
      }
    }
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    for (var i = 0; i < n; i++) {
      c.drawCircle(
        pts[i],
        6 + (sin(t * _tau + i) * 0.5 + 0.5) * 2,
        p..color = _a(0.5),
      );
    }
    p.style = PaintingStyle.fill;
  }

  List<Offset> _nodes(Size s, int n, double drift) => List.generate(n, (i) {
    final bx = rnd.nextDouble();
    final by = rnd.nextDouble();
    final ph = rnd.nextDouble() * _tau;
    return Offset(
      bx * s.width + sin(t * _tau + ph) * drift,
      by * s.height * 0.95 + cos(t * _tau + ph) * drift,
    );
  });

  // ── bubbles ──────────────────────────────────────────────────────────────
  void _bubbles(Canvas c, Size s, Paint p) {
    const n = 13;
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < n; i++) {
      final bx = rnd.nextDouble();
      final ph = rnd.nextDouble() * _tau;
      final speed = 0.35 + rnd.nextDouble() * 0.5;
      final prog = (t * speed + rnd.nextDouble()) % 1.15;
      final x = bx * s.width + sin(t * _tau + ph) * 14;
      final y = (1 - prog) * s.height;
      c.drawCircle(
        Offset(x, y),
        4 + rnd.nextDouble() * 9,
        p..color = _a(0.20 * (1 - prog) + 0.05),
      );
    }
    p.style = PaintingStyle.fill;
  }

  // ── mirror (shimmer bands) ───────────────────────────────────────────────
  void _mirror(Canvas c, Size s, Paint p) {
    const n = 4;
    final bw = s.width * 0.11;
    for (var i = 0; i < n; i++) {
      final x = ((t * 0.3 + i / n) % 1.0) * (s.width * 1.2) - 0.1 * s.width;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, bw, s.height),
          Radius.circular(bw / 2),
        ),
        p..color = _a(0.05 + 0.07 * (sin(t * _tau + i) * 0.5 + 0.5)),
      );
    }
  }

  // ── target ───────────────────────────────────────────────────────────────
  void _target(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, s.height * 0.45);
    final m = s.shortestSide;
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final r in const [0.16, 0.30, 0.44]) {
      c.drawCircle(center, r * m, p..color = _a(0.16));
    }
    final f = t % 1.0;
    c.drawCircle(center, f * 0.5 * m, p..color = _a((1 - f) * 0.3));
    p.style = PaintingStyle.fill;
    c.drawCircle(center, 0.04 * m, p..color = _a(0.45));
  }

  // ── bars (equaliser) ─────────────────────────────────────────────────────
  void _bars(Canvas c, Size s, Paint p) {
    const bars = 9;
    final bw = s.width / (bars * 1.7);
    for (var i = 0; i < bars; i++) {
      final ph = i * 0.7 + rnd.nextDouble() * _tau;
      final hh = (sin(t * _tau + ph) * 0.5 + 0.5) * s.height * 0.4 + 14;
      final x = (i + 0.5) * s.width / bars;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, s.height - hh / 2),
            width: bw,
            height: hh,
          ),
          Radius.circular(bw / 2),
        ),
        p..color = _a(0.16),
      );
    }
  }

  // ── streaks ──────────────────────────────────────────────────────────────
  void _streaks(Canvas c, Size s, Paint p) {
    const n = 11;
    p
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < n; i++) {
      final by = rnd.nextDouble();
      final speed = 0.6 + rnd.nextDouble() * 0.9;
      final x = ((t * speed + rnd.nextDouble()) % 1.25 - 0.12) * s.width;
      final y = by * s.height;
      final len = 16 + rnd.nextDouble() * 26;
      c.drawLine(
        Offset(x, y),
        Offset(x + len, y - len * 0.32),
        p..color = _a(0.16),
      );
    }
  }

  // ── petals ───────────────────────────────────────────────────────────────
  void _petals(Canvas c, Size s, Paint p) {
    const n = 12;
    for (var i = 0; i < n; i++) {
      final bx = rnd.nextDouble();
      final ph = rnd.nextDouble() * _tau;
      final speed = 0.4 + rnd.nextDouble() * 0.5;
      final y = ((t * speed + rnd.nextDouble()) % 1.12) * s.height;
      final x = bx * s.width + sin(t * _tau + ph) * 16;
      final r = 4 + rnd.nextDouble() * 4;
      c.save();
      c.translate(x, y);
      c.rotate(ph + t * _tau * 0.35);
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r, height: r * 2.3),
        p..color = _a(0.22),
      );
      c.restore();
    }
  }

  // ── hearts ───────────────────────────────────────────────────────────────
  void _hearts(Canvas c, Size s, Paint p) {
    const n = 9;
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final bx = rnd.nextDouble();
      final ph = rnd.nextDouble() * _tau;
      final prog =
          (t * (0.4 + rnd.nextDouble() * 0.35) + rnd.nextDouble()) % 1.1;
      final pos = Offset(
        bx * s.width + sin(t * _tau + ph) * 12,
        (1 - prog) * s.height,
      );
      pts.add(pos);
      _heart(
        c,
        pos,
        7 + rnd.nextDouble() * 8,
        p..color = _a(0.07 + 0.18 * (1 - prog)),
      );
    }
    final line = Paint()..strokeWidth = 1;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final d = (pts[i] - pts[j]).distance;
        if (d < 80) {
          c.drawLine(pts[i], pts[j], line..color = _a(0.08 * (1 - d / 80)));
        }
      }
    }
  }

  // ── stars (night sky) ────────────────────────────────────────────────────
  void _stars(Canvas c, Size s, Paint p) {
    const n = 24;
    for (var i = 0; i < n; i++) {
      final x = rnd.nextDouble() * s.width;
      final y = rnd.nextDouble() * s.height * 0.88;
      final tw = sin(t * _tau * 1.6 + i) * 0.5 + 0.5;
      c.drawCircle(Offset(x, y), 1 + tw * 1.5, p..color = _a(0.25 + tw * 0.5));
    }
    final mc = Offset(s.width * 0.82, s.height * 0.26);
    c.drawCircle(mc, 26, p..color = _a(0.12));
    c.drawCircle(mc, 17, p..color = _a(0.45));
    final cx = (t * 0.4 % 1.2 - 0.1) * s.width;
    final cy = s.height * 0.78;
    for (final o in const [
      Offset(0, 0),
      Offset(18, -6),
      Offset(36, 0),
      Offset(14, 6),
    ]) {
      c.drawCircle(Offset(cx + o.dx, cy + o.dy), 12, p..color = _a(0.10));
    }
  }

  // ── rays (sunburst) ──────────────────────────────────────────────────────
  void _rays(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, -18);
    const rays = 13;
    final rp = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < rays; i++) {
      final base = pi * (0.12 + 0.76 * i / (rays - 1));
      final ang = base + sin(t * _tau * 0.5 + i) * 0.015;
      final dir = Offset(cos(ang), sin(ang));
      c.drawLine(
        center,
        center + dir * s.height,
        rp..color = _a(0.06 + 0.10 * (sin(t * _tau + i) * 0.5 + 0.5)),
      );
    }
    c.drawCircle(center, 30, p..color = _a(0.25));
    for (var i = 0; i < 7; i++) {
      final bx = rnd.nextDouble();
      final prog =
          (t * (0.5 + rnd.nextDouble() * 0.5) + rnd.nextDouble()) % 1.0;
      _star(
        c,
        Offset(bx * s.width, (1 - prog) * s.height),
        4,
        p..color = _a(0.55 * (1 - prog)),
      );
    }
  }

  // ── spiral ───────────────────────────────────────────────────────────────
  void _spiral(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, s.height * 0.45);
    final m = s.shortestSide;
    const n = 46;
    for (var i = 0; i < n; i++) {
      final frac = i / n;
      final a = frac * _tau * 3 + t * _tau;
      final rad = frac * 0.5 * m;
      c.drawCircle(
        center + Offset(cos(a), sin(a)) * rad,
        1 + frac * 2.2,
        p..color = _a(0.1 + frac * 0.45),
      );
    }
  }

  // ── flame ────────────────────────────────────────────────────────────────
  void _flame(Canvas c, Size s, Paint p) {
    const n = 7;
    final w = s.width / n;
    for (var i = 0; i < n; i++) {
      final x = (i + 0.5) * w;
      final flick = sin(t * _tau * 1.3 + i) * 0.5 + 0.5;
      final h = s.height * (0.16 + 0.18 * flick);
      final base = s.height;
      final path = Path()
        ..moveTo(x, base)
        ..quadraticBezierTo(x - w * 0.32, base - h * 0.5, x, base - h)
        ..quadraticBezierTo(x + w * 0.32, base - h * 0.5, x, base);
      c.drawPath(path, p..color = _a(0.12 + 0.06 * flick));
    }
  }

  // ── bolt (lightning) ─────────────────────────────────────────────────────
  void _bolt(Canvas c, Size s, Paint p) {
    const n = 5;
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < n; i++) {
      final bx = 0.1 + rnd.nextDouble() * 0.8;
      final x = bx * s.width;
      final topY = rnd.nextDouble() * s.height * 0.2;
      final h = s.height * (0.35 + rnd.nextDouble() * 0.35);
      final f = (t * (0.8 + rnd.nextDouble() * 0.6) + rnd.nextDouble()) % 1.0;
      final alpha = f < 0.25 ? (1 - f / 0.25) * 0.5 : 0.05;
      final path = Path()
        ..moveTo(x, topY)
        ..lineTo(x - 8, topY + h * 0.4)
        ..lineTo(x + 5, topY + h * 0.5)
        ..lineTo(x - 6, topY + h);
      c.drawPath(path, p..color = _a(alpha));
    }
    p.style = PaintingStyle.fill;
  }

  // ── waves ────────────────────────────────────────────────────────────────
  void _waves(Canvas c, Size s, Paint p) {
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var k = 0; k < 3; k++) {
      final path = Path();
      final yBase = s.height * (0.35 + 0.18 * k);
      final amp = 10.0 + 6 * k;
      for (double x = 0; x <= s.width; x += 6) {
        final y = yBase + sin(x / s.width * _tau * 1.5 + t * _tau + k) * amp;
        x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      c.drawPath(path, p..color = _a(0.12 + 0.04 * (2 - k)));
    }
    p.style = PaintingStyle.fill;
  }

  // ── checklist ────────────────────────────────────────────────────────────
  void _checklist(Canvas c, Size s, Paint p) {
    const cols = 3, rows = 4;
    final cw = s.width / (cols + 1);
    final ch = s.height / (rows + 1);
    final box = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var r = 0; r < rows; r++) {
      for (var col = 0; col < cols; col++) {
        final i = r * cols + col;
        final center = Offset((col + 1) * cw, (r + 1) * ch);
        const sz = 13.0;
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: sz, height: sz),
            const Radius.circular(4),
          ),
          box..color = _a(0.18),
        );
        if (sin(t * _tau + i * 0.9) > 0.4) {
          final tick = Path()
            ..moveTo(center.dx - 4, center.dy)
            ..lineTo(center.dx - 1, center.dy + 3)
            ..lineTo(center.dx + 4, center.dy - 3);
          c.drawPath(tick, box..color = _a(0.5));
        }
      }
    }
  }

  // ── orbits ───────────────────────────────────────────────────────────────
  void _orbits(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, s.height * 0.45);
    final m = s.shortestSide;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const n = 11;
    for (var i = 0; i < n; i++) {
      final rad = (0.12 + 0.032 * i) * m;
      if (i % 3 == 0) {
        c.drawOval(
          Rect.fromCenter(center: center, width: rad * 2, height: rad * 1.4),
          ring..color = _a(0.08),
        );
      }
      final ang = t * _tau * (0.4 + 0.08 * i) + i * 0.7;
      final pos = center + Offset(cos(ang) * rad, sin(ang) * rad * 0.7);
      c.drawCircle(pos, 2.4, p..color = _a(0.5));
    }
  }

  // ── lotus ────────────────────────────────────────────────────────────────
  void _lotus(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, s.height * 0.55);
    final bloom = 0.62 + (sin(t * _tau) * 0.5 + 0.5) * 0.38;
    final len = s.shortestSide * 0.3 * bloom;
    const petals = 8;
    for (var k = 0; k < petals; k++) {
      final ang = k / petals * _tau + t * 0.3;
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(ang);
      c.drawOval(
        Rect.fromCenter(
          center: Offset(0, -len / 2),
          width: len * 0.36,
          height: len,
        ),
        p..color = _a(0.14),
      );
      c.restore();
    }
    c.drawCircle(center, 5, p..color = _a(0.4));
  }

  // ── clock ────────────────────────────────────────────────────────────────
  void _clock(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, s.height * 0.45);
    final r = s.shortestSide * 0.3;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    c.drawCircle(center, r, stroke..color = _a(0.2));
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * _tau;
      final o = Offset(cos(a), sin(a));
      c.drawLine(
        center + o * (r - 6),
        center + o * r,
        stroke..color = _a(0.25),
      );
    }
    final ha = t * _tau - pi / 2;
    final ma = t * _tau * 12 - pi / 2;
    c.drawLine(
      center,
      center + Offset(cos(ha), sin(ha)) * r * 0.5,
      stroke..color = _a(0.5),
    );
    c.drawLine(
      center,
      center + Offset(cos(ma), sin(ma)) * r * 0.8,
      stroke..color = _a(0.4),
    );
    c.drawCircle(center, 3, p..color = _a(0.5));
  }

  // ── heartbeat (ECG) ──────────────────────────────────────────────────────
  void _heartbeat(Canvas c, Size s, Paint p) {
    final y0 = s.height * 0.5;
    final peak = (t % 1.0) * s.width;
    final path = Path()..moveTo(0, y0);
    for (double x = 0; x <= s.width; x += 4) {
      final dx = (x - peak).abs();
      double y = y0;
      if (dx < 26) {
        final k = (x - peak) / 26; // -1..1
        y = y0 - sin(k * pi) * 34 * (1 - dx / 26);
      }
      path.lineTo(x, y);
    }
    c.drawPath(
      path,
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = _a(0.4),
    );
    c.drawCircle(
      Offset(peak, y0 - 34),
      3,
      p
        ..style = PaintingStyle.fill
        ..color = _a(0.6),
    );
  }

  // ── shield ───────────────────────────────────────────────────────────────
  void _shield(Canvas c, Size s, Paint p) {
    const n = 5;
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < n; i++) {
      final bx = rnd.nextDouble();
      final by = rnd.nextDouble() * 0.85;
      final ph = rnd.nextDouble() * _tau;
      final sz = 14 + rnd.nextDouble() * 12;
      final o = Offset(bx * s.width, by * s.height + sin(t * _tau + ph) * 5);
      final path = Path()
        ..moveTo(o.dx, o.dy - sz)
        ..lineTo(o.dx + sz * 0.8, o.dy - sz * 0.5)
        ..lineTo(o.dx + sz * 0.8, o.dy + sz * 0.2)
        ..quadraticBezierTo(o.dx, o.dy + sz, o.dx, o.dy + sz)
        ..quadraticBezierTo(o.dx, o.dy + sz, o.dx - sz * 0.8, o.dy + sz * 0.2)
        ..lineTo(o.dx - sz * 0.8, o.dy - sz * 0.5)
        ..close();
      c.drawPath(
        path,
        p..color = _a(0.16 + 0.1 * (sin(t * _tau + i) * 0.5 + 0.5)),
      );
    }
    p.style = PaintingStyle.fill;
  }

  // ── trophy ───────────────────────────────────────────────────────────────
  void _trophy(Canvas c, Size s, Paint p) {
    final center = Offset(s.width * 0.5, s.height * 0.46);
    final m = s.shortestSide * 0.22;
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // cup bowl
    final cup = Path()
      ..moveTo(center.dx - m, center.dy - m)
      ..lineTo(center.dx + m, center.dy - m)
      ..lineTo(center.dx + m * 0.7, center.dy + m * 0.4)
      ..lineTo(center.dx - m * 0.7, center.dy + m * 0.4)
      ..close();
    c.drawPath(cup, p..color = _a(0.4));
    // handles
    c.drawArc(
      Rect.fromCircle(
        center: Offset(center.dx - m, center.dy - m * 0.4),
        radius: m * 0.5,
      ),
      pi * 0.4,
      pi,
      false,
      p..color = _a(0.3),
    );
    c.drawArc(
      Rect.fromCircle(
        center: Offset(center.dx + m, center.dy - m * 0.4),
        radius: m * 0.5,
      ),
      -pi * 0.4,
      -pi,
      false,
      p..color = _a(0.3),
    );
    // stem + base
    c.drawLine(
      Offset(center.dx, center.dy + m * 0.4),
      Offset(center.dx, center.dy + m),
      p..color = _a(0.4),
    );
    c.drawLine(
      Offset(center.dx - m * 0.5, center.dy + m),
      Offset(center.dx + m * 0.5, center.dy + m),
      p..color = _a(0.4),
    );
    p.style = PaintingStyle.fill;
    // glints
    for (var i = 0; i < 6; i++) {
      final bx = rnd.nextDouble();
      final prog =
          (t * (0.5 + rnd.nextDouble() * 0.5) + rnd.nextDouble()) % 1.0;
      _star(
        c,
        Offset(bx * s.width, (1 - prog) * s.height),
        3.5,
        p..color = _a(0.5 * (1 - prog)),
      );
    }
  }

  // ── shape helpers ──────────────────────────────────────────────────────────
  void _heart(Canvas c, Offset o, double s, Paint p) {
    final path = Path()
      ..moveTo(o.dx, o.dy + s * 0.32)
      ..cubicTo(
        o.dx - s,
        o.dy - s * 0.3,
        o.dx - s * 0.5,
        o.dy - s,
        o.dx,
        o.dy - s * 0.38,
      )
      ..cubicTo(
        o.dx + s * 0.5,
        o.dy - s,
        o.dx + s,
        o.dy - s * 0.3,
        o.dx,
        o.dy + s * 0.32,
      );
    c.drawPath(path, p);
  }

  void _star(Canvas c, Offset o, double r, Paint p) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * pi / 2;
      path.moveTo(o.dx, o.dy);
      path.lineTo(
        o.dx + cos(a - 0.25) * r * 0.4,
        o.dy + sin(a - 0.25) * r * 0.4,
      );
      path.lineTo(o.dx + cos(a) * r, o.dy + sin(a) * r);
      path.lineTo(
        o.dx + cos(a + 0.25) * r * 0.4,
        o.dy + sin(a + 0.25) * r * 0.4,
      );
      path.close();
    }
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _DecorPainter old) =>
      old.t != t || old.color != color || old.motif != motif;
}
