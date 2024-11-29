import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zim_audio/zego_zim_audio.dart';

class ZIMKitAudioRecordData {
  ZIMKitAudioRecordData({
    required this.absFilePath,
    required this.conversationID,
    required this.conversationType,
    this.duration = 0,
    this.maxDuration = 60 * 1000,
  });

  static ZIMKitAudioRecordData empty() {
    return ZIMKitAudioRecordData(
      absFilePath: '',
      conversationID: '',
      conversationType: ZIMConversationType.unknown,
    );
  }

  /// milliseconds
  int duration;
  int maxDuration;
  String absFilePath;
  String conversationID;
  ZIMConversationType conversationType;

  @override
  String toString() {
    return '{[ZIMKitAudioPlayStatus]'
        'duration:$duration, '
        'maxDuration:$maxDuration, '
        'absFilePath:$absFilePath, '
        'conversationID:$conversationID, '
        'conversationType:$conversationType, '
        '}';
  }
}

class ZIMKitAudioPlayData {
  ZIMKitAudioPlayData({
    required this.id,
    required this.filePath,
    this.routeType,
  });

  /// milliseconds
  int id;
  String filePath;
  ZIMAudioRouteType? routeType;

  @override
  String toString() {
    return '{[ZIMKitAudioPlayStatus]id:$id, filePath:$filePath, routeType:$routeType}';
  }
}

class ZIMKitAudioPlayStatus {
  ZIMKitAudioPlayStatus({
    required this.id,
    required this.isPlaying,
  });

  /// milliseconds
  int id;
  bool isPlaying;

  @override
  String toString() {
    return '{[ZIMKitAudioPlayStatus]id:$id, isPlaying:$isPlaying}';
  }
}

class ZIMKitAudioData {
  StreamController<ZIMKitAudioRecordData>? recordCompleteStreamCtrl;
  StreamController<int>? recordFailedStreamCtrl;
  //  unit: milliseconds
  final recordDurationNotifier = ValueNotifier<int>(0);
  //  unit:seconds
  final recordCountDownNotifier = ValueNotifier<int>(0);

  ZIMKitAudioPlayData? cachePlayingData;
  final playProcessNotifier = ValueNotifier<int>(0);
  final playStatusNotifier =
      ValueNotifier<ZIMKitAudioPlayStatus>(ZIMKitAudioPlayStatus(
    id: -1,
    isPlaying: false,
  ));

  bool isInit = false;
  String absFileRoot = '';
  var recordingCache = Queue<ZIMKitAudioRecordData>();

  Future<void> init() async {
    if (isInit) {
      return;
    }

    isInit = true;
    recordCompleteStreamCtrl ??=
        StreamController<ZIMKitAudioRecordData>.broadcast();
    recordFailedStreamCtrl ??= StreamController<int>.broadcast();

    await getApplicationDocumentsDirectory().then((directory) {
      absFileRoot = directory.path;
    });
  }

  void uninit() {
    if (!isInit) {
      return;
    }

    isInit = false;

    recordCompleteStreamCtrl?.close();
    recordCompleteStreamCtrl = null;
    recordFailedStreamCtrl?.close();
    recordFailedStreamCtrl = null;
  }

  String generateRecordFilePath() {
    return '$absFileRoot${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch.toString()}.mp3';
  }

  void addRecording(
    String absFilePath,
    String conversationID,
    ZIMConversationType conversationType,
    int maxDuration,
  ) {
    recordingCache.add(ZIMKitAudioRecordData(
      absFilePath: absFilePath,
      conversationID: conversationID,
      conversationType: conversationType,
      maxDuration: maxDuration,
    ));
  }

  ZIMKitAudioRecordData getTopRecordedFile() {
    if (recordingCache.isEmpty) {
      return ZIMKitAudioRecordData.empty();
    }

    var data = recordingCache.first;
    data.duration = recordDurationNotifier.value;
    return data;
  }

  ZIMKitAudioRecordData removeTopRecordingFile() {
    if (recordingCache.isEmpty) {
      return ZIMKitAudioRecordData.empty();
    }

    var data = recordingCache.removeFirst();
    data.duration = recordDurationNotifier.value;
    return data;
  }
}
