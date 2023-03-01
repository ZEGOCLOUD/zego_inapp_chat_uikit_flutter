import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zego_zimkit/compnents/messages/video_message_controls.dart';
import 'package:zego_zimkit/compnents/messages/video_message_preview.dart';
import 'package:zego_zimkit/services/services.dart';

class ZIMKitVideoMessagePlayer extends StatefulWidget {
  const ZIMKitVideoMessagePlayer(this.message, {Key? key}) : super(key: key);

  final ZIMKitMessage message;

  @override
  State<ZIMKitVideoMessagePlayer> createState() =>
      ZIMKitVideoMessagePlayerState();
}

class ZIMKitVideoMessagePlayerState extends State<ZIMKitVideoMessagePlayer> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  Future<void> dispose() async {
    chewieController
      ..pause()
      ..dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.message.videoContent!.fileLocalPath.isNotEmpty &&
        File(widget.message.videoContent!.fileLocalPath).existsSync()) {
      ZIMKitLogger.fine('ZIMKitVideoMessagePlayer: initPlayer from local '
          'file: ${widget.message.videoContent!.fileLocalPath}');
      videoPlayerController = VideoPlayerController.file(
          File(widget.message.videoContent!.fileLocalPath.urlEncode));
    } else {
      ZIMKitLogger.fine('ZIMKitVideoMessagePlayer: initPlayer from network: '
          '${widget.message.videoContent!.fileDownloadUrl}');
      videoPlayerController = VideoPlayerController.network(
          widget.message.videoContent!.fileDownloadUrl);
    }

    // TODO
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        looping: true,
        customControls: const ZIMKitCustomControls(),
        placeholder: Center(child: ZIMKitVideoMessagePreview(widget.message)))
      ..setVolume(kIsWeb ? 0.0 : 1.0)
      ..play();

    Future.delayed(const Duration(seconds: 4)).then((value) {
      if (!chewieController.videoPlayerController.value.isInitialized) {
        ZIMKitLogger.severe(
            'videoPlayerController is not initialized, ${widget.message.videoContent!.fileLocalPath}');
        ZIMKitLogger.shout(context,
            "Seems Can't play this video, ${widget.message.videoContent!.fileLocalPath}");
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
                ZIMKitLogger.fine(
                    'ZIMKitVideoMessagePlayer: videoPlayerController initialize done');
                return Chewie(
                    key: ValueKey(snapshot.hashCode),
                    controller: chewieController);
              } else {
                ZIMKitLogger.fine(
                    'ZIMKitVideoMessagePlayer: videoPlayerController initializing...');
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
