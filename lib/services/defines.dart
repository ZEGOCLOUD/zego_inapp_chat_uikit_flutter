import 'package:flutter/widgets.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

export 'package:zego_zim/zego_zim.dart';

class ZIMKitConversation {
  ZIMKitConversation(this.data);
  ValueNotifier<ZIMConversation> data;
  bool disable = false;

  String get id => data.value.id;
  ZIMConversationType get type => data.value.type;
  String get name => data.value.name;
  String get url => data.value.url;
  Widget get icon => data.value.icon;
  int get unreadMessageCount => data.value.unreadMessageCount;
  ZIMConversation get zim => data.value;
}

class ZIMKitMessage {
  ZIMKitMessage(this.data);
  ValueNotifier<ZIMMessage> data;
  ValueNotifier<Map> extraInfo = ValueNotifier({});

  dynamic get isSender => data.value.isSender;
  String get tostr => data.value.tostr();
  String get senderUserID => data.value.senderUserID;
  ZIMMessage get zim => data.value;
}
