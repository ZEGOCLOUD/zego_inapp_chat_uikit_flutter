import 'dart:io' show Platform;

import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/src/callkit/handler.android.dart';
import 'package:zego_zimkit/src/callkit/notification_manager.dart';
import 'package:zego_zimkit/src/callkit/variables.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/utils/share_pref.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

mixin ZIMKitOfflineMessage {
  Future<void> initOfflineMessage({
    ZegoZIMKitNotificationConfig? notificationConfig,
  }) async {
    ZIMKitLogger.info(
      'init offline message, config:$notificationConfig',
    );

    ZegoPluginAdapter().installPlugins([ZegoUIKitSignalingPlugin()]);

    await ZegoPluginAdapter()
        .signalingPlugin
        ?.enableNotifyWhenAppRunningInBackgroundOrQuit(
          isIOSSandboxEnvironment:
              notificationConfig?.iosNotificationConfig?.isSandboxEnvironment,
          enableIOSVoIP: false,
          certificateIndex:
              notificationConfig?.iosNotificationConfig?.certificateIndex ??
                  ZegoSignalingPluginMultiCertificate.firstCertificate,
          appName: '',
          androidChannelID:
              notificationConfig?.androidNotificationConfig?.channelID ??
                  defaultZIMKitMessageChannelID,
          androidChannelName:
              notificationConfig?.androidNotificationConfig?.channelName ??
                  defaultZIMKitMessageChannelName,
          androidSound: (notificationConfig
                      ?.androidNotificationConfig?.sound?.isEmpty ??
                  true)
              ? ''
              : '/raw/${notificationConfig?.androidNotificationConfig?.sound}',
        )
        .then(
      (result) {
        ZIMKitLogger.info('enable notification result: $result');
      },
    );

    if (Platform.isAndroid) {
      ZIMKitLogger.info(
        'offline message, register background message handler',
      );

      await ZegoPluginAdapter()
          .signalingPlugin
          ?.setBackgroundMessageHandler(onBackgroundMessageReceived);
    } else if (Platform.isIOS) {
      ///
    }

    await initNotification(
      notificationConfig: notificationConfig,
    );
  }

  Future<void> initNotification({
    ZegoZIMKitNotificationConfig? notificationConfig,
  }) async {
    if (!(notificationConfig?.supportOfflineMessage ?? false)) {
      ZIMKitLogger.info(
        'background message, but not support background message',
      );

      return;
    }

    await setPreferenceString(
      serializationKeyHandlerPrivateInfo,
      ZimKitHandlerPrivateInfo(
        channelID: notificationConfig?.androidNotificationConfig?.channelID ??
            defaultZIMKitMessageChannelID,
        channelName:
            notificationConfig?.androidNotificationConfig?.channelName ??
                defaultZIMKitMessageChannelName,
        sound: notificationConfig?.androidNotificationConfig?.sound ?? '',
        icon: notificationConfig?.androidNotificationConfig?.icon ?? '',
        isVibrate:
            notificationConfig?.androidNotificationConfig?.vibrate ?? false,
      ).toJsonString(),
    );

    await ZegoZIMKitNotificationManager.instance.init(
      notificationConfig: notificationConfig,
    );
  }
}
