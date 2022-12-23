import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'package:logging/logging.dart';

import 'package:zego_zimkit/services/internal/imkit_core_data.dart';
import 'package:zego_zimkit/services/internal/imkit_core_event.dart';

part 'imkit_logger.dart';

// TODO core和coreData再整理一下
class ZIMKitCore with ZIMKitCoreEvent {
  factory ZIMKitCore() => instance;
  ZIMKitCore._internal();
  ZIMKitCoreData coreData = ZIMKitCoreData();

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    Level logLevel = Level.ALL,
    bool enablePrint = true,
  }) async {
    ZIMKitLogger.init(logLevel: logLevel, enablePrint: enablePrint);
    initEventHandler();
    coreData.init(appID: appID, appSign: appSign, appSecret: appSecret);
  }

  Future<void> uninit() async {
    uninitEventHandler();
    return coreData.uninit();
  }

  Future<int> connectUser(
      {required String id, String name = '', String token = ''}) async {
    return coreData.connectUser(id: id, name: name, token: token);
  }

  Future<void> disconnectUser() async {
    await coreData.disconnectUser();
  }

  static ZIMKitCore instance = ZIMKitCore._internal();
}
