import 'package:flutter/material.dart';
import 'package:zego_imkit/services/services.dart';

import '../common/common.dart';
import 'audio_message.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'text_message.dart';
import 'video_message.dart';
import 'widgets/widgets.dart';

export 'audio_message.dart';
export 'text_message.dart';
export 'video_message.dart';

class ZegoIMKitMessageWidget extends StatelessWidget {
  const ZegoIMKitMessageWidget({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
  }) : super(key: key);

  final ZegoIMKitMessage message;
  final Widget Function(
          BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)?
      avatarBuilder;
  final Widget Function(
          BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)?
      statusBuilder;
  final Widget Function(
          BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)?
      timestampBuilder;
  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onLongPress;

  // TODO default onPressed onLongPress action
  // TODO custom meesage
  Widget buildMessage(BuildContext context, ZegoIMKitMessage message) {
    switch (message.data.value.type) {
      case ZIMMessageType.text:
        return ZegoTextMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.audio:
        return ZegoAudioMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.video:
        return ZegoVideoMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.file:
        return ZegoFileMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.image:
        return ZegoImageMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);

      default:
        return Text(message.data.value.type.toString());
    }
  }

  Widget buildStatus(BuildContext context, ZegoIMKitMessage message) {
    Widget defaultStatusWidget = ZegoMessageStatusDot(message);
    return statusBuilder?.call(context, message, defaultStatusWidget) ??
        defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context, ZegoIMKitMessage message) {
    Widget defaultAvatarWidget =
        ZegoIMKitAvatar(userID: message.senderUserID, width: 50, height: 50);
    return avatarBuilder?.call(context, message, defaultAvatarWidget) ??
        defaultAvatarWidget;
  }

  // TODO how to custom laytout
  // TODO timestamp
  List<Widget> localMessage(BuildContext context, ZegoIMKitMessage message) {
    return [
      buildMessage(context, message),
      // buildAvatar(context, message),
      buildStatus(context, message),
    ];
  }

  List<Widget> remoteMessage(BuildContext context, ZegoIMKitMessage message) {
    return [
      buildAvatar(context, message),
      const SizedBox(width: 10),
      buildMessage(context, message),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: FractionallySizedBox(
        widthFactor: 0.66,
        alignment:
            message.isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: message.isSender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (message.isSender) ...localMessage(context, message),
            if (!message.isSender) ...remoteMessage(context, message),
          ],
        ),
      ),
    );
  }
}
