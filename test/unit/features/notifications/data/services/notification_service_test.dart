import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sorutrack_pro/features/notifications/data/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'notification_service_test.mocks.dart';

@GenerateMocks([
  NotificationService,
], customMocks: [
  MockSpec<FlutterLocalNotificationsPlugin>(onMissingStub: OnMissingStub.returnDefault),
])
void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService service;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = NotificationService(mockPlugin);
  });

  group('NotificationService', () {
    test('cancelAllNotifications calls plugin.cancelAll', () async {
      await service.cancelAllNotifications();
      verify(mockPlugin.cancelAll()).called(1);
    });

    test('cancelNotification calls plugin.cancel with id', () async {
      await service.cancelNotification(123);
      verify(mockPlugin.cancel(id: 123)).called(1);
    });

    test('showNotification calls plugin.show with correct details', () async {
      await service.showNotification(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      verify(mockPlugin.show(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('scheduleNotification calls plugin.zonedSchedule', () async {
      final date = DateTime.now().add(const Duration(hours: 1));
      
      await service.scheduleNotification(
        id: 2,
        title: 'Sched Title',
        body: 'Sched Body',
        scheduledDate: date,
      );

      verify(mockPlugin.zonedSchedule(
        id: 2,
        title: 'Sched Title',
        body: 'Sched Body',
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      )).called(1);
    });
  });
}
