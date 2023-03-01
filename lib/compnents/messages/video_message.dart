import 'package:flutter/material.dart';
import 'package:zego_zimkit/compnents/messages/video_message_player.dart';
import 'package:zego_zimkit/compnents/messages/video_message_preview.dart';
import 'package:zego_zimkit/services/services.dart';

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
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onLongPress;

  void _onPressed(BuildContext context, ZIMKitMessage msg) {
    void defaultAction() => playVideo(context);
    if (onPressed != null) {
      onPressed!.call(context, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  void _onLongPress(BuildContext context, ZIMKitMessage msg) {
    void defaultAction() {
      // TODO popup menu
    }
    if (onLongPress != null) {
      onLongPress!.call(context, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => _onPressed(context, message),
        onLongPress: () => _onLongPress(context, message),
        child: ZIMKitVideoMessagePreview(message),
      ),
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
