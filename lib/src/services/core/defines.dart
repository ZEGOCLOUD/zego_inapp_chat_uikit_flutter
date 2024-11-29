import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';

export 'event.dart';

class ZIMKitDB {
  ZIMKitConversationList conversations = ZIMKitConversationList();

  /// New Message Notification
  final Map<ZIMConversationType, Map<String, ZIMKitMessageList>> _messageList =
      {};
  final Map<String, ZIMKitGroupMemberList> _groupMemberList = {};
  final Map<String, ZIMKitGroupInfoData> _groupInfo = {};

  ZIMKitMessageList messages(String id, ZIMConversationType type) {
    _messageList[type] ??= {};
    _messageList[type]![id] ??= ZIMKitMessageList();
    return _messageList[type]![id]!;
  }

  ZIMKitGroupMemberList groupMemberList(String id) {
    _groupMemberList[id] ??= ZIMKitGroupMemberList();
    return _groupMemberList[id]!;
  }

  ZIMKitGroupInfoData groupInfo(String id) {
    _groupInfo[id] ??= ZIMKitGroupInfoData();
    return _groupInfo[id]!;
  }

  void clear() {
    conversations.clear();
    _messageList
        .forEach((type, map) => map.forEach((id, list) => list.clear()));
  }
}

class ZIMKitGroupInfoData {
  ValueNotifier<ZIMKitGroupInfo> notifier = ValueNotifier(ZIMKitGroupInfo());

  void update(ZIMGroupFullInfo groupInfo) {
    notifier.value = notifier.value
        .copyWith(notice: groupInfo.notice, attributes: groupInfo.attributes);
  }

  void onGroupStateChanged(
      ZIMGroupState state, ZIMGroupEvent event, ZIMGroupFullInfo groupInfo) {
    notifier.value = notifier.value.copyWith(
      notice: groupInfo.notice,
      attributes: groupInfo.attributes,
      event: event,
      state: state,
    );
  }

  void onGroupNoticeUpdated(String notice) {
    notifier.value = notifier.value.copyWith(notice: notice);
  }

  void onGroupAttributesUpdated(List<ZIMGroupAttributesUpdateInfo> updateInfo) {
    final newAttributes = Map<String, String>.from(notifier.value.attributes);
    for (ZIMGroupAttributesUpdateInfo element in updateInfo) {
      if (element.action == ZIMGroupAttributesUpdateAction.set) {
        newAttributes.addAll(element.groupAttributes ?? {});
      } else {
        element.groupAttributes
            ?.forEach((key, value) => newAttributes.remove(key));
      }
    }
    notifier.value = notifier.value.copyWith(attributes: newAttributes);
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
        zimConversationList.map((e) => ValueNotifier(e.toKIT())).toList();
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
      notifier.insert(0, ValueNotifier(zimConversation.toKIT()), notify: false);
      ret = get(id, type);
      if (type == ZIMConversationType.peer) {
        ZIMKit().queryUser(id).then((ZIMUserFullInfo zimResult) {
          final newConversation = ret!.value.clone()
            ..name = zimResult.baseInfo.userName
            ..avatarUrl = zimResult.userAvatarUrl;
          ret.value = newConversation;
        });
      } else if (type == ZIMConversationType.group) {
        ZIM
            .getInstance()!
            .queryGroupInfo(id)
            .then((ZIMGroupInfoQueriedResult? zimResult) {
          if (zimResult != null) {
            ret!.value = ret.value.clone()
              ..name = zimResult.groupInfo.name
              ..avatarUrl = zimResult.groupInfo.url
              ..notificationStatus = ZIMConversationNotificationStatus
                  .values[zimResult.groupInfo.notificationStatus.index];
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
        zimConversationList.map((e) => ValueNotifier(e.toKIT())).toList());
  }

  void deleteAll() {
    notifier.clear();
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

  void insertOrUpdate(ZIMKitConversation kitConversation) {
    final index = notifier.value.indexWhere((element) =>
        element.value.equal(kitConversation.id, kitConversation.type));
    if (index != -1) {
      final oldElement = notifier.value.removeAt(index);
      notifier.insert(0, oldElement);
      oldElement.value = kitConversation;
    } else {
      notifier.insert(0, ValueNotifier(kitConversation));
    }
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
  bool inited = false;

  /// All Messages Notification
  ListNotifier<ValueNotifier<ZIMKitMessage>> notifier = ListNotifier([]);

  bool get notInited => !inited;

  bool hasMore = true;

  bool get noMore => !hasMore;

  set noMore(bool noMore) => hasMore = !noMore;

  bool loading = false;

  void init(List<ZIMMessage> messageList) {
    notifier.value = messageList.map((e) => ValueNotifier(e.toKIT())).toList();
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
    notifier.addAll(
      receiveMessages.reversed.map((e) => ValueNotifier(e.toKIT())),
    );
  }

  void insertAll(List<ZIMMessage> receiveMessages) {
    notifier.insertAll(0, receiveMessages.map((e) => ValueNotifier(e.toKIT())));
  }

  void delete(List<ZIMKitMessage> deleteMessages) {
    for (final message in deleteMessages) {
      notifier.removeWhere((element) {
        return element.value.info.localMessageID == message.info.localMessageID;
      }, notify: false);
    }
    notifier.triggerNotify();
  }

  void deleteAll() {
    notifier.clear();
  }

  ZIMKitMessageNotifier onAttach(ZIMMessage zimMessage) {
    final kitMessage = ValueNotifier(zimMessage.toKIT());
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

  void onSendFailed(int localMessageID) {
    for (final kitMessage in notifier.value) {
      if (kitMessage.value.info.localMessageID == localMessageID) {
        kitMessage.value = (kitMessage.value.clone()
          ..info.sentStatus = ZIMMessageSentStatus.failed);
        break;
      }
    }
  }

  void onMessageReactionsChanged(ZIMMessageReaction reaction) {
    final index = notifier.value
        .indexWhere((e) => (e.value.info.messageID == reaction.messageID));
    if (index == -1) {
      ZIMKitLogger.warning("[db]onMessageReactionsChanged: can't find message");
    } else {
      notifier[index].value.onMessageReactionsChanged(reaction);
    }
  }
}

class ZIMKitReactions {
  String reaction = '';
  List<ZIMReactionUserInfo> userList = [];
  int totalCount = 0;
  String reactionType = '';
  bool isSelfIncluded = false;
}

extension ZIMKitMessageExtension on ZIMKitMessage {
  void sendFailed(PlatformException error) {
    info.sentStatus = ZIMMessageSentStatus.failed;
    info.error = error;
  }

  void sendSuccess() => info.sentStatus = ZIMMessageSentStatus.success;

  void updateExtraInfo(Map extraInfo) {
    zimkitExtraInfo = (Map.from(zimkitExtraInfo)..addAll(extraInfo));
  }

  void onMessageReactionsChanged(ZIMMessageReaction reaction) {
    final index = reactions.value
        .indexWhere((e) => (e.reactionType == reaction.reactionType));
    if (index == -1) {
      reactions.add(reaction);
    } else {
      reactions[index] = reaction;
    }
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
        autoContent!.videoFirstFrameLocalPath =
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
      case ZIMMessageType.custom:
        return customContent;
      default:
        throw Exception('not support type');
    }
  }
}

class ZIMKitGroupMemberList {
  ListNotifier<ZIMGroupMemberInfo> notifier = ListNotifier([]);
  bool fetched = false;
  ValueNotifier<int> count = ValueNotifier(-1);
  ValueNotifier<ZIMGroupMemberInfo?> owner = ValueNotifier(null);

  void updateOwnerOrNot() {
    final search =
        notifier.value.where((e) => (e.memberRole == ZIMGroupMemberRole.owner));
    if (search.isNotEmpty) {
      owner.value = search.first;
    }
  }

  void addAll(Iterable<ZIMGroupMemberInfo> iterable, {bool notify = true}) {
    if (iterable.isEmpty) return;
    notifier.addAll(iterable, notify: false);
    notifier.removeDuplicates((e) => e.userID, notify: false);
    sort(notify: false);
    updateOwnerOrNot();
    if (notify) notifier.triggerNotify();
  }

  void removeAll(Iterable<ZIMGroupMemberInfo> iterable, {bool notify = true}) {
    for (final removeItem in iterable) {
      notifier.removeWhere((e) => e.userID == removeItem.userID, notify: false);
    }
    if (notify) notifier.triggerNotify();
  }

  void removeWhere(bool Function(ZIMGroupMemberInfo memberInfo) test,
      {bool notify = true}) {
    notifier.removeWhere(test, notify: notify);
  }

  void sort({bool notify = true}) {
    if (notifier.value.length < 2) return;
    final myID = ZIMKit().currentUser()?.baseInfo.userID;
    if (myID == null) return;

    notifier.sort((a, b) {
      // owner first
      if (a.memberRole == ZIMGroupMemberRole.owner) return -1;
      if (b.memberRole == ZIMGroupMemberRole.owner) return 1;

      // member last
      if ((a.memberRole == ZIMGroupMemberRole.member) &&
          (a.memberRole == b.memberRole)) {
        // Put me at the top of the list in role category.
        if (a.userID == myID) return -1;
        if (b.userID == myID) return 1;
        return a.userID.compareTo(b.userID);
      }

      if (a.memberRole == ZIMGroupMemberRole.member) {
        return 1;
      }

      if (b.memberRole == ZIMGroupMemberRole.member) {
        return -1;
      }

      // custom role
      int weight(a) {
        int roleWeight = a.memberRole * 2;
        int meWeight = (a.userID == myID) ? -1 : 0;
        return roleWeight + meWeight;
      }

      return weight(a).compareTo(weight(b));
    }, notify: notify);
  }

  void triggerNotify() => notifier.triggerNotify();
}

class ZIMKitReceivedMessages {
  String id;
  ZIMConversationType type;
  List<ZIMKitMessage> receiveMessages;

  ZIMKitReceivedMessages({
    required this.id,
    required this.type,
    required this.receiveMessages,
  });
}
