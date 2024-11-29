import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:async/async.dart';
import 'package:logging/logging.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/src/callkit/defines.dart';
import 'package:zego_zimkit/src/callkit/notification_manager.dart';
import 'package:zego_zimkit/src/services/audio/core.dart';
import 'package:zego_zimkit/src/services/core/offline_message.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';

export 'defines.dart';

part 'conversation.dart';

part 'group.dart';

part 'message.dart';

part 'message_media.dart';

part 'message_reaction.dart';

part 'user.dart';

const int kDefaultLoadCount = 30; // default is 30
const bool kEnableAutoDownload = true;

class ZIMKitCore
    with ZIMKitCoreEvent, ZIMKitCoreUserData, ZIMKitOfflineMessage {
  factory ZIMKitCore() => instance;

  ZIMKitCore._internal();

  static ZIMKitCore instance = ZIMKitCore._internal();

  int appID = 0;
  String appSign = '';
  String appSecret = '';
  bool useToken = false;

  bool isInited = false;
  ZIMUserFullInfo? currentUser;
  ZIMKitDB db = ZIMKitDB();

  final Map<String, AsyncCache<ZIMGroupFullInfo?>> _queryGroupCache = {};
  final Map<String, AsyncCache<ZIMGroupMemberInfo?>>
      _queryGroupMemberInfoCache = {};
  final Map<int, AsyncCache<ZIMUserFullInfo>> _queryUserCache = {};

  Completer? loginCompleter;

  final totalUnreadMessageCountNotifier = ValueNotifier<int>(0);
  final messageArrivedNotifier = ValueNotifier<ZIMKitReceivedMessages?>(null);

  // Event
  final onGroupStateChangedEventController =
      StreamController<ZIMKitEventGroupStateChanged>.broadcast();
  final onGroupNameUpdatedEventController =
      StreamController<ZIMKitEventGroupNameUpdated>.broadcast();
  final onGroupAvatarUrlUpdatedEventController =
      StreamController<ZIMKitEventGroupAvatarUrlUpdated>.broadcast();
  final onGroupNoticeUpdatedEventController =
      StreamController<ZIMKitEventGroupNoticeUpdated>.broadcast();
  final onGroupAttributesUpdatedEventController =
      StreamController<ZIMKitEventGroupAttributesUpdated>.broadcast();
  final onGroupMemberStateChangedEventController =
      StreamController<ZIMKitEventGroupMemberStateChanged>.broadcast();
  final onGroupMemberInfoUpdatedEventController =
      StreamController<ZIMKitEventGroupMemberInfoUpdated>.broadcast();

  // API
  Future<String> getVersion() async {
    final signalingVersion = await ZegoUIKitSignalingPlugin().getVersion();
    return 'zimkit:1.16.0;plugin:$signalingVersion';
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    Level logLevel = Level.ALL,
    bool enablePrint = true,
    ZegoZIMKitNotificationConfig? notificationConfig,
  }) async {
    if (isInited) {
      ZIMKitLogger.info('has inited.');
      return;
    }

    isInited = true;

    ZIMKitLogger.init(logLevel: logLevel, enablePrint: enablePrint);

    await initOfflineMessage(
      notificationConfig: notificationConfig,
    );

    initEventHandler();

    this.appID = appID;
    this.appSign = appSign;
    this.appSecret = appSecret;

    ZIMKitLogger.info('init, appID:$appID');

    await ZegoUIKitSignalingPlugin().init(appID: appID, appSign: appSign);

    await getVersion().then((value) {
      ZIMKitLogger.info('version: $value');
    });

    await ZIMKitAudioInstance().init();
    await ZIMKitAudioInstance().getVersion().then((value) {
      ZIMKitLogger.info('audio version: $value');
    });
  }

  Future<void> uninit() async {
    if (!isInited) {
      ZIMKitLogger.info('is not inited.');
      return;
    }

    uninitEventHandler();

    ZIMKitLogger.info('destroy.');
    await disconnectUser();
    await ZegoUIKitSignalingPlugin().uninit();
    await ZIMKitAudioInstance().uninit();

    isInited = false;
  }

  void clear() {
    _queryGroupCache.clear();
    _queryUserCache.clear();
    db.clear();
    currentUser = null;
  }

  Stream<ZegoSignalingPluginErrorEvent> getErrorEventStream() {
    return ZegoUIKitSignalingPlugin().getErrorEventStream();
  }

  Stream<ZegoSignalingPluginTokenWillExpireEvent>
      getTokenWillExpireEventStream() {
    return ZegoUIKitSignalingPlugin().getTokenWillExpireEventStream();
  }
}
