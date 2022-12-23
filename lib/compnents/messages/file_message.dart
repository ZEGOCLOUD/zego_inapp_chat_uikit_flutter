import 'package:flutter/material.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitFileMessage extends StatelessWidget {
  const ZIMKitFileMessage({
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
    final color = message.isSender
        ? Colors.white
        : Theme.of(context).textTheme.bodyText1!.color;
    final textStyle = TextStyle(color: color);
    return ValueListenableBuilder<ZIMMessage>(
      valueListenable: message.data,
      builder: (context, ZIMMessage msg, child) {
        final message = msg as ZIMFileMessage;
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
                        Text(
                          fileSizeFormat(message.fileSize),
                          style: textStyle,
                          maxLines: 1,
                        ),
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

  String fileSizeFormat(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).ceil()} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).ceil()} MB';
    } else {
      return '${(size / 1024 / 1024 / 1024).ceil()} GB';
    }
  }
}
