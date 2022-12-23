import 'package:zego_zimkit/zego_zimkit.dart';

class ZIMKitDB {
  ZIMKitConversationList conversations = ZIMKitConversationList();
  ZIMKitMessageList messages(String id, ZIMConversationType type) {
    _messageList[type] ??= {};
    _messageList[type]![id] ??= ZIMKitMessageList();
    return _messageList[type]![id]!;
  }

  final Map<ZIMConversationType, Map<String, ZIMKitMessageList>> _messageList =
      {};

  void clear() {
    // todo 测试切换账号
    conversations.clear();
    _messageList
        .forEach((type, map) => map.forEach((id, list) => list.clear()));
  }
}

class ZIMKitConversationList {
  bool inited = false;
  bool get notInited => !inited;

  bool hasMore = true;
  bool get noMore => !hasMore;
  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  ListNotifier<ZIMKitConversation> data = ListNotifier([]);

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

  ZIMKitConversation get(String id, ZIMConversationType type) {
    ZIMKitConversation? ret;
    for (var i = 0; i < data.length; i++) {
      if (data[i].equal2(id, type)) {
        ret = data[i];
        break;
      }
    }

    if (ret == null) {
      final zimConversation = ZIMConversation()
        ..id = id
        ..type = type;
      data.value.insert(0, zimConversation.tokit());
      ret = get(id, type);
      if (type == ZIMConversationType.peer) {
        ZIMKit().queryUser(id).then((ZIMUserFullInfo zimResult) {
          final newConversation = ret!.data.value.clone()
            ..name = zimResult.baseInfo.userName
            ..url = zimResult.userAvatarUrl;
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
    data.removeWhere((ZIMKitConversation element) {
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
    for (var i = 0; i < data.length; i++) {
      if (data[i].equal(zimConversation)) {
        data[i] = zimConversation.tokit();
        return true;
      }
    }
    return false;
  }

  void disable(ZIMConversation zimConversation) {
    for (var i = 0; i < data.length; i++) {
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

extension ZIMKitConversationExtension on ZIMKitConversation {
  dynamic equal(ZIMConversation zimConversation) =>
      equal2(zimConversation.id, zimConversation.type);
  bool equal2(String id, ZIMConversationType type) =>
      (data.value.id == id) && (data.value.type == type);
}

class ZIMKitMessageList {
  ListNotifier<ZIMKitMessage> data = ListNotifier([]);
  bool inited = false;
  bool get notInited => !inited;

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

  void attach(ZIMKitMessage kitMessage) => data.add(kitMessage);
}

extension ZIMKitMessageExtension on ZIMKitMessage {
  void updateExtraInfo(Map map) =>
      extraInfo.value = Map.from(extraInfo.value)..addAll(map);

  void sendFaild() {
    data.value = (data.value.clone()..sentStatus = ZIMMessageSentStatus.failed);
  }

  void download() => ZIMKit().downloadMediaFile(this);

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
