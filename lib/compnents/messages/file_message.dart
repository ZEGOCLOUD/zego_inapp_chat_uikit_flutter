import 'package:flutter/material.dart';

import 'package:zego_imkit/services/services.dart';

class ZegoFileMessage extends StatelessWidget {
  const ZegoFileMessage({
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
    var color = message.isSender
        ? Colors.white
        : Theme.of(context).textTheme.bodyText1!.color;
    var textStyle = TextStyle(color: color);
    return ValueListenableBuilder<ZIMMessage>(
      valueListenable: message.data,
      builder: (context, ZIMMessage msg, child) {
        ZIMFileMessage message = msg as ZIMFileMessage;
        return Flexible(
          child: GestureDetector(
            // TODO download file
            onTap: () => onPressed?.call(context, this.message, () {}),
            onLongPress: () => onLongPress?.call(context, this.message, () {}),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withOpacity(message.isSender ? 1 : 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_copy, color: color),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.fileName,
                            style: textStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('${(message.fileSize / 1024).ceil()} kb',
                            style: textStyle, maxLines: 1),
                      ],
                    ),
                  ),
                  const Icon(Icons.download),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
