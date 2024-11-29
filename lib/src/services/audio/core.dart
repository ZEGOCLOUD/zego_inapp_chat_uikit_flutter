import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zim_audio/zego_zim_audio.dart';

import 'package:zego_zimkit/src/services/logger_service.dart';
import 'data.dart';

part 'event.dart';

class ZIMKitAudioInstance with ZIMKitAudioEventService {
  factory ZIMKitAudioInstance() => instance;

  ZIMKitAudioInstance._internal() {
    data.init();
  }

  static final ZIMKitAudioInstance instance = ZIMKitAudioInstance._internal();
  var data = ZIMKitAudioData();

  Future<void> init({
    String license = '',
    String absFileRoot = '',
  }) async {
    ZIMKitLogger.info('ZIMAudio init');

    data.init();

    ZIMAudio.getInstance().init(license);
    registerEvents();
  }

  Future<void> uninit() async {
    ZIMKitLogger.info('ZIMAudio uninit');

    data.uninit();

    unregisterEvents();
    ZIMAudio.getInstance().uninit();
  }

  Future<void> startRecord(
    String conversationID,
    ZIMConversationType conversationType, {
    String? filePath,

    /// The maximum recording time, the default is 60000 ms, which is 60s. The unit of this parameter is milliseconds, and the maximum value does not exceed 120000.
    int maxDuration = 60 * 1000,
  }) async {
    filePath ??= data.generateRecordFilePath();

    ZIMKitLogger.info('ZIMAudio startRecord,'
        'conversationID:$conversationID, '
        'conversationType:$conversationType, '
        'filePath:$filePath, '
        'maxDuration:$maxDuration, ');

    data.addRecording(
      filePath,
      conversationID,
      conversationType,
      maxDuration,
    );

    return ZIMAudio.getInstance().startRecord(ZIMAudioRecordConfig(
      filePath,
      maxDuration: maxDuration,
    ));
  }

  Future<void> completeRecord() async {
    ZIMKitLogger.info('ZIMAudio completeRecord');
    return ZIMAudio.getInstance().completeRecord();
  }

  Future<void> cancelRecord() async {
    ZIMKitLogger.info('ZIMAudio cancelRecord');
    return ZIMAudio.getInstance().cancelRecord();
  }

  Future<bool> isRecording() async {
    return ZIMAudio.getInstance().isRecording();
  }

  Future<void> startPlay(
    int id,
    String filePath, {
    ZIMAudioRouteType? routeType,
  }) async {
    if (data.playStatusNotifier.value.id == id) {
      ZIMKitLogger.info('ZIMAudio startPlay, target id($id) is playing');
      return;
    }

    if (data.playStatusNotifier.value.isPlaying) {
      /// playing another audio
      ZIMKitLogger.info('ZIMAudio startPlay, '
          'current is playing:${data.playStatusNotifier.value.id}, '
          'cache target:$id, waiting stop');

      data.cachePlayingData = ZIMKitAudioPlayData(
        id: id,
        filePath: filePath,
        routeType: routeType,
      );

      /// playing other audio, stop first
      await stopPlay();

      /// update data
      data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
        id: id,
        isPlaying: true,
      );

      return;
    }

    ZIMKitLogger.info('ZIMAudio startPlay, '
        'current playing:${data.playStatusNotifier.value.id}, '
        'target, id:$id, filePath:$filePath, routeType:$routeType');

    /// update data
    data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: id,
      isPlaying: true,
    );
    return ZIMAudio.getInstance().startPlay(ZIMAudioPlayConfig(
      filePath,
      routeType: routeType,
    ));
  }

  Future<void> stopPlay() async {
    ZIMKitLogger.info(
        'ZIMAudio stopPlay, current playing:${data.playStatusNotifier.value.id}');

    /// update data
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;
    data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );

    return ZIMAudio.getInstance().stopPlay();
  }

  Future<bool> isPlaying() async {
    return ZIMAudio.getInstance().isPlaying();
  }

  Future<String> getVersion() async {
    return ZIMAudio.getVersion();
  }
}
