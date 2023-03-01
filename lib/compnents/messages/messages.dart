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
    this.onPressed,
    this.onLongPress,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
    required this.message,
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
  Widget buildMessage(BuildContext context) {
    switch (message.type) {
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
        return Text(message.tostr());
    }
  }

  Widget buildStatus(BuildContext context) {
    final Widget defaultStatusWidget = ZIMKitMessageStatusDot(message);
    return statusBuilder?.call(context, message, defaultStatusWidget) ??
        defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context) {
    final Widget defaultAvatarWidget =
        ZIMKitAvatar(userID: message.info.senderUserID, width: 50, height: 50);
    return avatarBuilder?.call(context, message, defaultAvatarWidget) ??
        defaultAvatarWidget;
  }

  // TODO add userName or groupNickName to message
  List<Widget> localMessage(BuildContext context) {
    return [
      buildMessage(context),
      // buildAvatar(context),
      buildStatus(context),
    ];
  }

  List<Widget> remoteMessage(BuildContext context) {
    return [
      buildAvatar(context),
      const SizedBox(width: 10),
      buildMessage(context),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: FractionallySizedBox(
        widthFactor: 0.66,
        alignment:
            message.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (message.isMine) ...localMessage(context),
            if (!message.isMine) ...remoteMessage(context),
          ],
        ),
      ),
    );
  }
}
