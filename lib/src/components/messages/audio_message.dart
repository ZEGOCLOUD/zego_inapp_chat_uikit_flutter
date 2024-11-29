import 'package:flutter/material.dart';

import 'package:zego_zim_audio/zego_zim_audio.dart';

import 'package:zego_zimkit/src/components/messages/audio/defines.dart';
import 'package:zego_zimkit/src/components/messages/defines.dart';
import 'package:zego_zimkit/src/services/audio/core.dart';
import 'package:zego_zimkit/src/services/audio/data.dart';
import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitAudioMessage extends StatefulWidget {
  const ZIMKitAudioMessage({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final ZIMKitMessage message;

  final void Function(
    BuildContext context,
    ZIMKitMessage message,
    Function defaultAction,
  )? onPressed;
  final void Function(BuildContext context, LongPressStartDetails details,
      ZIMKitMessage message, Function defaultAction)? onLongPress;

  @override
  State<ZIMKitAudioMessage> createState() => _ZIMKitAudioMessageState();
}

/// @nodoc
class _ZIMKitAudioMessageState extends State<ZIMKitAudioMessage> {
  final localPlayStatusNotifier =
      ValueNotifier<ZIMKitAudioPlayStatus>(ZIMKitAudioPlayStatus(
    id: 0,
    isPlaying: false,
  ));

  bool get isPlayingCurrent =>
      ZIMKitAudioInstance().data.playStatusNotifier.value.isPlaying &&
      ZIMKitAudioInstance().data.playStatusNotifier.value.id ==
          widget.message.info.messageID;

  SliderThemeData get sliderThemeData => SliderThemeData(
        trackHeight: 2.0,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 3.0,
        ),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.5),
      );

  @override
  void initState() {
    super.initState();

    ZIMKitAudioInstance()
        .data
        .playStatusNotifier
        .addListener(onPlayStatusUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    ZIMKitAudioInstance()
        .data
        .playStatusNotifier
        .removeListener(onPlayStatusUpdated);

    if (ZIMKitAudioInstance().data.playStatusNotifier.value.id ==
        widget.message.info.messageID) {
      ZIMKitAudioInstance().stopPlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () async {
          final defaultAction =
              isPlayingCurrent ? defaultStopPressed : defaultPlayPressed;
          widget.onPressed != null
              ? widget.onPressed?.call(context, widget.message, defaultAction)
              : defaultAction();
        },
        onLongPressStart: (details) => widget.onLongPress != null
            ? widget.onLongPress
                ?.call(context, details, widget.message, defaultLongPress)
            : defaultLongPress,
        child: LayoutBuilder(builder: (context, constraints) {
          const minDisplayWidth = 100;
          var durationWidth = widget.message.audioContent!.audioDuration * 5;
          if (durationWidth > constraints.maxWidth - minDisplayWidth) {
            durationWidth = constraints.maxWidth.toInt() - minDisplayWidth - 1;
          }
          return Container(
            width: (minDisplayWidth + durationWidth).toDouble(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(widget.message.isMine ? 1 : 0.1),
            ),
            child: Row(
              children: [
                ...state(),
                process(),
                duration(),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> state() {
    final playPauseWidget = ValueListenableBuilder<ZIMKitAudioPlayStatus>(
      valueListenable: localPlayStatusNotifier,
      builder: (context, playingStatus, _) {
        if (playingStatus.id != widget.message.info.messageID) {
          return Icon(
            Icons.play_arrow,
            color: widget.message.isMine
                ? Colors.white
                : Theme.of(context).primaryColor,
          );
        }

        return Icon(
          playingStatus.isPlaying ? Icons.pause : Icons.play_arrow,
          color: widget.message.isMine
              ? Colors.white
              : Theme.of(context).primaryColor,
        );
      },
    );

    if (widget.message.audioContent!.fileLocalPath.isEmpty) {
      return [
        SizedBox(
          width: ZIMKitMessageStyle.iconSize / 2,
          height: ZIMKitMessageStyle.iconSize / 2,
          child: const CircularProgressIndicator(),
        ),
        const SizedBox(
          width: 5,
        ),
      ];
    }

    return [playPauseWidget];
  }

  Widget duration() {
    return Text(
      formatAudioRecordDuration(
        widget.message.audioContent!.audioDuration * 1000,
      ),
      style: TextStyle(
        fontSize: 12,
        color: widget.message.isMine ? Colors.white : null,
      ),
    );
  }

  Widget process() {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 2,
            color: Colors.transparent,
            child: ValueListenableBuilder<ZIMKitAudioPlayStatus>(
              valueListenable: localPlayStatusNotifier,
              builder: (context, playingStatus, _) {
                if (playingStatus.id != widget.message.info.messageID) {
                  return SliderTheme(
                    data: sliderThemeData,
                    child: Slider(
                      value: 0,
                      min: 0.0,
                      max: 1,
                      onChanged: (_) {},
                    ),
                  );
                }

                return ValueListenableBuilder<int>(
                  valueListenable:
                      ZIMKitAudioInstance().data.playProcessNotifier,
                  builder: (context, playProcess, _) {
                    return SliderTheme(
                      data: sliderThemeData,
                      child: Slider(
                        value: (playProcess / 1000).toDouble().floorToDouble(),
                        min: 0.0,
                        max: widget.message.audioContent!.audioDuration
                            .toDouble(),
                        onChanged: (_) {},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> defaultPlayPressed() async {
    await ZIMKitAudioInstance().startPlay(
      widget.message.info.messageID,
      widget.message.audioContent?.fileLocalPath ?? '',
      routeType: ZIMAudioRouteType.speaker,
    );
  }

  Future<void> defaultStopPressed() async {
    await ZIMKitAudioInstance().stopPlay();
  }

  Future<void> defaultLongPress() async {}

  void onPlayStatusUpdated() {
    localPlayStatusNotifier.value =
        ZIMKitAudioInstance().data.playStatusNotifier.value;
  }
}
