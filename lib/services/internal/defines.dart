import 'package:flutter/foundation.dart';
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

  ListNotifier<ValueNotifier<ZIMKitConversation>> notifier = ListNotifier([]);

  void init(List<ZIMConversation> zimConversationList) {
    notifier.value =
        zimConversationList.map((e) => ValueNotifier(e.tokit())).toList();
    inited = true;
  }

  bool get isEmpty => notifier.isEmpty;
  bool get isNotEmpty => notifier.isNotEmpty;

  void clear() {
    notifier.clear();
    inited = false;
    hasMore = true;
  }

  ValueNotifier<ZIMKitConversation> get(String id, ZIMConversationType type) {
    ValueNotifier<ZIMKitConversation>? ret;
    for (var i = 0; i < notifier.length; i++) {
      if (notifier[i].value.equal(id, type)) {
        ret = notifier[i];
        break;
      }
    }

    if (ret == null) {
      final zimConversation = ZIMConversation()
        ..id = id
        ..type = type;
      // so here do not notify ui, will notify later
      notifier.insert(0, ValueNotifier(zimConversation.tokit()), notify: false);
      ret = get(id, type);
      if (type == ZIMConversationType.peer) {
        ZIMKit().queryUser(id).then((ZIMUserFullInfo zimResult) {
          final newConversation = ret!.value.clone()
            ..name = zimResult.baseInfo.userName
            ..avatarUrl = zimResult.userAvatarUrl;
          ret.value = newConversation;
        });
      } else if (type == ZIMConversationType.group) {
        ZIMKitCore.instance.queryGroup(id).then((ZIMGroupFullInfo? zimResult) {
          if (zimResult != null) {
            ret!.value = ret.value.clone()
              ..name = zimResult.name
              ..avatarUrl = zimResult.url
              ..notificationStatus = ZIMConversationNotificationStatus
                  .values[zimResult.notificationStatus.index];
          } else {
            notifier.triggerNotify();
          }
        });
      }
    }

    return ret;
  }

  void addAll(List<ZIMConversation> zimConversationList) {
    notifier.addAll(
        zimConversationList.map((e) => ValueNotifier(e.tokit())).toList());
  }

  void delete(String id, ZIMConversationType type) {
    notifier.removeWhere((element) {
      if (element.value.equal(id, type)) {
        return true;
      } else {
        return false;
      }
    });
  }

  void insert(ZIMKitConversation kitConversation) {
    notifier.value.removeWhere((element) =>
        element.value.equal(kitConversation.id, kitConversation.type));
    notifier.insert(0, ValueNotifier(kitConversation));
  }

  void update(ZIMKitConversation kitConversation) {
    notifier.value.removeWhere((element) =>
        element.value.equal(kitConversation.id, kitConversation.type));
    notifier.insert(0, ValueNotifier(kitConversation));
    sort();
  }

  void disable(ZIMKitConversation kitConversation) {
    for (var i = 0; i < notifier.length; i++) {
      if (notifier[i].value.equal(kitConversation.id, kitConversation.type)) {
        notifier[i].value = (notifier[i].value.clone()..disable = true);
        break;
      }
    }
    sort();
  }

  void remove(String id, ZIMConversationType type) {
    notifier.removeWhere((element) => element.value.equal(id, type));
  }

  void sort() {
    notifier.sort((a, b) {
      return b.value.orderKey.compareTo(a.value.orderKey);
    });
  }
}

class ZIMKitMessageList {
  ListNotifier<ValueNotifier<ZIMKitMessage>> notifier = ListNotifier([]);
  bool inited = false;
  bool get notInited => !inited;

  bool hasMore = true;
  bool get noMore => !hasMore;
  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  void init(List<ZIMMessage> messageList) {
    notifier.value = messageList.map((e) => ValueNotifier(e.tokit())).toList();
    inited = true;
  }

  bool isEmpty() => notifier.isEmpty;
  bool isNotEmpty() => notifier.isNotEmpty;

  void clear() {
    notifier.clear();
    inited = false;
    hasMore = true;
  }

  void receive(List<ZIMMessage> receiveMessages) {
    notifier
        .addAll(receiveMessages.reversed.map((e) => ValueNotifier(e.tokit())));
  }

  void insertAll(List<ZIMMessage> receiveMessages) {
    notifier.insertAll(0, receiveMessages.map((e) => ValueNotifier(e.tokit())));
  }

  ZIMKitMessageNotifier onAttach(ZIMMessage zimMessage) {
    final kitMessage = ValueNotifier(zimMessage.tokit());
    notifier.add(kitMessage);
    return kitMessage;
  }

  void onSendSuccess(int localMessageID) {
    for (final kitMessage in notifier.value) {
      if (kitMessage.value.info.localMessageID == localMessageID) {
        kitMessage.value = (kitMessage.value.clone()
          ..info.sentStatus = ZIMMessageSentStatus.success);
        break;
      }
    }
  }

  void onSendFaild(int localMessageID) {
    for (final kitMessage in notifier.value) {
      if (kitMessage.value.info.localMessageID == localMessageID) {
        kitMessage.value = (kitMessage.value.clone()
          ..info.sentStatus = ZIMMessageSentStatus.failed);
        break;
      }
    }
  }
}

extension ZIMKitMessageExtension on ZIMKitMessage {
  void sendFaild() => info.sentStatus = ZIMMessageSentStatus.failed;
  void sendSuccess() => info.sentStatus = ZIMMessageSentStatus.success;
  void updateExtraInfo(Map extraInfo) {
    this.extraInfo = (Map.from(this.extraInfo)..addAll(extraInfo));
  }

  void downloadDone(ZIMMediaFileType downloadType, ZIMMessage zimMessage) {
    switch (downloadType) {
      case ZIMMediaFileType.originalFile:
        autoContent!.fileLocalPath =
            (zimMessage as ZIMMediaMessage).fileLocalPath;
        break;
      case ZIMMediaFileType.largeImage:
        autoContent!.fileLocalPath =
            (zimMessage as ZIMImageMessage).largeImageLocalPath;
        break;
      case ZIMMediaFileType.thumbnail:
        autoContent!.fileLocalPath =
            (zimMessage as ZIMImageMessage).thumbnailLocalPath;
        break;
      case ZIMMediaFileType.videoFirstFrame:
        autoContent!.fileLocalPath =
            (zimMessage as ZIMVideoMessage).videoFirstFrameLocalPath;
        break;
    }
  }

  dynamic get autoContent {
    switch (type) {
      case ZIMMessageType.image:
        return imageContent;
      case ZIMMessageType.file:
        return fileContent;
      case ZIMMessageType.audio:
        return audioContent;
      case ZIMMessageType.video:
        return videoContent;
      case ZIMMessageType.system:
        return systemContent;
      case ZIMMessageType.text:
        return textContent;
      default:
        throw Exception('not support type');
    }
  }
}
