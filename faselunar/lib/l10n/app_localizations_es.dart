// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fase lunar';

  @override
  String get loading => 'Cargando datos lunares…';

  @override
  String get error => 'No se pudo cargar la fase lunar.';

  @override
  String get retry => 'Reintentar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get today => 'Hoy';

  @override
  String get date => 'Fecha';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get lunarCycle => 'Ciclo lunar';

  @override
  String get illumination => 'Iluminación';

  @override
  String get age => 'Edad';

  @override
  String get days => 'días';

  @override
  String get hours => 'horas';

  @override
  String get minutes => 'minutos';

  @override
  String get source => 'Fuente';

  @override
  String get nextFullMoon => 'Próxima luna llena';

  @override
  String get nextNewMoon => 'Próxima luna nueva';

  @override
  String get nextQuarter => 'Próximo cuarto';

  @override
  String get timeRemaining => 'Tiempo restante';

  @override
  String remainingDaysHours(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '$hours hora',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String remainingHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '$hours hora',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return '$_temp0';
  }

  @override
  String get phaseNewMoon => 'Luna nueva';

  @override
  String get phaseWaxingCrescent => 'Luna creciente';

  @override
  String get phaseFirstQuarter => 'Cuarto creciente';

  @override
  String get phaseWaxingGibbous => 'Gibosa creciente';

  @override
  String get phaseFullMoon => 'Luna llena';

  @override
  String get phaseWaningGibbous => 'Gibosa menguante';

  @override
  String get phaseLastQuarter => 'Cuarto menguante';

  @override
  String get phaseWaningCrescent => 'Luna menguante';

  @override
  String get phaseUnknown => 'Fase desconocida';
}
