import 'dart:convert';

import 'package:zego_zimkit/src/services/logger_service.dart';

const String defaultZIMKitMessageChannelID = 'ZIM Message';
const String defaultZIMKitMessageChannelName = 'Message';

const String serializationKeyHandlerPrivateInfo = 'zim_message_handler';

class ZimKitHandlerPrivateInfo {
  String channelID;
  String channelName;
  String sound;
  String icon;
  bool isVibrate;

  ZimKitHandlerPrivateInfo({
    required this.channelID,
    required this.channelName,
    this.sound = '',
    this.icon = '',
    this.isVibrate = false,
  });

  factory ZimKitHandlerPrivateInfo.fromJson(Map<String, dynamic> json) {
    return ZimKitHandlerPrivateInfo(
      channelID: json['cid'] ?? defaultZIMKitMessageChannelID,
      channelName: json['cn'] ?? defaultZIMKitMessageChannelName,
      sound: json['s'] ?? '',
      icon: json['i'] ?? '',
      isVibrate: json['v'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': channelID,
      'cn': channelName,
      's': sound,
      'i': icon,
      'v': isVibrate,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static ZimKitHandlerPrivateInfo? fromJsonString(String jsonString) {
    Map<String, dynamic>? jsonMap;
    try {
      jsonMap = jsonDecode(jsonString);
    } catch (e) {
      ZIMKitLogger.info('handler info, parsing handler info exception:$e');
    }

    return null == jsonMap ? null : ZimKitHandlerPrivateInfo.fromJson(jsonMap);
  }
}
