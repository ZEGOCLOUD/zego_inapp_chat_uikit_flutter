import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_zpns/zego_zpns.dart';

import 'package:zego_zimkit/src/callkit/notification_manager.dart';
import 'package:zego_zimkit/src/callkit/variables.dart';
import 'package:zego_zimkit/src/channel/defines.dart';
import 'package:zego_zimkit/src/channel/platform_interface.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';
import 'package:zego_zimkit/src/utils/share_pref.dart';

const backgroundMessageIsolatePortName = 'zimkit_bg_msg_isolate_port';

/// @nodoc
///
/// [Android] Silent Notification event notify
///
/// Note: @pragma('vm:entry-point') must be placed on a function to indicate that it can be parsed, allocated, or called directly from native or VM code in AOT mode.
@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(ZPNsMessage message) async {
  ZIMKitLogger.info(
    'background message, '
    'received: '
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}',
  );

  if (!message.extras.containsKey('zego')) {
    ZIMKitLogger.info(
        '[onBackgroundMessageReceived] is not zego protocol, droped');
    return;
  }

  final registeredIsolatePort =
      IsolateNameServer.lookupPortByName(backgroundMessageIsolatePortName);
  final isAppRunning = null != registeredIsolatePort;
  ZIMKitLogger.info(
      'isolate:${registeredIsolatePort?.hashCode}, isAppRunning:$isAppRunning');
  if (isAppRunning) {
    /// after app being screen-locked for more than 10 minutes, the app was not
    /// killed(suspended) but the zpns login timed out, so that's why receive
    /// offline call when app was alive.
    ///
    /// At this time, because the fcm push will make the Dart open another isolate (thread) to process,
    /// it will cause the problem of double opening of the app.
    ///
    /// So, send this offline call to [ZegoUIKitPrebuiltCallInvitationService] to handle.
    ZIMKitLogger.info(
      'background message, '
      'isolate:app has another isolate(${registeredIsolatePort.hashCode}), '
      'send command to deal with this background message',
    );
    registeredIsolatePort.send(jsonEncode({
      'title': message.title,
      'extras': message.extras,
    }));
    return;
  }

  final backgroundPort = ReceivePort();
  IsolateNameServer.registerPortWithName(
    backgroundPort.sendPort,
    backgroundMessageIsolatePortName,
  );
  backgroundPort.listen((dynamic message) async {
    ZIMKitLogger.info(
      'background message, '
      'isolate: current port(${backgroundPort.hashCode}) receive, '
      'message:$message',
    );

    final messageMap = jsonDecode(message) as Map<String, dynamic>;

    final messageTitle = messageMap['title'] as String? ?? '';
    final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

    _onBackgroundMessageReceived(
      messageTitle: messageTitle,
      messageExtras: messageExtras,
      fromOtherIsolate: true,
      backgroundPort: backgroundPort,
    );
  });
  ZIMKitLogger.info(
    'background message, '
    'isolate: register and listen port(${backgroundPort.hashCode}), '
    'send command to deal with this background message',
  );

  _onBackgroundMessageReceived(
    messageTitle: message.title,
    messageExtras: message.extras,
    fromOtherIsolate: false,
    backgroundPort: backgroundPort,
  );
}

Future<void> _onBackgroundMessageReceived({
  required String messageTitle,
  required Map<String, Object?> messageExtras,
  required bool fromOtherIsolate,
  required ReceivePort backgroundPort,
}) async {
  final payload = messageExtras['payload'] as String? ?? '';
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>? ?? {};

  final operationType = BackgroundMessageTypeExtension.fromText(
      payloadMap[ZIMKitInvitationProtocolKey.operationType] as String? ?? '');

  if (BackgroundMessageType.textMessage != operationType &&
      BackgroundMessageType.mediaMessage != operationType) {
    return;
  }

  final body = messageExtras['body'] as String? ?? '';

  final conversationID = payloadMap['id'] as String? ?? '';
  final conversationTypeIndex = payloadMap['type'] as int? ?? -1;

  final senderInfo = payloadMap['sender'] as Map<String, dynamic>? ?? {};
  // final senderID = senderInfo['id'] as String? ?? '';
  final senderName = senderInfo['name'] as String? ?? '';

  ZIMKitLogger.info(
    'background message, '
    'im message received, '
    'body:$body, conversationID:$conversationID, '
    'conversationTypeIndex:$conversationTypeIndex',
  );

  final handlerInfoJson =
      await getPreferenceString(serializationKeyHandlerPrivateInfo);
  ZIMKitLogger.info(
    'background message, '
    'parsing handler info:$handlerInfoJson',
  );
  final handlerInfo = ZimKitHandlerPrivateInfo.fromJsonString(handlerInfoJson);

  await ZegoZIMKitPluginPlatform.instance.addLocalNotification(
    ZegoZIMKitPluginLocalNotificationConfig(
      id: Random().nextInt(2147483647),
      channelID: handlerInfo?.channelID ?? defaultZIMKitMessageChannelID,
      title: senderName,
      content: body,
      vibrate: handlerInfo?.isVibrate ?? false,
      iconSource: ZegoZIMKitNotificationManager.getIconSource(
        handlerInfo?.icon ?? '',
      ),
      soundSource: ZegoZIMKitNotificationManager.getSoundSource(
        handlerInfo?.sound ?? '',
      ),
      clickCallback: () async {
        await ZegoZIMKitPluginPlatform.instance.activeAppToForeground();
        await ZegoZIMKitPluginPlatform.instance.requestDismissKeyguard();
      },
    ),
  );

  ZIMKitLogger.info(
    'background message, '
    'isolate: clear IsolateNameServer, port:${backgroundPort.hashCode}',
  );
  backgroundPort.close();
  IsolateNameServer.removePortNameMapping(
    backgroundMessageIsolatePortName,
  );
}
