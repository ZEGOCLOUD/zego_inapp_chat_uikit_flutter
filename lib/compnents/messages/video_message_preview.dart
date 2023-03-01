import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitVideoMessagePreview extends StatelessWidget {
  const ZIMKitVideoMessagePreview(this.message, {Key? key}) : super(key: key);

  final ZIMKitMessage message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: message.videoContent!.videoFirstFrameLocalPath.isNotEmpty
              ? Image.file(
                  File(message.videoContent!.videoFirstFrameLocalPath),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: message.videoContent!.videoFirstFrameDownloadUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, _, __) => const Icon(Icons.error),
                  placeholder: (context, url) =>
                      const Icon(Icons.video_file_outlined),
                ),
        ),
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            size: 16,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}
