import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    return Flexible(
      child: GestureDetector(
        // TODO save image
        onTap: () =>
            onPressed?.call(context, message, () {}), // TODO default onPressed
        onLongPress: () => onLongPress?.call(context, message, () {}),
        child: AspectRatio(
          aspectRatio: message.imageContent!.aspectRatio,
          child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: message.isMine
                  ? FutureBuilder(
                      future:
                          File(message.imageContent!.fileLocalPath).exists(),
                      builder: (context, snapshot) {
                        return snapshot.hasData && (snapshot.data! as bool)
                            ? Image.file(
                                File(message.imageContent!.fileLocalPath),
                                cacheHeight: constraints.maxHeight.floor(),
                                cacheWidth: constraints.maxWidth.floor(),
                              )
                            : CachedNetworkImage(
                                imageUrl:
                                    message.imageContent!.largeImageDownloadUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, _, __) => const Icon(
                                    Icons.image_not_supported_outlined),
                                placeholder: (context, url) =>
                                    const Icon(Icons.image_outlined),
                                memCacheHeight: constraints.maxHeight.floor(),
                                memCacheWidth: constraints.maxWidth.floor(),
                              );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: message.imageContent!.largeImageDownloadUrl,
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
  }
}
