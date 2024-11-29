class ZIMKitAudioRecordEvents {
  ZIMKitAudioRecordEvents({
    this.onFailed,
    this.onCountdownTick,
  });

  final void Function(int errorCode)? onFailed;
  final void Function(int remainingSecond)? onCountdownTick;
}
