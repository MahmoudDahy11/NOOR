import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/core/constants/app_keys.dart';
import 'package:tally_islamic/core/router/app_router.dart';
import 'package:tally_islamic/core/services/local_notification_service.dart';

void main() {
  group('LocalNotificationService payload helpers', () {
    test('buildRoomPayload returns clean JSON structure', () {
      final payload = LocalNotificationService.buildRoomPayload('room-42');

      expect(payload, isNotNull);

      final decoded = jsonDecode(payload!) as Map<String, dynamic>;
      expect(decoded[AppKeys.notificationRoute], AppRouter.liveRoomRoute);
      expect(decoded[AppKeys.notificationRoomId], 'room-42');
    });

    test('extractRoomIdFromPayload reads standardized payload', () {
      final payload = jsonEncode({
        AppKeys.notificationRoute: AppRouter.liveRoomRoute,
        AppKeys.notificationRoomId: 'room-99',
      });

      expect(
        LocalNotificationService.extractRoomIdFromPayload(payload),
        'room-99',
      );
    });

    test('extractRoomIdFromPayload supports legacy raw room id payloads', () {
      expect(
        LocalNotificationService.extractRoomIdFromPayload('legacy-room-id'),
        'legacy-room-id',
      );
    });
  });
}
