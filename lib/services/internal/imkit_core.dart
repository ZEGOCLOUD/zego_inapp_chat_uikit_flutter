import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/services/internal/defines.dart';
import 'package:zego_zimkit/services/internal/event.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

part 'imkit_core_conversation.dart';
part 'imkit_core_group.dart';
part 'imkit_core_message.dart';
part 'imkit_core_user.dart';
part 'imkit_logger.dart';

const int kdefaultLoadCount = 30; // default is 30
const bool kEnableAutoDownload = true;

class ZIMKitCore with ZIMKitCoreEvent, ZIMKitCoreUserData {
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
  final Map<int, AsyncCache<ZIMUserFullInfo>> _queryUserCache = {};

  Completer? loginCompleter;
  Future<String> getVersion() async {
    final signalingVersion = await ZegoUIKitSignalingPlugin().getVersion();
    return 'imkit:0.1.1;plugin:$signalingVersion';
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    Level logLevel = Level.ALL,
    bool enablePrint = true,
  }) async {
    if (isInited) {
      ZIMKitLogger.info('has inited.');
      return;
    }
    isInited = true;
    ZIMKitLogger.init(logLevel: logLevel, enablePrint: enablePrint);
    initEventHandler();

    this.appID = appID;
    this.appSign = appSign;
    this.appSecret = appSecret;

    ZIMKitLogger.info('init, appID:$appID');

    ZegoUIKitSignalingPlugin().init(appID: appID, appSign: appSign);

    getVersion().then((value) {
      ZIMKitLogger.info('Zego IM SDK version: $value');
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
    ZegoUIKitSignalingPlugin().uninit();
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
