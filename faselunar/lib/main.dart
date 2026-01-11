import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'package:faselunar/l10n/app_localizations.dart';

void main() {
  runApp(const MoonApp());
}

class MoonApp extends StatelessWidget {
  const MoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C7DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MoonHomePage(),
    );
  }
}

class MoonHomePage extends StatefulWidget {
  const MoonHomePage({super.key});

  @override
  State<MoonHomePage> createState() => _MoonHomePageState();
}

class _MoonHomePageState extends State<MoonHomePage> {
  final MoonPhaseService _service = MoonPhaseService();
  late Future<MoonPhaseResult> _future;
  late DateTime _selectedDate;

  static const MethodChannel _widgetChannel =
      MethodChannel('com.sasogu.faselunar/widget');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _future = _service.fetch(_selectedDate);
    _requestWidgetUpdate();
  }

  void _refresh() {
    setState(() {
      _future = _service.fetch(_selectedDate);
    });
    _requestWidgetUpdate();
  }

  Future<void> _requestWidgetUpdate() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _widgetChannel.invokeMethod<void>('updateMoonWidget');
      } catch (_) {
        // Ignorar: el widget es opcional.
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: AppLocalizations.of(context)!.selectDate,
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _future = _service.fetch(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _pickDate,
            tooltip: l10n.selectDate,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1023),
              Color(0xFF1C274A),
              Color(0xFF2B335D),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<MoonPhaseResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _StatusView(
                  icon: const CircularProgressIndicator(),
                  message: l10n.loading,
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return _StatusView(
                  icon: const Icon(Icons.cloud_off, size: 40),
                  message: l10n.error,
                  actionLabel: l10n.retry,
                  onAction: _refresh,
                );
              }

              final result = snapshot.data!;
              final locale = Localizations.localeOf(context).toLanguageTag();
              final dateText = DateFormat.yMMMMEEEEd(locale).format(result.date);
              final phaseName = result.type.localizedName(l10n);
              final dateLabel = _isSameDate(result.date, DateTime.now())
                  ? l10n.today
                  : l10n.date;
              final nextFullMoonText =
                  DateFormat.yMMMMEEEEd(locale).format(result.nextFullMoon);
              final remainingText = _formatRemaining(
                result.timeUntilNextFullMoon,
                l10n,
              );
              final nextNewMoonText =
                  DateFormat.yMMMMEEEEd(locale).format(result.nextNewMoon);
              final remainingNewMoonText = _formatRemaining(
                result.timeUntilNextNewMoon,
                l10n,
              );
              final nextQuarterName = result.nextQuarterType.localizedName(l10n);
              final nextQuarterText =
                  DateFormat.yMMMMEEEEd(locale).format(result.nextQuarter);
              final remainingQuarterText = _formatRemaining(
                result.timeUntilNextQuarter,
                l10n,
              );

              final horizontalPadding = MediaQuery.sizeOf(context).width < 360
                  ? 16.0
                  : 24.0;

              return ListView(
                padding:
                    EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 32),
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: MoonPhaseIcon(
                      size: 180,
                      illumination: result.illumination,
                      isWaxing: result.type.isWaxing,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    phaseName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$dateLabel · $dateText',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lunarCycle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (result.age / MoonPhaseService.synodicMonthDays)
                          .clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${result.age.toStringAsFixed(1)} / ${MoonPhaseService.synodicMonthDays.toStringAsFixed(1)} ${l10n.days}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _InfoTile(
                    label: l10n.illumination,
                    value:
                        '${(result.illumination * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.age,
                    value:
                        '${result.age.toStringAsFixed(1)} ${l10n.days}',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.nextFullMoon,
                    value: nextFullMoonText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.timeRemaining,
                    value: remainingText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.nextNewMoon,
                    value: nextNewMoonText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.timeRemaining,
                    value: remainingNewMoonText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.nextQuarter,
                    value: '$nextQuarterName · $nextQuarterText',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: l10n.timeRemaining,
                    value: remainingQuarterText,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.refresh),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final Widget icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white70,
        );
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: valueStyle,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatRemaining(Duration duration, AppLocalizations l10n) {
  final totalMinutes = duration.inMinutes;
  final days = totalMinutes ~/ (60 * 24);
  final hours = (totalMinutes % (60 * 24)) ~/ 60;
  final minutes = totalMinutes % 60;

  if (days > 0) {
    return l10n.remainingDaysHours(days, hours);
  }
  if (hours > 0) {
    return l10n.remainingHoursMinutes(hours, minutes);
  }
  return l10n.remainingMinutes(minutes);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class MoonPhaseIcon extends StatelessWidget {
  const MoonPhaseIcon({
    super.key,
    required this.size,
    required this.illumination,
    required this.isWaxing,
  });

  final double size;
  final double illumination;
  final bool isWaxing;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: MoonPhasePainter(
        illumination: illumination,
        isWaxing: isWaxing,
      ),
    );
  }
}

class MoonPhasePainter extends CustomPainter {
  MoonPhasePainter({required this.illumination, required this.isWaxing});

  final double illumination;
  final bool isWaxing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final clamped = illumination.clamp(0.0, 1.0);
    final darkPaint = Paint()..color = const Color(0xFF0B1023);
    final lightPaint = Paint()..color = const Color(0xFFF6F1D1);

    canvas.drawCircle(center, radius, darkPaint);
    canvas.drawCircle(center, radius, lightPaint);

    final shift = clamped * radius * 2;
    final offset = Offset(isWaxing ? -shift : shift, 0);
    canvas.drawCircle(center + offset, radius, darkPaint);

    final outline = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outline);
  }

  @override
  bool shouldRepaint(MoonPhasePainter oldDelegate) {
    return oldDelegate.illumination != illumination ||
        oldDelegate.isWaxing != isWaxing;
  }
}

enum MoonPhaseType {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
  unknown,
}

extension MoonPhaseTypeX on MoonPhaseType {
  bool get isWaxing {
    switch (this) {
      case MoonPhaseType.waxingCrescent:
      case MoonPhaseType.firstQuarter:
      case MoonPhaseType.waxingGibbous:
        return true;
      default:
        return false;
    }
  }

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case MoonPhaseType.newMoon:
        return l10n.phaseNewMoon;
      case MoonPhaseType.waxingCrescent:
        return l10n.phaseWaxingCrescent;
      case MoonPhaseType.firstQuarter:
        return l10n.phaseFirstQuarter;
      case MoonPhaseType.waxingGibbous:
        return l10n.phaseWaxingGibbous;
      case MoonPhaseType.fullMoon:
        return l10n.phaseFullMoon;
      case MoonPhaseType.waningGibbous:
        return l10n.phaseWaningGibbous;
      case MoonPhaseType.lastQuarter:
        return l10n.phaseLastQuarter;
      case MoonPhaseType.waningCrescent:
        return l10n.phaseWaningCrescent;
      case MoonPhaseType.unknown:
        return l10n.phaseUnknown;
    }
  }
}

class MoonPhaseResult {
  MoonPhaseResult({
    required this.date,
    required this.type,
    required this.illumination,
    required this.age,
    required this.source,
    required this.nextFullMoon,
    required this.timeUntilNextFullMoon,
    required this.nextNewMoon,
    required this.timeUntilNextNewMoon,
    required this.nextQuarter,
    required this.nextQuarterType,
    required this.timeUntilNextQuarter,
  });

  final DateTime date;
  final MoonPhaseType type;
  final double illumination;
  final double age;
  final String source;
  final DateTime nextFullMoon;
  final Duration timeUntilNextFullMoon;
  final DateTime nextNewMoon;
  final Duration timeUntilNextNewMoon;
  final DateTime nextQuarter;
  final MoonPhaseType nextQuarterType;
  final Duration timeUntilNextQuarter;
}

class MoonPhaseService {
  static const String _apiSource = 'Local';
  static const double synodicMonthDays = 29.53058867;
  static final DateTime _referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  static const double _fullMoonAgeDays = synodicMonthDays / 2;
  static const double _firstQuarterAgeDays = synodicMonthDays / 4;
  static const double _lastQuarterAgeDays = synodicMonthDays * 3 / 4;

  Future<MoonPhaseResult> fetch(DateTime date) async {
    final (type, age, illumination) = _calculate(date);
    final (nextFullMoon, untilFullMoon) = _nextFullMoon(date, age);
    final (nextNewMoon, untilNewMoon) = _nextNewMoon(date, age);
    final (nextQuarter, nextQuarterType, untilQuarter) = _nextQuarter(date, age);
    return MoonPhaseResult(
      date: date,
      type: type,
      illumination: illumination,
      age: age,
      source: _apiSource,
      nextFullMoon: nextFullMoon,
      timeUntilNextFullMoon: untilFullMoon,
      nextNewMoon: nextNewMoon,
      timeUntilNextNewMoon: untilNewMoon,
      nextQuarter: nextQuarter,
      nextQuarterType: nextQuarterType,
      timeUntilNextQuarter: untilQuarter,
    );
  }

  /// Returns: (type, ageDays, illumination[0..1])
  (MoonPhaseType, double, double) _calculate(DateTime date) {
    final secondsSinceRef =
        date.toUtc().difference(_referenceNewMoon).inSeconds.toDouble();
    final daysSinceRef = secondsSinceRef / Duration.secondsPerDay;
    var age = daysSinceRef % synodicMonthDays;
    if (age < 0) {
      age += synodicMonthDays;
    }

    // Approximate illumination: 0=new, 1=full.
    final phaseAngle = 2 * math.pi * (age / synodicMonthDays);
    final illumination = (0.5 * (1 - math.cos(phaseAngle))).clamp(0.0, 1.0);

    // Phase buckets by age in days (common approximation thresholds).
    final type = switch (age) {
      < 1.84566 => MoonPhaseType.newMoon,
      < 5.53699 => MoonPhaseType.waxingCrescent,
      < 9.22831 => MoonPhaseType.firstQuarter,
      < 12.91963 => MoonPhaseType.waxingGibbous,
      < 16.61096 => MoonPhaseType.fullMoon,
      < 20.30228 => MoonPhaseType.waningGibbous,
      < 23.99361 => MoonPhaseType.lastQuarter,
      < 27.68493 => MoonPhaseType.waningCrescent,
      _ => MoonPhaseType.newMoon,
    };

    return (type, age, illumination);
  }

  (DateTime, Duration) _nextFullMoon(DateTime from, double ageDays) {
    final double daysUntil;
    if (ageDays <= _fullMoonAgeDays) {
      daysUntil = _fullMoonAgeDays - ageDays;
    } else {
      daysUntil = synodicMonthDays - ageDays + _fullMoonAgeDays;
    }

    final seconds = (daysUntil * Duration.secondsPerDay).round();
    final duration = Duration(seconds: seconds);
    return (from.add(duration), duration);
  }

  (DateTime, Duration) _nextNewMoon(DateTime from, double ageDays) {
    final daysUntil = ageDays == 0 ? synodicMonthDays : (synodicMonthDays - ageDays);
    final seconds = (daysUntil * Duration.secondsPerDay).round();
    final duration = Duration(seconds: seconds);
    return (from.add(duration), duration);
  }

  (DateTime, MoonPhaseType, Duration) _nextQuarter(DateTime from, double ageDays) {
    final (targetAge, type) = ageDays <= _firstQuarterAgeDays
        ? (_firstQuarterAgeDays, MoonPhaseType.firstQuarter)
        : (ageDays <= _lastQuarterAgeDays
            ? (_lastQuarterAgeDays, MoonPhaseType.lastQuarter)
        : (synodicMonthDays + _firstQuarterAgeDays, MoonPhaseType.firstQuarter));

    final daysUntil = targetAge - ageDays;
    final seconds = (daysUntil * Duration.secondsPerDay).round();
    final duration = Duration(seconds: seconds);
    return (from.add(duration), type, duration);
  }
}
