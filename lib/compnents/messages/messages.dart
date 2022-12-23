import 'package:flutter/material.dart';

import 'package:zego_zimkit/compnents/common/common.dart';
import 'package:zego_zimkit/compnents/messages/audio_message.dart';
import 'package:zego_zimkit/compnents/messages/file_message.dart';
import 'package:zego_zimkit/compnents/messages/image_message.dart';
import 'package:zego_zimkit/compnents/messages/text_message.dart';
import 'package:zego_zimkit/compnents/messages/video_message.dart';
import 'package:zego_zimkit/compnents/messages/widgets/widgets.dart';
import 'package:zego_zimkit/services/services.dart';

export 'audio_message.dart';
export 'text_message.dart';
export 'video_message.dart';

class ZIMKitMessageWidget extends StatelessWidget {
  const ZIMKitMessageWidget({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
  }) : super(key: key);

  final ZIMKitMessage message;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      avatarBuilder;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      statusBuilder;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      timestampBuilder;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onPressed;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onLongPress;

  // TODO default onPressed onLongPress action
  // TODO custom meesage
  Widget buildMessage(BuildContext context, ZIMKitMessage message) {
    switch (message.data.value.type) {
      case ZIMMessageType.text:
        return ZIMKitTextMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.audio:
        return ZIMKitAudioMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.video:
        return ZIMKitVideoMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.file:
        return ZIMKitFileMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.image:
        return ZIMKitImageMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);

      default:
        return Text(message.data.value.type.toString());
    }
  }

  Widget buildStatus(BuildContext context, ZIMKitMessage message) {
    final Widget defaultStatusWidget = ZIMKitMessageStatusDot(message);
    return statusBuilder?.call(context, message, defaultStatusWidget) ??
        defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context, ZIMKitMessage message) {
    final Widget defaultAvatarWidget =
        ZIMKitAvatar(userID: message.senderUserID, width: 50, height: 50);
    return avatarBuilder?.call(context, message, defaultAvatarWidget) ??
        defaultAvatarWidget;
  }

  // TODO how to custom laytout
  // TODO timestamp
  List<Widget> localMessage(BuildContext context, ZIMKitMessage message) {
    return [
      buildMessage(context, message),
      // buildAvatar(context, message),
      buildStatus(context, message),
    ];
  }

  List<Widget> remoteMessage(BuildContext context, ZIMKitMessage message) {
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
