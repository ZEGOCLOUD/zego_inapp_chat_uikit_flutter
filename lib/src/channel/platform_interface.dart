import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:zego_zimkit/src/channel/defines.dart';
import 'package:zego_zimkit/src/channel/method_channel.dart';

/// @nodoc
abstract class ZegoZIMKitPluginPlatform extends PlatformInterface {
  /// Constructs a ZegoZIMKitPluginPlatform.
  ZegoZIMKitPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZegoZIMKitPluginPlatform _instance = MethodChannelZegoCallPlugin();

  /// The default instance of [ZegoZIMKitPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUntitled].
  static ZegoZIMKitPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZegoZIMKitPluginPlatform] when
  /// they register themselves.
  static set instance(ZegoZIMKitPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// addLocalIMNotification
  Future<void> addLocalNotification(
    ZegoZIMKitPluginLocalNotificationConfig config,
  ) {
    throw UnimplementedError('addLocalNotification has not been implemented.');
  }

  /// createNotificationChannel
  Future<void> createNotificationChannel(
    ZegoZIMKitPluginLocalNotificationChannelConfig config,
  ) {
    throw UnimplementedError(
        'createNotificationChannel has not been implemented.');
  }

  /// dismissAllNotifications
  Future<void> dismissAllNotifications() {
    throw UnimplementedError(
        'dismissAllNotifications has not been implemented.');
  }

  /// activeAppToForeground
  Future<void> activeAppToForeground() {
    throw UnimplementedError('activeAppToForeground has not been implemented.');
  }

  Future<void> requestDismissKeyguard() {
    throw UnimplementedError(
        'requestDismissKeyguard has not been implemented.');
  }

  Future<bool> isLockScreen() {
    throw UnimplementedError('isLockScreen has not been implemented.');
  }
}
