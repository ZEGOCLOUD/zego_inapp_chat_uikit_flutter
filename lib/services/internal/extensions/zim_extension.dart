import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

extension ZIMMessageExtend on ZIMMessage {
  bool get isSender => direction == ZIMMessageDirection.send;

  String tostr() {
    switch (type) {
      case ZIMMessageType.text:
        return (this as ZIMTextMessage).message;
      case ZIMMessageType.command:
        return '[cmd]';
      case ZIMMessageType.barrage:
        return (this as ZIMBarrageMessage).message;
      case ZIMMessageType.audio:
        return '[audio]';
      case ZIMMessageType.video:
        return '[video]';
      case ZIMMessageType.file:
        return '[file]';
      case ZIMMessageType.image:
        return '[image]';
      case ZIMMessageType.unknown:
        return '[unknown message type]';
      case ZIMMessageType.system:
        return '[system]';
      default:
        return '[unknown message type]';
    }
  }

  ZIMKitMessage tokit() => ZIMKitMessage(ValueNotifier(this));

  ZIMMessage _cloneMediaDetail(ZIMMediaMessage newMessage) {
    final rv = this as ZIMMediaMessage;
    newMessage
      ..fileLocalPath = rv.fileLocalPath
      ..fileDownloadUrl = rv.fileDownloadUrl
      ..fileUID = rv.fileUID
      ..fileName = rv.fileName
      ..fileSize = rv.fileSize;
    return newMessage;
  }

  ZIMMessage _cloneDetail() {
    if (runtimeType == ZIMTextMessage) {
      return ZIMTextMessage(message: (this as ZIMTextMessage).message);
    } else if (runtimeType == ZIMCommandMessage) {
      return ZIMCommandMessage(message: (this as ZIMCommandMessage).message);
    } else if (runtimeType == ZIMBarrageMessage) {
      return ZIMBarrageMessage(message: (this as ZIMBarrageMessage).message);
    } else if (runtimeType == ZIMRevokeMessage) {
      final rv = this as ZIMRevokeMessage;
      return ZIMRevokeMessage()
        ..revokeType = rv.revokeType
        ..revokeStatus = rv.revokeStatus
        ..revokeTimestamp = rv.revokeTimestamp
        ..operatedUserID = rv.operatedUserID
        ..revokeExtendedData = rv.revokeExtendedData
        ..originalMessageType = rv.originalMessageType
        ..originalTextMessageContent = rv.originalTextMessageContent;
    } else if (runtimeType == ZIMSystemMessage) {
      return ZIMSystemMessage(message: (this as ZIMSystemMessage).message);
    } else if (runtimeType == ZIMImageMessage) {
      final rv = this as ZIMImageMessage;
      return _cloneMediaDetail(
        ZIMImageMessage(rv.fileLocalPath)
          ..thumbnailDownloadUrl = rv.thumbnailDownloadUrl
          ..thumbnailLocalPath = rv.thumbnailLocalPath
          ..largeImageDownloadUrl = rv.largeImageDownloadUrl
          ..largeImageLocalPath = rv.largeImageLocalPath
          ..originalImageWidth = rv.originalImageWidth
          ..originalImageHeight = rv.originalImageHeight
          ..largeImageWidth = rv.largeImageWidth
          ..largeImageHeight = rv.largeImageHeight
          ..thumbnailWidth = rv.thumbnailWidth
          ..thumbnailHeight = rv.thumbnailHeight,
      );
    } else if (runtimeType == ZIMVideoMessage) {
      final rv = this as ZIMVideoMessage;
      return _cloneMediaDetail(
        ZIMVideoMessage(rv.fileLocalPath)
          ..videoDuration = rv.videoDuration
          ..videoFirstFrameDownloadUrl = rv.videoFirstFrameDownloadUrl
          ..videoFirstFrameLocalPath = rv.videoFirstFrameLocalPath
          ..videoFirstFrameWidth = rv.videoFirstFrameWidth
          ..videoFirstFrameHeight = rv.videoFirstFrameHeight,
      );
    } else if (runtimeType == ZIMAudioMessage) {
      final rv = this as ZIMAudioMessage;
      return _cloneMediaDetail(
        ZIMAudioMessage(rv.fileLocalPath)..audioDuration = rv.audioDuration,
      );
    } else if (runtimeType == ZIMFileMessage) {
      final rv = this as ZIMFileMessage;
      return _cloneMediaDetail(
        ZIMFileMessage(rv.fileLocalPath),
      );
    } else {
      throw UnimplementedError();
    }
  }

  ZIMMessage clone() {
    return _cloneDetail()
      ..type = type
      ..messageID = messageID
      ..localMessageID = localMessageID
      ..senderUserID = senderUserID
      ..conversationID = conversationID
      ..direction = direction
      ..sentStatus = sentStatus
      ..conversationType = conversationType
      ..timestamp = timestamp
      ..conversationSeq = conversationSeq
      ..orderKey = orderKey
      ..isUserInserted = isUserInserted
      ..receiptStatus = receiptStatus;
  }
}

extension ZIMImageMessageExtend on ZIMImageMessage {
  double get aspectRatio => (originalImageWidth / originalImageHeight) > 0
      ? (originalImageWidth / originalImageHeight)
      : 1.0;
}

extension ZIMUserFullInfoExtend on ZIMUserFullInfo {
  // TODO use ValueListenableBuilder
  // or ZIMUserFullInfo -> ZIMKitUser
  Widget get icon {
    const Widget placeholder = Icon(Icons.person);
    return userAvatarUrl.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: userAvatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => placeholder,
            placeholder: (context, url) => placeholder,
          );
  }
}

extension ZIMString on String {
  ZIMConversationType? toConversationType() {
    try {
      return ZIMConversationType.values
          .where((element) => element.name == this)
          .first;
    } catch (e) {
      return null;
    }
  }
}

extension ZIMConversationExtend on ZIMConversation {
  String get id => conversationID;
  set id(String value) => conversationID = value;

  String get name => conversationName.isEmpty ? 'Chat' : conversationName;
  set name(String value) => conversationName = value;

  String get url => conversationAvatarUrl;
  set url(String value) => conversationAvatarUrl = value;

  bool equal(ZIMConversation other) => id == other.id && type == other.type;

  Widget get icon {
    late Widget placeholder;
    switch (type) {
      case ZIMConversationType.peer:
        return ZIMKitAvatar(userID: id);
      case ZIMConversationType.room:
        placeholder = const Icon(Icons.room);
        break;
      case ZIMConversationType.group:
        placeholder = const Icon(Icons.group);
        break;
    }

    return conversationAvatarUrl.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: conversationAvatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => placeholder,
            placeholder: (context, url) => placeholder,
          );
  }

  ZIMConversation clone() {
    return ZIMConversation()
      ..conversationID = conversationID
      ..conversationName = conversationName
      ..conversationAvatarUrl = conversationAvatarUrl
      ..type = type
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..lastMessage = lastMessage
      ..orderKey = orderKey;
  }

  ZIMKitConversation tokit() => ZIMKitConversation(ValueNotifier(this));
}

extension ZIMGroupFullInfoExtension on ZIMGroupFullInfo {
  ZIMConversation toConversation() {
    return baseInfo.toConversation();
  }

  String get id => baseInfo.groupID;
  String get name => baseInfo.groupName;
  String get url => baseInfo.groupAvatarUrl;
  String get notice => groupNotice;
  Map<String, String> get attributes => groupAttributes;
}

extension ZIMGroupExtension on ZIMGroup {
  ZIMConversation toConversation() {
    return ZIMConversation()
      ..id = baseInfo?.groupID ?? ''
      ..name = baseInfo?.groupName ?? ''
      ..url = baseInfo?.groupAvatarUrl ?? ''
      ..type = ZIMConversationType.group
      ..notificationStatus =
          (notificationStatus == ZIMGroupMessageNotificationStatus.notify
              ? ZIMConversationNotificationStatus.notify
              : ZIMConversationNotificationStatus.doNotDisturb);
  }

  String get id => baseInfo?.groupID ?? '';
  String get name => baseInfo?.groupName ?? '';
  String get url => baseInfo?.groupAvatarUrl ?? '';
}

extension ZIMGroupInfoExtension on ZIMGroupInfo {
  ZIMConversation toConversation() {
    return ZIMConversation()
      ..id = groupID
      ..name = groupName
      ..url = groupAvatarUrl
      ..type = ZIMConversationType.group;
  }

  String get id => groupID;
  String get name => groupName;
  String get url => groupAvatarUrl;
}
