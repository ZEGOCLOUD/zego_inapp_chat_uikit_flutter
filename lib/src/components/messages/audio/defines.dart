enum ZIMKitRecordState {
  idle,
  recording,
  cancel,
  complete,
}

enum ZIMKitRecordLockerState {
  idle,
  testing,
  locked,
}

class ZIMKitRecordStyle {
  static double lockerIconSize = 50;
}

String formatAudioRecordDuration(int milliseconds) {
  final seconds = (milliseconds / 1000).floor();
  final minutes = (seconds / 60).floor();
  final remainingSeconds = seconds % 60;

  final formattedMinutes = minutes.toString().padLeft(2, '0');
  final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

  return '$formattedMinutes:$formattedSeconds';
}
