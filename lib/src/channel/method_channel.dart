import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:zego_zimkit/src/channel/defines.dart';
import 'package:zego_zimkit/src/channel/platform_interface.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';

/// @nodoc
/// An implementation of [ZegoCallPluginPlatform] that uses method channels.
class MethodChannelZegoCallPlugin extends ZegoZIMKitPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zimkit_plugin');

  /// add local IM notification
  /// only support android
  @override
  Future<void> addLocalNotification(
    ZegoZIMKitPluginLocalNotificationConfig config,
  ) async {
    if (Platform.isIOS) {
      ZIMKitLogger.info('addLocalNotification, not support in iOS');

      return;
    }

    ZIMKitLogger.info('addLocalNotification:$config');

    try {
      await methodChannel.invokeMethod('addLocalNotification', {
        'id': config.id.toString(),
        'sound_source': config.soundSource ?? '',
        'icon_source': config.iconSource ?? '',
        'vibrate': config.vibrate,
        'channel_id': config.channelID,
        'title': config.title,
        'content': config.content,
      });

      /// set buttons callback
      methodChannel.setMethodCallHandler((call) async {
        ZIMKitLogger.info(
            'MethodCallHandler, method:${call.method}, arguments:${call.arguments}.');

        switch (call.method) {
          case 'onNotificationClicked':
            config.clickCallback?.call();
        }
      });
    } on PlatformException catch (e) {
      ZIMKitLogger.warning('Failed to add local notification: $e.');
    }
  }

  /// create notification channel
  /// only support android
  @override
  Future<void> createNotificationChannel(
    ZegoZIMKitPluginLocalNotificationChannelConfig config,
  ) async {
    if (Platform.isIOS) {
      ZIMKitLogger.info('createNotificationChannel, not support in iOS');

      return;
    }

    ZIMKitLogger.info(
      'createNotificationChannel:$config',
    );

    try {
      await methodChannel.invokeMethod('createNotificationChannel', {
        'channel_id': config.channelID,
        'channel_name': config.channelName,
        'sound_source': config.soundSource ?? '',
        'vibrate': config.vibrate,
      });
    } on PlatformException catch (e) {
      ZIMKitLogger.warning('Failed to create notification channel: $e.');
    }
  }

  /// dismiss all notifications
  /// only support android
  @override
  Future<void> dismissAllNotifications() async {
    if (Platform.isIOS) {
      ZIMKitLogger.info('dismissAllNotifications, not support in iOS');

      return;
    }

    ZIMKitLogger.info('dismissAllNotifications');

    try {
      await methodChannel.invokeMethod('dismissAllNotifications', {});
    } on PlatformException catch (e) {
      ZIMKitLogger.warning('Failed to dismiss all notifications: $e.');
    }
  }

  /// active app to foreground
  /// only support android
  @override
  Future<void> activeAppToForeground() async {
    if (Platform.isIOS) {
      ZIMKitLogger.info('activeAppToForeground, not support in iOS');

      return;
    }

    ZIMKitLogger.info('activeAppToForeground');

    try {
      await methodChannel.invokeMethod('activeAppToForeground', {});
    } on PlatformException catch (e) {
      ZIMKitLogger.warning('Failed to active app to foreground: $e.');
    }
  }

  /// request dismiss keyguard
  /// only support android
  @override
  Future<void> requestDismissKeyguard() async {
    if (Platform.isIOS) {
      ZIMKitLogger.info('requestDismissKeyguard, not support in iOS');

      return;
    }

    ZIMKitLogger.info('requestDismissKeyguard');

    try {
      await methodChannel.invokeMethod('requestDismissKeyguard', {});
    } on PlatformException catch (e) {
      ZIMKitLogger.warning('Failed to request dismiss keyguard: $e.');
    }
  }

  @override
  Future<bool> isLockScreen() async {
    if (Platform.isIOS) {
      ZIMKitLogger.info('isLockScreen, not support in iOS');
      return false;
    }

    var isLock = false;
    try {
      isLock = await methodChannel.invokeMethod<bool?>('isLockScreen') ?? false;
    } on PlatformException catch (e) {
      ZIMKitLogger.warning('Failed to check isLock: $e.');
    }

    return isLock;
  }
}
