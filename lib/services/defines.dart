import 'package:flutter/widgets.dart';
import 'package:zego_imkit/zego_imkit.dart';
export 'package:zego_zim/zego_zim.dart';

class ZegoIMKitConversation {
  ValueNotifier<ZIMConversation> data;
  bool disable = false;

  ZegoIMKitConversation(this.data);

  String get id => data.value.id;
  ZIMConversationType get type => data.value.type;
  String get name => data.value.name;
  String get url => data.value.url;
  Widget get icon => data.value.icon;
  int get unreadMessageCount => data.value.unreadMessageCount;
  get zim => data.value;
}

class ZegoIMKitMessage {
  ValueNotifier<ZIMMessage> data;
  ValueNotifier<Map> extraInfo = ValueNotifier({});

  ZegoIMKitMessage(this.data);

  get isSender => data.value.isSender;
  get tostr => data.value.tostr();
  get senderUserID => data.value.senderUserID;
  get zim => data.value;
}
