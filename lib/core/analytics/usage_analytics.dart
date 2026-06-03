/// Pure-Dart analytics: detects the user's habitual app-open time and
/// computes when to fire a "smart reminder" (~30 min before their usual open).
///
/// Requires at least 14 days of data; until then the status is "collecting".
/// The algorithm:
///  1. Deduplicate: keep only the *first* open of each calendar day.
///  2. Build a histogram of time-of-day in 30-minute buckets.
///  3. The bucket with ≥ 5 data-points and the highest count wins.
///  4. Compute the mean minute-of-day inside that bucket.
///  5. Notification fires 30 minutes before that mean (clamped so it never
///     lands in the middle of the night for an early riser).
library;

class UsagePattern {
  final int daysCollected;
  final int daysNeeded; // always 14
  final bool isReady;
  final int? predictedHour;
  final int? predictedMinute;
  final int? notifyHour;
  final int? notifyMinute;
  final int confidence; // 0–100 %

  const UsagePattern({
    required this.daysCollected,
    this.daysNeeded = 14,
    this.isReady = false,
    this.predictedHour,
    this.predictedMinute,
    this.notifyHour,
    this.notifyMinute,
    this.confidence = 0,
  });

  bool get isCollecting => daysCollected < daysNeeded;
  double get collectionProgress => (daysCollected / daysNeeded).clamp(0.0, 1.0);
  int get daysRemaining => (daysNeeded - daysCollected).clamp(0, daysNeeded);

  // ---- Display helpers ------------------------------------------------------

  String get predictedTimeLabel {
    if (!isReady || predictedHour == null) return '--:--';
    return '${predictedHour!}h${_mm(predictedMinute!)}';
  }

  String get notifyTimeLabel {
    if (!isReady || notifyHour == null) return '--:--';
    return '${notifyHour!}h${_mm(notifyMinute!)}';
  }

  String get periodLabel {
    if (predictedHour == null) return '';
    final h = predictedHour!;
    if (h >= 5 && h < 10) return 'le matin';
    if (h >= 10 && h < 13) return 'en matinée';
    if (h >= 13 && h < 18) return "l'après-midi";
    if (h >= 18 && h < 22) return 'en soirée';
    return 'la nuit';
  }

  String get statusMessage {
    if (daysCollected == 0) {
      return "Ouvre l'app chaque jour — apprentik apprend tes habitudes.";
    }
    if (isCollecting) {
      final rem = daysRemaining;
      return rem > 1
          ? 'Plus que $rem jours pour finaliser l\'analyse'
          : 'Encore 1 jour pour finaliser l\'analyse';
    }
    if (!isReady) {
      return 'Tes horaires sont variés — l\'analyse continue de s\'affiner.';
    }
    return 'Rappel intelligent actif · confiance $confidence %';
  }

  String get notifTitle {
    if (predictedHour == null) {
      return 'Ton moment apprentik approche ⏰';
    }
    final h = predictedHour!;
    if (h >= 5 && h < 10) return 'Bonne journée ! Quelques minutes ce matin ?';
    if (h >= 10 && h < 13) return 'Ta pause méritée — et si tu avançais ?';
    if (h >= 13 && h < 18) {
      return "L'élan de l'après-midi — parfait pour apprendre";
    }
    if (h >= 18 && h < 22) {
      return 'La soirée commence — quelques minutes pour toi ?';
    }
    return 'Avant de dormir — ancre ce que tu as appris';
  }

  static const notifBody =
      'Ton programme apprentik t\'attend. Avance à ton rythme, même 5 minutes comptent.';

  static String _mm(int minute) => minute < 10 ? '0$minute' : '$minute';
}

// ---------------------------------------------------------------------------
// Core analysis function
// ---------------------------------------------------------------------------

UsagePattern analyzeUsagePattern(List<int> timestamps) {
  const daysNeeded = 14;
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 30));

  // --- Step 1: one timestamp per day (earliest open) ----------------------
  final byDay = <String, DateTime>{};
  for (final ts in timestamps) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    if (dt.isBefore(cutoff)) continue;
    final key =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    if (!byDay.containsKey(key) || dt.isBefore(byDay[key]!)) {
      byDay[key] = dt;
    }
  }

  final daysCollected = byDay.length;

  // Not enough data yet
  if (daysCollected < 7) {
    return UsagePattern(daysCollected: daysCollected, daysNeeded: daysNeeded);
  }

  // --- Step 2: 30-minute buckets of time-of-day ---------------------------
  final buckets = <int, List<int>>{}; // bucket → [minuteOfDay, ...]
  for (final dt in byDay.values) {
    final mod = dt.hour * 60 + dt.minute;
    final bucket = mod ~/ 30;
    buckets.putIfAbsent(bucket, () => []).add(mod);
  }

  // --- Step 3: dominant bucket --------------------------------------------
  int bestBucket = -1;
  int bestCount = 0;
  for (final e in buckets.entries) {
    if (e.value.length > bestCount) {
      bestCount = e.value.length;
      bestBucket = e.key;
    }
  }

  // Require ≥5 occurrences in peak AND ≥14 days total
  if (bestCount < 5 || daysCollected < daysNeeded) {
    return UsagePattern(
      daysCollected: daysCollected,
      daysNeeded: daysNeeded,
      confidence: bestCount > 0
          ? (bestCount / daysCollected * 60).round().clamp(0, 59)
          : 0,
    );
  }

  // --- Step 4: mean of peak bucket ----------------------------------------
  final vals = buckets[bestBucket]!;
  final meanMod = vals.fold(0, (s, v) => s + v) ~/ vals.length;
  final pHour = meanMod ~/ 60;
  final pMinute = meanMod % 60;

  // --- Step 5: notify 30 min before (wrap around midnight if needed) ------
  var notifyMod = meanMod - 30;
  if (notifyMod < 0) notifyMod += 24 * 60;
  final nHour = notifyMod ~/ 60;
  final nMinute = notifyMod % 60;

  final confidence = (bestCount / daysCollected * 100).clamp(0, 100).round();

  return UsagePattern(
    daysCollected: daysCollected,
    daysNeeded: daysNeeded,
    isReady: true,
    predictedHour: pHour,
    predictedMinute: pMinute,
    notifyHour: nHour,
    notifyMinute: nMinute,
    confidence: confidence,
  );
}
