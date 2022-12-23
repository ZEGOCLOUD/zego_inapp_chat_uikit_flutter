import 'package:flutter/material.dart';

import 'package:zego_zimkit/compnents/messages/video_message_player.dart';
import 'package:zego_zimkit/compnents/messages/video_message_preview.dart';
import 'package:zego_zimkit/services/services.dart';

class ZIMKitVideoMessage extends StatelessWidget {
  const ZIMKitVideoMessage({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final ZIMKitMessage message;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onPressed;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onLongPress;

  void _onPressed(BuildContext context) {
    void defaultAction() => playVideo(context);
    if (onPressed != null) {
      onPressed!.call(context, message, defaultAction);
    } else {
      defaultAction();
    }
  }

  void _onLongPress(BuildContext context) {
    void defaultAction() {}
    if (onLongPress != null) {
      onLongPress!.call(context, message, defaultAction);
    } else {
      defaultAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZIMMessage>(
      valueListenable: message.data,
      builder: (context, ZIMMessage msg, child) {
        return Flexible(
          child: GestureDetector(
            onTap: () => _onPressed(context),
            onLongPress: () => _onLongPress(context),
            child: ZIMKitVideoMessagePreview(message),
          ),
        );
      },
    );
  }

  void playVideo(BuildContext context) {
    showBottomSheet(
            context: context,
            builder: (context) => ZIMKitVideoMessagePlayer(message))
        .closed
        .then((value) {
      ZIMKitLogger.fine('ZIMKitVideoMessage: playVideo end');
    });
  }
}
