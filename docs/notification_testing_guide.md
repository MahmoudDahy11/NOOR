# Notification Testing Guide

## Configuration checks

1. Confirm Android package alignment:
   - `android/app/build.gradle.kts` -> `applicationId = "com.example.tally_islamic"`
   - `android/app/google-services.json` -> `client[].client_info.android_client_info.package_name = "com.example.tally_islamic"`
   - `lib/firebase_options.dart` -> `DefaultFirebaseOptions.android` uses app id `1:1012204243775:android:10a1e9f8d7c5d3c39fa18a`
2. Confirm the active notification channel id is `room_started_channel`.
3. Confirm the device has granted notification permission on Android 13+.

## Unit test

Run:

```bash
flutter test test/core/services/local_notification_service_test.dart
```

What it covers:
- Standardized payload JSON generation
- Room id extraction from the JSON payload
- Backward compatibility with legacy raw-string payloads

## Integration-style test

Run:

```bash
flutter test test/core/services/notification_message_handler_test.dart
```

What it covers:
- Simulates an incoming FCM-style `RemoteMessage`
- Verifies `showHeadsUpNotification` would be triggered through the injected callback
- Verifies navigation is skipped when the room id is missing

## Real-device FCM v1 test

1. Fetch an OAuth 2.0 access token for your Firebase service account.
2. Replace `<ACCESS_TOKEN>` and `<FCM_DEVICE_TOKEN>`.
3. Send:

```bash
curl --request POST \
  --url "https://fcm.googleapis.com/v1/projects/suits-d4a64/messages:send" \
  --header "Authorization: Bearer <ACCESS_TOKEN>" \
  --header "Content-Type: application/json" \
  --data '{
    "message": {
      "token": "<FCM_DEVICE_TOKEN>",
      "notification": {
        "title": "Room Started",
        "body": "A live room is waiting for you."
      },
      "data": {
        "roomId": "room-42",
        "route": "/live-room",
        "title": "Room Started",
        "body": "A live room is waiting for you."
      },
      "android": {
        "priority": "high",
        "notification": {
          "channel_id": "room_started_channel",
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    }
  }'
```

Expected result:
- Foreground: app shows a heads-up local notification
- Background: tapping the notification opens the room route
- Terminated: launching from the notification navigates to `/live-room/:roomId`
