import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_imkit/compnents/messages/video_message_preview.dart';

import 'package:zego_imkit/services/services.dart';
import 'package:video_player/video_player.dart';

class ZegoVideoMessagePlayer extends StatefulWidget {
  const ZegoVideoMessagePlayer(this.message, {Key? key}) : super(key: key);

  final ZegoIMKitMessage message;

  @override
  State<ZegoVideoMessagePlayer> createState() => ZegoVideoMessagePlayerState();
}

class ZegoVideoMessagePlayerState extends State<ZegoVideoMessagePlayer> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  void dispose() async {
    chewieController.pause();
    chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final ZIMVideoMessage message =
        widget.message.data.value as ZIMVideoMessage;
    if (message.fileLocalPath.isNotEmpty &&
        File(message.fileLocalPath).existsSync()) {
      ZegoIMKitLogger.fine(
          'ZegoVideoMessagePlayer: initPlayer from local file: ${message.fileLocalPath}');
      videoPlayerController =
          VideoPlayerController.file(File(message.fileLocalPath.urlEncode));
    } else {
      ZegoIMKitLogger.fine(
          'ZegoVideoMessagePlayer: initPlayer from network: ${message.fileDownloadUrl}');
      videoPlayerController =
          VideoPlayerController.network(message.fileDownloadUrl);
    }

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        looping: true,
        customControls:
            const MaterialDesktopControls(), // always use DesktopControls
        placeholder: Center(child: ZegoVideoMessagePreview(widget.message)))
      ..setVolume(kIsWeb ? 0.0 : 1.0)
      ..play();

    Future.delayed(const Duration(seconds: 4)).then((value) {
      if (chewieController.videoPlayerController.value.isInitialized == false) {
        ZegoIMKitLogger.severe(
            'videoPlayerController is not initialized, ${widget.message.zim.fileLocalPath}');
        ZegoIMKitLogger.shout(context,
            "Seems Can't play this video, ${widget.message.zim.fileLocalPath}");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: videoPlayerController.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                ZegoIMKitLogger.fine(
                    'ZegoVideoMessagePlayer: videoPlayerController initialize done');
                return Chewie(
                    key: ValueKey(snapshot.hashCode),
                    controller: chewieController);
              } else {
                ZegoIMKitLogger.fine(
                    'ZegoVideoMessagePlayer: videoPlayerController initializing...');
                return Chewie(
                    key: ValueKey(snapshot.hashCode),
                    controller: chewieController);
              }
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
