import 'package:flutter/material.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitAudioMessage extends StatelessWidget {
  const ZIMKitAudioMessage({
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

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        // TODO play audio
        onTap: () => onPressed?.call(context, message, () {}),
        onLongPress: () => onLongPress?.call(context, message, () {}),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context)
                .primaryColor
                .withOpacity(message.isMine ? 1 : 0.1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_arrow,
                color: message.isMine
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: message.isMine
                            ? Colors.white
                            : Theme.of(context).primaryColor.withOpacity(0.4),
                      ),
                      Positioned(
                        left: 0,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: message.isMine
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Text(
                '0:${message.audioContent!.audioDuration < 10 ? "0" : ''}${(message.audioContent!.audioDuration < 1 ? 1 : message.audioContent!.audioDuration).toString()}',
                style: TextStyle(
                  fontSize: 12,
                  color: message.isMine ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
