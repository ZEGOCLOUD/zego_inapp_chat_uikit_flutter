part of 'core.dart';

mixin ZIMKitAudioEventService {
  void registerEvents() {
    ZIMAudioEventHandler.onError = onError;
    ZIMAudioEventHandler.onRecorderStarted = onRecorderStarted;
    ZIMAudioEventHandler.onRecorderCompleted = onRecorderCompleted;
    ZIMAudioEventHandler.onRecorderCancelled = onRecorderCancelled;
    ZIMAudioEventHandler.onRecorderProgress = onRecorderProgress;
    ZIMAudioEventHandler.onRecorderFailed = onRecorderFailed;
    ZIMAudioEventHandler.onPlayerStarted = onPlayerStarted;
    ZIMAudioEventHandler.onPlayerEnded = onPlayerEnded;
    ZIMAudioEventHandler.onPlayerStopped = onPlayerStopped;
    ZIMAudioEventHandler.onPlayerProgress = onPlayerProgress;
    ZIMAudioEventHandler.onPlayerInterrupted = onPlayerInterrupted;
    ZIMAudioEventHandler.onPlayerFailed = onPlayerFailed;
  }

  void unregisterEvents() {
    ZIMAudioEventHandler.onError = null;
    ZIMAudioEventHandler.onRecorderStarted = null;
    ZIMAudioEventHandler.onRecorderCompleted = null;
    ZIMAudioEventHandler.onRecorderCancelled = null;
    ZIMAudioEventHandler.onRecorderProgress = null;
    ZIMAudioEventHandler.onRecorderFailed = null;
    ZIMAudioEventHandler.onPlayerStarted = null;
    ZIMAudioEventHandler.onPlayerEnded = null;
    ZIMAudioEventHandler.onPlayerStopped = null;
    ZIMAudioEventHandler.onPlayerProgress = null;
    ZIMAudioEventHandler.onPlayerInterrupted = null;
    ZIMAudioEventHandler.onPlayerFailed = null;
  }

  void onError(ZIMAudioError errorInfo) {
    ZIMKitLogger.info('ZIMAudio, onError, errorInfo:$errorInfo');

    ZIMKitAudioInstance().data.removeTopRecordingFile();
    ZIMKitAudioInstance().data.recordDurationNotifier.value = 0;

    ZIMKitAudioInstance().data.recordFailedStreamCtrl?.add(errorInfo.code);
  }

  void onRecorderStarted() {
    ZIMKitLogger.info('ZIMAudio, onRecorderStarted');

    ZIMKitAudioInstance().data.recordDurationNotifier.value = 0;
    ZIMKitAudioInstance().data.recordCountDownNotifier.value =
        ZIMKitAudioInstance().data.getTopRecordedFile().maxDuration ~/ 1000;
  }

  void onRecorderCompleted(int totalDuration) {
    ZIMKitLogger.info(
        'ZIMAudio, onRecorderCompleted, totalDuration:$totalDuration');

    final currentRecordData =
        ZIMKitAudioInstance().data.removeTopRecordingFile();
    currentRecordData.duration = totalDuration;
    ZIMKitAudioInstance().data.recordCompleteStreamCtrl?.add(currentRecordData);

    ZIMKitAudioInstance().data.recordDurationNotifier.value = 0;
  }

  void onRecorderCancelled() {
    ZIMKitLogger.info('ZIMAudio, onRecorderCancelled');

    ZIMKitAudioInstance().data.removeTopRecordingFile();

    ZIMKitAudioInstance().data.recordDurationNotifier.value = 0;
  }

  void onRecorderProgress(int currentDuration) {
    ZIMKitAudioInstance().data.recordDurationNotifier.value = currentDuration;
    ZIMKitAudioInstance().data.recordCountDownNotifier.value =
        (ZIMKitAudioInstance().data.getTopRecordedFile().maxDuration -
                currentDuration) ~/
            1000;
  }

  void onRecorderFailed(int errorCode) {
    ZIMKitLogger.info('ZIMAudio, onRecorderFailed, errorCode:$errorCode');

    ZIMKitAudioInstance().data.removeTopRecordingFile();
    ZIMKitAudioInstance().data.recordDurationNotifier.value = 0;

    ZIMKitAudioInstance().data.recordFailedStreamCtrl?.add(errorCode);
  }

  void onPlayerStarted(int totalDuration) {
    ZIMKitLogger.info(
        'ZIMAudio, onPlayerStarted, totalDuration:$totalDuration');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;
  }

  void onPlayerEnded() {
    ZIMKitLogger.info('ZIMAudio, onPlayerEnded');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;

    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );
  }

  void onPlayerStopped() {
    ZIMKitLogger.info('ZIMAudio, onPlayerStopped');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;

    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );

    if (ZIMKitAudioInstance().data.cachePlayingData != null) {
      /// exist cache play, play now
      final pendingPlayData = ZIMKitAudioInstance().data.cachePlayingData!;
      ZIMKitAudioInstance().data.cachePlayingData = null;

      ZIMKitAudioInstance().startPlay(
        pendingPlayData.id,
        pendingPlayData.filePath,
        routeType: pendingPlayData.routeType,
      );
    }
  }

  void onPlayerProgress(int currentDuration) {
    ZIMKitLogger.info(
        'ZIMAudio, onPlayerProgress, currentDuration:$currentDuration');
    ZIMKitAudioInstance().data.playProcessNotifier.value = currentDuration;
  }

  void onPlayerInterrupted() {
    ZIMKitLogger.info('ZIMAudio, onPlayerInterrupted');
    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );
  }

  void onPlayerFailed(int errorCode) {
    ZIMKitLogger.info('ZIMAudio, onPlayerFailed, errorCode:$errorCode');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;

    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );
  }
}
