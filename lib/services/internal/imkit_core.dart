import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'imkit_core_data.dart';
import 'imkit_core_event.dart';

part 'imkit_logger.dart';

class ZegoIMKitCore with ZegoIMKitCoreEvent {
  ZegoIMKitCoreData coreData = ZegoIMKitCoreData();

  Future<void> init(
      {required int appID, String appSign = '', Level logLevel = Level.ALL, bool enablePrint = true}) async {
    ZegoIMKitLogger.init(logLevel: logLevel, enablePrint: enablePrint);
    initEventHandler();
    coreData.init(appID: appID, appSign: appSign);
  }

  Future<void> uninit() async {
    uninitEventHandler();
    return await coreData.uninit();
  }

  Future<int> login({required String id, String name = ''}) async {
    return coreData.login(id: id, name: name);
  }

  Future<void> logout() async {
    await coreData.logout();
  }

  static ZegoIMKitCore instance = ZegoIMKitCore._internal();
  factory ZegoIMKitCore() => instance;
  ZegoIMKitCore._internal();
}
