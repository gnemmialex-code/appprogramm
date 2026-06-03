import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/recommendation_engine.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// A self-contained "what's next" section: a mini report of the finished
/// journey followed by personalised recommendations for the next theme.
class RecommendationSection extends StatelessWidget {
  final CompletionReport report;
  const RecommendationSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Mini report header ---
        _MiniReportCard(report: report),
        const SizedBox(height: 20),

        // --- Section title ---
        Row(
          children: [
            const Text('🧭', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text(
              'La suite de ton apprentissage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Recommandations basées sur ce que tu as appris et les sujets '
          'qui t\'ont demandé plus de temps.',
          style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
        ),
        const SizedBox(height: 16),

        // --- Recommendation cards ---
        ...report.recommendations.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecommendationCard(rec: r),
          ),
        ),
      ],
    );
  }
}

class _MiniReportCard extends StatelessWidget {
  final CompletionReport report;
  const _MiniReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandStart, AppColors.brandEnd],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📊 MINI-RAPPORT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                report.masteryLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            report.headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _ReportStat(
                value: '${(report.completionRatio * 100).round()}%',
                label: 'complété',
              ),
              _statDivider(),
              _ReportStat(
                value: '${(report.avgQuizRatio * 100).round()}%',
                label: 'aux quiz',
              ),
              _statDivider(),
              _ReportStat(
                value: report.totalMinutes > 0
                    ? '${report.totalMinutes}min'
                    : '—',
                label: 'investies',
              ),
            ],
          ),
          if (report.strongSubjects.isNotEmpty ||
              report.strugglingSubjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 14),
            if (report.strongSubjects.isNotEmpty)
              _SubjectLine(
                icon: '💪',
                label: 'Tes points forts',
                subjects: report.strongSubjects,
              ),
            if (report.strongSubjects.isNotEmpty &&
                report.strugglingSubjects.isNotEmpty)
              const SizedBox(height: 10),
            if (report.strugglingSubjects.isNotEmpty)
              _SubjectLine(
                icon: '🎯',
                label: 'À consolider',
                subjects: report.strugglingSubjects,
              ),
          ],
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 32,
    color: Colors.white.withValues(alpha: 0.20),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

class _ReportStat extends StatelessWidget {
  final String value;
  final String label;
  const _ReportStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectLine extends StatelessWidget {
  final String icon;
  final String label;
  final List<String> subjects;
  const _SubjectLine({
    required this.icon,
    required this.label,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    // Show up to 3 subjects.
    final shown = subjects.take(3).toList();
    final extra = subjects.length - shown.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                shown.join(' · ') + (extra > 0 ? ' +$extra' : ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final accent = rec.isExpert
        ? AppColors.deepPurple
        : (rec.isSameDomain ? AppColors.lavender : AppColors.mint);

    return SoftCard(
      onTap: () {
        if (rec.isExpert) {
          context.push(
            '/expert-generate/${rec.domainId}',
            extra: rec.subThemeLabel,
          );
        } else {
          context.push('/domain/${rec.domainId}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(rec.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Tag(
                          label: rec.isExpert
                              ? '🎓 EXPERT'
                              : (rec.isSameDomain ? 'APPROFONDIR' : 'EXPLORER'),
                          color: accent,
                        ),
                        const SizedBox(width: 6),
                        if (!rec.isSameDomain || rec.isExpert)
                          Flexible(
                            child: Text(
                              rec.domainLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.inkSoft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rec.subThemeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.inkSoft,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded, size: 15, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.reason,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color.lerp(color, Colors.black, 0.25),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
