import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

class ZegoZIMKitNotificationConfig {
  /// The [resource id] for notification which same as [Zego Console](https://console.zegocloud.com/)
  String? resourceID;

  ///
  bool supportOfflineMessage;

  ///
  ZegoZIMKitAndroidNotificationConfig? androidNotificationConfig;

  ///
  ZegoZIMKitIOSNotificationConfig? iosNotificationConfig;

  ZegoZIMKitNotificationConfig({
    this.resourceID,
    this.supportOfflineMessage = true,
    this.androidNotificationConfig,
    this.iosNotificationConfig,
  });

  @override
  String toString() {
    return 'resource id:$resourceID, '
        'supportOfflineMessage:$supportOfflineMessage, '
        'androidNotificationConfig:$androidNotificationConfig, '
        'iosNotificationConfig:$iosNotificationConfig';
  }
}

/// android notification config
class ZegoZIMKitAndroidNotificationConfig {
  /// specify the channel id of notification
  String channelID;

  /// specify the channel name of notification
  String channelName;

  /// specify the icon file name id of notification,
  /// Additionally, you must place your icon file in the following path:
  /// ${project_root}/android/app/src/main/res/drawable/${icon}.png
  String? icon;

  /// specify the sound file name id of notification,
  /// Additionally, you must place your audio file in the following path:
  /// ${project_root}/android/app/src/main/res/raw/${sound}.mp3
  String? sound;

  bool vibrate;

  ZegoZIMKitAndroidNotificationConfig({
    this.channelID = 'ZIM Message',
    this.channelName = 'Message',
    this.icon = '',
    this.sound = '',
    this.vibrate = false,
  });
}

/// iOS notification config
class ZegoZIMKitIOSNotificationConfig {
  /// is iOS sandbox or not
  bool? isSandboxEnvironment;

  ZegoSignalingPluginMultiCertificate certificateIndex;

  ZegoZIMKitIOSNotificationConfig({
    this.isSandboxEnvironment,
    this.certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
  });

  @override
  String toString() {
    return 'isSandboxEnvironment:$isSandboxEnvironment, '
        'certificateIndex:$certificateIndex ';
  }
}
