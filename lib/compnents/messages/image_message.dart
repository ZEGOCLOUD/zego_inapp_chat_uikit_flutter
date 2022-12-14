import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:zego_imkit/services/services.dart';

class ZegoImageMessage extends StatelessWidget {
  const ZegoImageMessage({
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
        ZIMImageMessage message = msg as ZIMImageMessage;
        // TODO show thumbnail / largeImage / originFile
        // TODO apply originalImageHeight、originalImageWidth
        return Flexible(
          child: GestureDetector(
            // TODO save image
            onTap: () => onPressed?.call(
                context, this.message, () {}), // TODO default onPressed
            onLongPress: () => onLongPress?.call(context, this.message, () {}),
            child: AspectRatio(
              aspectRatio: message.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: message.isSender
                    ? FutureBuilder(
                        future: File(message.fileLocalPath).exists(),
                        builder: (context, snapshot) {
                          return snapshot.hasData &&
                                  (snapshot.data as bool == true)
                              ? Image.file(File(message.fileLocalPath))
                              : CachedNetworkImage(
                                  imageUrl: message.largeImageDownloadUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, _, __) => const Icon(
                                      Icons.image_not_supported_outlined),
                                  placeholder: (context, url) =>
                                      const Icon(Icons.image_outlined),
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
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
