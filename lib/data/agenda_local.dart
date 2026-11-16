import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:healthrisk_mobile/data/agenda.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class AgendaLocal implements AgendaAlarmes {
  AgendaLocal(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _canalMed = 'medicamentos';
  static const _canalConsulta = 'consultas';

  static Future<AgendaLocal> criar() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _canalMed,
        'Medicamentos',
        description: 'Lembrete de dose',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _canalConsulta,
        'Consultas',
        description: 'Lembrete de consulta (24 h e 2 h)',
        importance: Importance.defaultImportance,
      ),
    );
    await android?.requestNotificationsPermission();
    return AgendaLocal(plugin);
  }

  @override
  Future<void> agendar({
    required int id,
    required DateTime quando,
    required String canal,
    required String texto,
  }) async {
    final alto = canal == _canalMed;
    final quandoTz = tz.TZDateTime.from(quando, tz.local);
    if (!quandoTz.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id,
        'HealthRisk',
        texto,
        quandoTz,
        NotificationDetails(
          android: AndroidNotificationDetails(
            canal,
            alto ? 'Medicamentos' : 'Consultas',
            channelDescription: alto ? 'Lembrete de dose' : 'Lembrete de consulta',
            importance: alto ? Importance.high : Importance.defaultImportance,
            priority: alto ? Priority.high : Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: alto ? DateTimeComponents.time : null,
      );
    } catch (_) {}
  }

  @override
  Future<void> cancelar(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelarTodos() => _plugin.cancelAll();
}
