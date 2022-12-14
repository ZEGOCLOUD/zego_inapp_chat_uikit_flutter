import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zego_imkit/zego_imkit.dart';

export 'internal/internal.dart';
export 'defines.dart';

part 'conversation_service.dart';
part 'user_service.dart';
part 'message_service.dart';
part 'room_service.dart';
part 'input_service.dart';
part 'default_dialogs.dart';

class ZegoIMKit
    with
        ZegoConversationService,
        ZegoUserService,
        ZegoMessageService,
        ZegoRoomService,
        ZegoInputService,
        ZegoDefaultDialogService {
  static final ZegoIMKit instance = ZegoIMKit._internal();
  factory ZegoIMKit() => instance;

  Future<void> init({required int appID, String appSign = ''}) async {
    return await ZegoIMKitCore.instance.init(appID: appID, appSign: appSign);
  }

  Future<void> uninit() async {
    return await ZegoIMKitCore.instance.uninit();
  }

  ZegoIMKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
