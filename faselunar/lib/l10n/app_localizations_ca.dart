// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Fase lunar';

  @override
  String get loading => 'Carregant dades lunars…';

  @override
  String get error => 'No s\'ha pogut carregar la fase lunar.';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String get refresh => 'Actualitza';

  @override
  String get today => 'Hui';

  @override
  String get date => 'Data';

  @override
  String get selectDate => 'Selecciona una data';

  @override
  String get lunarCycle => 'Cicle lunar';

  @override
  String get illumination => 'Il·luminació';

  @override
  String get age => 'Edat';

  @override
  String get days => 'dies';

  @override
  String get hours => 'hores';

  @override
  String get minutes => 'minuts';

  @override
  String get source => 'Font';

  @override
  String get nextFullMoon => 'Pròxima lluna plena';

  @override
  String get nextNewMoon => 'Pròxima lluna nova';

  @override
  String get nextQuarter => 'Pròxim quart';

  @override
  String get timeRemaining => 'Temps restant';

  @override
  String remainingDaysHours(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dies',
      one: '$days dia',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hores',
      one: '$hours hora',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String remainingHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hores',
      one: '$hours hora',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minuts',
      one: '$minutes minut',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minuts',
      one: '$minutes minut',
    );
    return '$_temp0';
  }

  @override
  String get phaseNewMoon => 'Lluna nova';

  @override
  String get phaseWaxingCrescent => 'Lluna creixent';

  @override
  String get phaseFirstQuarter => 'Quart creixent';

  @override
  String get phaseWaxingGibbous => 'Gibosa creixent';

  @override
  String get phaseFullMoon => 'Lluna plena';

  @override
  String get phaseWaningGibbous => 'Gibosa minvant';

  @override
  String get phaseLastQuarter => 'Quart minvant';

  @override
  String get phaseWaningCrescent => 'Lluna minvant';

  @override
  String get phaseUnknown => 'Fase desconeguda';
}
