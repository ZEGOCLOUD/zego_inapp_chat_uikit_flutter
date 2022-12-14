import 'package:flutter/material.dart';

import 'package:zego_imkit/services/services.dart';

import 'video_message_player.dart';
import 'video_message_preview.dart';

class ZegoVideoMessage extends StatelessWidget {
  const ZegoVideoMessage({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final ZegoIMKitMessage message;
  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onLongPress;

  void _onPressed(BuildContext context) {
    defaultAction() => playVideo(context);
    if (onPressed != null) {
      onPressed!.call(context, message, defaultAction);
    } else {
      defaultAction();
    }
  }

  void _onLongPress(BuildContext context) {
    defaultAction() {}
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
            child: ZegoVideoMessagePreview(message),
          ),
        );
      },
    );
  }

  void playVideo(BuildContext context) {
    showBottomSheet(
            context: context,
            builder: (context) => ZegoVideoMessagePlayer(message))
        .closed
        .then((value) {
      ZegoIMKitLogger.fine('ZegoVideoMessage: playVideo end');
    });
  }
}
