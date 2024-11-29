import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/defines.dart';
import 'package:zego_zimkit/src/services/audio/core.dart';
import 'package:zego_zimkit/src/services/services.dart';
import 'defines.dart';
import 'status.dart';

class ZIMKitRecordCancelSlider extends StatefulWidget {
  const ZIMKitRecordCancelSlider({
    Key? key,
    required this.status,
    this.stopIcon,
    this.sendButtonWidget,
    this.onMessageSent,
    this.preMessageSending,
  }) : super(key: key);

  final Widget? stopIcon;

  final ZIMKitRecordStatus status;
  final Widget? sendButtonWidget;

  /// Called when a message is sent.
  final void Function(ZIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending;

  @override
  State<ZIMKitRecordCancelSlider> createState() =>
      _ZIMKitRecordCancelSliderState();
}

/// @nodoc
class _ZIMKitRecordCancelSliderState extends State<ZIMKitRecordCancelSlider> {
  Offset startOffset = Offset.zero;

  double get durationWidth => 50;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onHorizontalDragStart: (details) {
              startOffset = details.globalPosition;
            },
            onHorizontalDragUpdate: (details) {
              Offset currentOffset = details.globalPosition;
              double distance = currentOffset.dx - startOffset.dx;
              if (distance < -(constraints.maxWidth / 3)) {
                widget.status.stateNotifier.value = ZIMKitRecordState.cancel;
                widget.status.stateNotifier.value = ZIMKitRecordState.idle;

                widget.status.lockerStateNotifier.value =
                    ZIMKitRecordLockerState.idle;
              }
            },
            onHorizontalDragEnd: (details) {
              startOffset = Offset.zero;
            },
            child: Stack(
              children: [
                duration(),
                slider(constraints),
                sendButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget slider(constraints) {
    return Positioned(
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          widget.status.stateNotifier.value = ZIMKitRecordState.cancel;
          widget.status.stateNotifier.value = ZIMKitRecordState.idle;

          widget.status.lockerStateNotifier.value =
              ZIMKitRecordLockerState.idle;
        },
        child: Container(
          width: constraints.maxWidth,
          padding: EdgeInsets.fromLTRB(
            constraints.maxWidth / 2 - durationWidth,
            0,
            0,
            0,
          ),
          child: const Row(
            children: [
              Text(
                'slide to cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget duration() {
    return Positioned(
      left: 0,
      child: SizedBox(
        width: durationWidth,
        child: ValueListenableBuilder<int>(
          valueListenable: ZIMKitAudioInstance().data.recordDurationNotifier,
          builder: (context, duration, _) {
            return Text(
              formatAudioRecordDuration(duration),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget sendButton() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          sendAudioMessage();
        },
        child: Container(
          height: ZIMKitMessageStyle.iconSize,
          width: ZIMKitMessageStyle.iconSize,
          // padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: widget.sendButtonWidget == null
              ? BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                )
              : null,
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: ZIMKitMessageStyle.iconSize / 2,
          ),
        ),
      ),
    );
  }

  Future<void> sendAudioMessage() async {
    widget.status.stateNotifier.value = ZIMKitRecordState.complete;
    widget.status.stateNotifier.value = ZIMKitRecordState.idle;

    widget.status.lockerStateNotifier.value = ZIMKitRecordLockerState.idle;
  }
}
