import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/video_message_player.dart';
import 'package:zego_zimkit/src/components/messages/video_message_preview.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitVideoMessage extends StatelessWidget {
  const ZIMKitVideoMessage({
    Key? key,
    this.onPressed,
    this.onLongPress,
    required this.message,
  }) : super(key: key);

  final ZIMKitMessage message;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onPressed;
  final void Function(BuildContext context, LongPressStartDetails details,
      ZIMKitMessage message, Function defaultAction)? onLongPress;

  void _onPressed(BuildContext context, ZIMKitMessage msg) {
    void defaultAction() => playVideo(context);
    if (onPressed != null) {
      onPressed!.call(context, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  void _onLongPress(
    BuildContext context,
    LongPressStartDetails details,
    ZIMKitMessage msg,
  ) {
    void defaultAction() {
      // TODO popup menu
    }
    if (onLongPress != null) {
      onLongPress!.call(context, details, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => _onPressed(context, message),
        onLongPressStart: (details) => _onLongPress(context, details, message),
        child: ZIMKitVideoMessagePreview(
          message,
          key: ValueKey(message.info.messageID),
        ),
      ),
    );
  }

  void playVideo(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) => ZIMKitVideoMessagePlayer(message,
          key: ValueKey(message.info.messageID)),
    ).closed.then((value) {
      ZIMKitLogger.fine('ZIMKitVideoMessage: playVideo end');
    });
  }
}
