import 'dart:io' show Platform;
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/callkit/defines.dart';
import 'package:zego_zimkit/src/callkit/variables.dart';
import 'package:zego_zimkit/src/channel/defines.dart';
import 'package:zego_zimkit/src/channel/platform_interface.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';

/// @nodoc
class ZegoZIMKitNotificationManager {
  factory ZegoZIMKitNotificationManager() => instance;

  ZegoZIMKitNotificationManager._internal();

  static ZegoZIMKitNotificationManager instance =
      ZegoZIMKitNotificationManager._internal();

  bool _isInit = false;
  ZegoZIMKitNotificationConfig? _notificationConfig;

  String? get resourceID => _notificationConfig?.resourceID;

  String get channelID =>
      _notificationConfig?.androidNotificationConfig?.channelID ??
      defaultZIMKitMessageChannelID;

  String get channelName =>
      _notificationConfig?.androidNotificationConfig?.channelName ??
      defaultZIMKitMessageChannelName;

  Future<void> init({
    ZegoZIMKitNotificationConfig? notificationConfig,
  }) async {
    if (_isInit) {
      ZIMKitLogger.info('notification manager, init already');

      return;
    }

    _isInit = true;
    _notificationConfig = notificationConfig;

    ZIMKitLogger.info('notification manager, init');

    await requestPermission(Permission.notification).then((value) {
      ZIMKitLogger.info(
          'notification manager, request notification permission result:$value');
    });

    /// for bring app to foreground from background in Android 10
    await requestPermission(Permission.systemAlertWindow).then((value) {
      ZIMKitLogger.info(
          'notification manager, request system alert window permission result:$value');
    });

    await ZegoZIMKitPluginPlatform.instance.createNotificationChannel(
      ZegoZIMKitPluginLocalNotificationChannelConfig(
        channelID: channelID,
        channelName: channelName,
        soundSource: getSoundSource(
          _notificationConfig?.androidNotificationConfig?.sound,
        ),
      ),
    );

    await ZegoZIMKitPluginPlatform.instance.dismissAllNotifications();
  }

  Future<void> cancelAll() async {
    ZIMKitLogger.info('notification manager, cancelAll');

    /// clear notifications
    await ZegoZIMKitPluginPlatform.instance.dismissAllNotifications();
  }

  void uninit() {
    ZIMKitLogger.info('notification manager, uninit');

    _isInit = false;
    _notificationConfig = null;

    cancelAll();
  }

  void showInvitationNotification(ZIMKitReceivedMessages? messages) {
    if (!_isInit) {
      ZIMKitLogger.warning('notification manager, not init');
    }

    ZegoZIMKitPluginPlatform.instance.dismissAllNotifications();

    messages?.receiveMessages.forEach((message) async {
      var content = '[${message.type.name}]';
      if (ZIMKitMessageType.text == message.type) {
        content = message.textContent?.text ?? '';
      }

      var senderName = '';
      await ZIMKit()
          .queryUser(message.info.senderUserID)
          .then((ZIMUserFullInfo zimResult) {
        senderName = zimResult.baseInfo.userName;
      });
      await ZegoZIMKitPluginPlatform.instance.addLocalNotification(
        ZegoZIMKitPluginLocalNotificationConfig(
          id: Random().nextInt(2147483647),
          channelID: defaultZIMKitMessageChannelID,
          title: senderName,
          content: content,
          vibrate:
              _notificationConfig?.androidNotificationConfig?.vibrate ?? false,
          iconSource: getIconSource(
            _notificationConfig?.androidNotificationConfig?.icon,
          ),
          soundSource: getSoundSource(
            _notificationConfig?.androidNotificationConfig?.sound,
          ),
          clickCallback: () async {
            await ZegoZIMKitPluginPlatform.instance.activeAppToForeground();
            await ZegoZIMKitPluginPlatform.instance.requestDismissKeyguard();
            await ZegoZIMKitPluginPlatform.instance.dismissAllNotifications();
          },
        ),
      );
    });
  }

  static String? getIconSource(String? iconFileName) {
    String? iconSource;

    if (Platform.isAndroid && (iconFileName?.isNotEmpty ?? false)) {
      var targetIconFileName = iconFileName ?? '';
      final postfixIndex = targetIconFileName.indexOf('.');
      if (-1 != postfixIndex) {
        targetIconFileName = targetIconFileName.substring(0, postfixIndex);
      }

      iconSource = 'resource://drawable/$targetIconFileName';

      ZIMKitLogger.info("icon file, config name:${iconFileName ?? ""}, "
          'file name:$targetIconFileName, source:$iconSource');
    }

    return iconSource;
  }

  static String? getSoundSource(String? soundFileName) {
    String? soundSource;

    if (Platform.isAndroid && (soundFileName?.isNotEmpty ?? false)) {
      var targetSoundFileName = soundFileName ?? '';
      final postfixIndex = targetSoundFileName.indexOf('.');
      if (-1 != postfixIndex) {
        targetSoundFileName = targetSoundFileName.substring(0, postfixIndex);
      }

      soundSource = 'resource://raw/$targetSoundFileName';

      ZIMKitLogger.info("sound file, config name:${soundFileName ?? ""}, "
          'file name:$targetSoundFileName, source:$soundSource');
    }

    return soundSource;
  }

  /// @nodoc
  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus? status;
    try {
      status = await permission.request();
    } catch (e) {
      ZIMKitLogger.info(
          'notification manager, Exception: $permission permission not granted, $e');
    }

    if (status != PermissionStatus.granted) {
      ZIMKitLogger.info(
          'notification manager, Error: $permission permission not granted, $status');
      return false;
    }

    return true;
  }
}
