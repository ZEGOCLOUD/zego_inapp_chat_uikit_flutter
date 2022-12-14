import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:zego_imkit/services/services.dart';

class ZegoVideoMessagePreview extends StatelessWidget {
  const ZegoVideoMessagePreview(this.message, {Key? key}) : super(key: key);

  final ZegoIMKitMessage message;

  @override
  Widget build(BuildContext context) {
    final message = this.message.zim as ZIMVideoMessage;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: message.videoFirstFrameLocalPath.isNotEmpty
              ? Image.file(
                  File(message.videoFirstFrameLocalPath),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: message.videoFirstFrameDownloadUrl,
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
