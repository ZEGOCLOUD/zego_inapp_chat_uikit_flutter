import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitTextMessage extends StatelessWidget {
  const ZIMKitTextMessage({
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
        onTap: () => onPressed?.call(context, message, () {}),
        onLongPress: () => onLongPress?.call(context, message, () {
          Clipboard.setData(ClipboardData(text: message.textContent!.text));
        }),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(message.isMine ? 1 : 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            message.textContent!.text,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: message.isMine
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color),
          ),
        ),
      ),
    );
  }
}
