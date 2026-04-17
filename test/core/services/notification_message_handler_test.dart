import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/core/constants/app_keys.dart';
import 'package:tally_islamic/core/services/notification_message_handler.dart';

void main() {
  group('NotificationMessageHandler', () {
    test(
      'handleForegroundMessage triggers heads-up notification callback',
      () async {
        const message = RemoteMessage(
          messageId: 'message-1',
          data: {
            AppKeys.notificationRoomId: 'room-7',
            AppKeys.notificationTitle: 'Room Started',
            AppKeys.notificationBody: 'Join now',
          },
        );

        var wasCalled = false;
        int? actualId;
        String? actualTitle;
        String? actualBody;
        String? actualPayload;

        await NotificationMessageHandler.handleForegroundMessage(
          message,
          showNotification:
              ({
                required int id,
                required String title,
                required String body,
                String? payload,
              }) async {
                wasCalled = true;
                actualId = id;
                actualTitle = title;
                actualBody = body;
                actualPayload = payload;
              },
        );

        expect(wasCalled, isTrue);
        expect(actualId, isNotNull);
        expect(actualTitle, 'Room Started');
        expect(actualBody, 'Join now');
        expect(actualPayload, contains('"roomId":"room-7"'));
      },
    );

    test(
      'navigateFromMessage skips navigation when room id is missing',
      () async {
        const message = RemoteMessage(
          messageId: 'message-2',
          data: {AppKeys.notificationTitle: 'No room'},
        );

        var navigationCalls = 0;

        await NotificationMessageHandler.navigateFromMessage(
          message,
          navigateToRoom: (roomId) async {
            navigationCalls++;
          },
        );

        expect(navigationCalls, 0);
      },
    );
  });
}
