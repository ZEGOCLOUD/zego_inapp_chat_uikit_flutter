import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/callkit/defines.dart';
import 'package:zego_zimkit/src/channel/platform_interface.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/services/defines.dart';
import 'package:zego_zimkit/src/services/extensions/extensions.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';

part 'conversation_service.dart';

part 'group_service.dart';

part 'helper_service.dart';

part 'input_service.dart';

part 'message_service.dart';

part 'user_service.dart';

/// {@category Get started}
/// {@category APIs}
/// {@category Events}
/// {@category Configs}
class ZIMKit
    with
        ZIMKitConversationService,
        ZIMKitUserService,
        ZIMKitMessageService,
        ZIMKitInputService,
        ZIMKitGroupService,
        ZIMKitHelperService {
  factory ZIMKit() => instance;

  ZIMKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static final ZIMKit instance = ZIMKit._internal();

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    ZegoZIMKitNotificationConfig? notificationConfig,
  }) async {
    return ZIMKitCore.instance.init(
      appID: appID,
      appSign: appSign,
      appSecret: appSecret,
      notificationConfig: notificationConfig,
    );
  }

  Future<void> uninit() async {
    return ZIMKitCore.instance.uninit();
  }
}
