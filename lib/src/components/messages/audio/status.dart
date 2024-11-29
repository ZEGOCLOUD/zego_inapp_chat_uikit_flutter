import 'package:flutter/cupertino.dart';

import 'package:zego_zimkit/src/services/audio/core.dart';
import 'defines.dart';

class ZIMKitRecordStatus {
  final stateNotifier =
      ValueNotifier<ZIMKitRecordState>(ZIMKitRecordState.idle);
  final lockerStateNotifier =
      ValueNotifier<ZIMKitRecordLockerState>(ZIMKitRecordLockerState.idle);

  void register() {
    stateNotifier.addListener(_onStateChanged);
  }

  void unregister() {
    stateNotifier.removeListener(_onStateChanged);
  }

  void _onStateChanged() {
    switch (stateNotifier.value) {
      case ZIMKitRecordState.idle:
        break;
      case ZIMKitRecordState.recording:
        break;
      case ZIMKitRecordState.cancel:
        ZIMKitAudioInstance().cancelRecord();
        break;
      case ZIMKitRecordState.complete:
        ZIMKitAudioInstance().completeRecord();
        break;
    }
  }
}
