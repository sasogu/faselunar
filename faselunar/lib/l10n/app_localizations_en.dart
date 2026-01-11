// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lunar Phase';

  @override
  String get loading => 'Loading lunar data…';

  @override
  String get error => 'Could not load the lunar phase.';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh';

  @override
  String get today => 'Today';

  @override
  String get date => 'Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get lunarCycle => 'Lunar cycle';

  @override
  String get illumination => 'Illumination';

  @override
  String get age => 'Age';

  @override
  String get days => 'days';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get source => 'Source';

  @override
  String get nextFullMoon => 'Next full moon';

  @override
  String get nextNewMoon => 'Next new moon';

  @override
  String get nextQuarter => 'Next quarter';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String remainingDaysHours(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '$hours hour',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String remainingHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '$hours hour',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '$minutes minute',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '$minutes minute',
    );
    return '$_temp0';
  }

  @override
  String get phaseNewMoon => 'New Moon';

  @override
  String get phaseWaxingCrescent => 'Waxing Crescent';

  @override
  String get phaseFirstQuarter => 'First Quarter';

  @override
  String get phaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get phaseFullMoon => 'Full Moon';

  @override
  String get phaseWaningGibbous => 'Waning Gibbous';

  @override
  String get phaseLastQuarter => 'Last Quarter';

  @override
  String get phaseWaningCrescent => 'Waning Crescent';

  @override
  String get phaseUnknown => 'Unknown phase';
}
