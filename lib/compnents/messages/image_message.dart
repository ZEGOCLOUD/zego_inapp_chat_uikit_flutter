import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitImageMessage extends StatelessWidget {
  const ZIMKitImageMessage({
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
    return ValueListenableBuilder<ZIMMessage>(
      valueListenable: message.data,
      builder: (context, ZIMMessage msg, child) {
        final message = msg as ZIMImageMessage;
        return Flexible(
          child: GestureDetector(
            // TODO save image
            onTap: () => onPressed?.call(
                context, this.message, () {}), // TODO default onPressed
            onLongPress: () => onLongPress?.call(context, this.message, () {}),
            child: AspectRatio(
              aspectRatio: message.aspectRatio,
              child:
                  LayoutBuilder(builder: (context, BoxConstraints constraints) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: message.isSender
                      ? FutureBuilder(
                          future: File(message.fileLocalPath).exists(),
                          builder: (context, snapshot) {
                            return snapshot.hasData && (snapshot.data! as bool)
                                ? Image.file(
                                    File(message.fileLocalPath),
                                    cacheHeight: constraints.maxHeight.floor(),
                                    cacheWidth: constraints.maxWidth.floor(),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: message.largeImageDownloadUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, _, __) => const Icon(
                                        Icons.image_not_supported_outlined),
                                    placeholder: (context, url) =>
                                        const Icon(Icons.image_outlined),
                                    memCacheHeight:
                                        constraints.maxHeight.floor(),
                                    memCacheWidth: constraints.maxWidth.floor(),
                                  );
                          },
                        )
                      : CachedNetworkImage(
                          imageUrl: message.largeImageDownloadUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, _, __) =>
                              const Icon(Icons.image_not_supported_outlined),
                          placeholder: (context, url) =>
                              const Icon(Icons.image_outlined),
                          memCacheHeight: constraints.maxHeight.floor(),
                          memCacheWidth: constraints.maxWidth.floor(),
                        ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
