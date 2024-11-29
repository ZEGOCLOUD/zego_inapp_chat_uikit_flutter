import 'package:flutter/material.dart';

import 'defines.dart';
import 'status.dart';

class ZIMKitRecordLocker extends StatefulWidget {
  const ZIMKitRecordLocker({
    Key? key,
    this.icon,
    required this.processor,
  }) : super(key: key);

  final Widget? icon;
  final ZIMKitRecordStatus processor;

  @override
  State<ZIMKitRecordLocker> createState() => _ZIMKitRecordLockerState();
}

/// @nodoc
class _ZIMKitRecordLockerState extends State<ZIMKitRecordLocker> {
  Offset startOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.processor.stateNotifier,
      builder: (context, recordState, _) {
        return ValueListenableBuilder(
          valueListenable: widget.processor.lockerStateNotifier,
          builder: (context, lockerState, _) {
            var color = Colors.grey.withOpacity(0.4);
            if (lockerState == ZIMKitRecordLockerState.testing) {
              color = Colors.green.withOpacity(0.4);
            }

            return recordState == ZIMKitRecordState.recording &&
                    lockerState != ZIMKitRecordLockerState.locked
                ? Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2000),
                    ),
                    child: widget.icon ?? const Icon(Icons.lock),
                  )
                : Container();
          },
        );
      },
    );
  }
}
