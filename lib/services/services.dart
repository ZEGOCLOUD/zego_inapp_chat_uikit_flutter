import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

export 'defines.dart';
export 'internal/internal.dart';

part 'conversation_service.dart';
part 'group_service.dart';
part 'input_service.dart';
part 'message_service.dart';
part 'user_service.dart';

class ZIMKit
    with
        ZIMKitConversationService,
        ZIMKitUserService,
        ZIMKitMessageService,
        ZIMKitInputService,
        ZIMKitGroupService {
  factory ZIMKit() => instance;

  ZIMKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }
  static final ZIMKit instance = ZIMKit._internal();

  Future<void> init(
      {required int appID, String appSign = '', String appSecret = ''}) async {
    return ZIMKitCore.instance
        .init(appID: appID, appSign: appSign, appSecret: appSecret);
  }

  Future<void> uninit() async {
    return ZIMKitCore.instance.uninit();
  }
}
