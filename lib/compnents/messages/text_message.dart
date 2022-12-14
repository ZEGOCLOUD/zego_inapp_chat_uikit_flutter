import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zego_imkit/services/services.dart';

class ZegoTextMessage extends StatelessWidget {
  const ZegoTextMessage({
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZIMMessage>(
      valueListenable: message.data,
      builder: (context, ZIMMessage msg, child) {
        ZIMTextMessage message = msg as ZIMTextMessage;
        return Flexible(
          child: GestureDetector(
            onTap: () => onPressed?.call(context, this.message, () {}),
            onLongPress: () => onLongPress?.call(context, this.message, () {
              Clipboard.setData(ClipboardData(text: message.message));
            }),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withOpacity(message.isSender ? 1 : 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                message.message,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: message.isSender
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyText1!.color),
              ),
            ),
          ),
        );
      },
    );
  }
}
