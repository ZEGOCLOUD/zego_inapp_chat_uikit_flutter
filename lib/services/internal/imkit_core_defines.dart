import 'package:zego_imkit/zego_imkit.dart';

class ZegoIMKitDB {
  ZegoIMKitConversationList conversations = ZegoIMKitConversationList();
  ZegoIMKitMessageList messages(String id, ZIMConversationType type) {
    _messageList[type] ??= {};
    _messageList[type]![id] ??= ZegoIMKitMessageList();
    return _messageList[type]![id]!;
  }

  final Map<ZIMConversationType, Map<String, ZegoIMKitMessageList>>
      _messageList = {};

  void clear() {
    // todo 测试切换账号
    conversations.clear();
    _messageList
        .forEach((type, map) => map.forEach((id, list) => list.clear()));
  }
}

class ZegoIMKitConversationList {
  bool inited = false;
  get notInited => !inited;

  bool hasMore = true;
  bool get noMore => !hasMore;
  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  ListNotifier<ZegoIMKitConversation> data = ListNotifier([]);

  void init(List<ZIMConversation> zimConversationList) {
    data.value = zimConversationList.map((e) => e.tokit()).toList();
    inited = true;
  }

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;

  void clear() {
    data.clear();
    inited = false;
    hasMore = true;
  }

  ZegoIMKitConversation get(String id, ZIMConversationType type) {
    ZegoIMKitConversation? ret;
    for (int i = 0; i < data.length; i++) {
      if (data[i].equal2(id, type)) {
        ret = data[i];
        break;
      }
    }

    if (ret == null) {
      var zimConversation = ZIMConversation();
      zimConversation.id = id;
      zimConversation.type = type;
      data.value.insert(0, zimConversation.tokit());
      ret = get(id, type);
      if (type == ZIMConversationType.peer) {
        ZegoIMKit().queryUser(id).then((ZIMUserFullInfo zimResult) {
          ZIMConversation newConversation = ret!.data.value.clone();
          newConversation.name = zimResult.baseInfo.userName;
          newConversation.url = zimResult.userAvatarUrl;
          ret.data.value = newConversation;
        });
      }
    }

    return ret;
  }

  void addAll(List<ZIMConversation> zimConversationList) {
    data.addAll(zimConversationList.map((e) => e.tokit()).toList());
  }

  void delete(String id, ZIMConversationType type) {
    data.removeWhere((ZegoIMKitConversation element) {
      if (element.equal2(id, type)) {
        return true;
      } else {
        return false;
      }
    });
  }

  void insert(ZIMConversation zimConversation) {
    if (update(zimConversation)) {
      return;
    }
    data.insert(0, zimConversation.tokit());
  }

  bool update(ZIMConversation zimConversation) {
    for (int i = 0; i < data.length; i++) {
      if (data[i].equal(zimConversation)) {
        data[i] = zimConversation.tokit();
        return true;
      }
    }
    return false;
  }

  void disable(ZIMConversation zimConversation) {
    for (int i = 0; i < data.length; i++) {
      if (data[i].equal(zimConversation)) {
        data[i].disable = true;
        break;
      }
    }
  }

  void remove(String id, ZIMConversationType type) {
    data.removeWhere((element) => element.equal2(id, type));
  }
}

extension ZegoIMKitConversationExtension on ZegoIMKitConversation {
  equal(ZIMConversation zimConversation) =>
      equal2(zimConversation.id, zimConversation.type);
  equal2(String id, ZIMConversationType type) =>
      (data.value.id == id) && (data.value.type == type);
}

class ZegoIMKitMessageList {
  ListNotifier<ZegoIMKitMessage> data = ListNotifier([]);
  bool inited = false;
  get notInited => !inited;

  bool hasMore = true;
  bool get noMore => !hasMore;
  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  void init(List<ZIMMessage> messageList) {
    data.value = messageList.map((e) => e.tokit()).toList();
    inited = true;
  }

  bool isEmpty() => data.isEmpty;
  bool isNotEmpty() => data.isNotEmpty;

  void clear() {
    data.clear();
    inited = false;
    hasMore = true;
  }

  void receive(List<ZIMMessage> receiveMessages) {
    data.addAll(receiveMessages.map((e) => e.tokit()));
  }

  void insertAll(List<ZIMMessage> receiveMessages) {
    data.insertAll(0, receiveMessages.map((e) => e.tokit()));
  }

  void attach(ZegoIMKitMessage kitMessage) => data.add(kitMessage);
}

extension ZegoIMKitMessageExtension on ZegoIMKitMessage {
  void updateExtraInfo(Map map) =>
      extraInfo.value = Map.from(extraInfo.value)..addAll(map);

  void sendFaild() {
    data.value = (data.value.clone()..sentStatus = ZIMMessageSentStatus.failed);
  }

  void download() => ZegoIMKit().downloadMediaFile(this);

  void uploadDone(ZIMMessage zimMessage) => data.value = zimMessage;

  void downloadDone(ZIMMediaFileType downloadType, ZIMMessage zimMessage) {
    switch (downloadType) {
      case ZIMMediaFileType.originalFile:
        data.value = ((data.value.clone() as ZIMMediaMessage)
          ..fileLocalPath = (zimMessage as ZIMMediaMessage).fileLocalPath);
        break;
      case ZIMMediaFileType.largeImage:
        data.value = ((data.value.clone() as ZIMImageMessage)
          ..largeImageLocalPath =
              (zimMessage as ZIMImageMessage).largeImageLocalPath);
        break;
      case ZIMMediaFileType.thumbnail:
        data.value = ((data.value.clone() as ZIMImageMessage)
          ..thumbnailLocalPath =
              (zimMessage as ZIMImageMessage).thumbnailLocalPath);

        break;
      case ZIMMediaFileType.videoFirstFrame:
        data.value = ((data.value.clone() as ZIMVideoMessage)
          ..videoFirstFrameLocalPath =
              (zimMessage as ZIMVideoMessage).videoFirstFrameLocalPath);
        break;
    }
  }
}
