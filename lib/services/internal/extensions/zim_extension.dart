import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zego_imkit/zego_imkit.dart';

extension ZIMMessageExtend on ZIMMessage {
  get isSender => direction == ZIMMessageDirection.send;

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

  ZegoIMKitMessage tokit() => ZegoIMKitMessage(ValueNotifier(this));

  ZIMMessage _cloneMediaDetail(ZIMMediaMessage newMessage) {
    var rv = (this as ZIMMediaMessage);
    newMessage.fileLocalPath = rv.fileLocalPath;
    newMessage.fileDownloadUrl = rv.fileDownloadUrl;
    newMessage.fileUID = rv.fileUID;
    newMessage.fileName = rv.fileName;
    newMessage.fileSize = rv.fileSize;
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
      var rv = (this as ZIMRevokeMessage);
      var newMessage = ZIMRevokeMessage();
      newMessage.revokeType = rv.revokeType;
      newMessage.revokeStatus = rv.revokeStatus;
      newMessage.revokeTimestamp = rv.revokeTimestamp;
      newMessage.operatedUserID = rv.operatedUserID;
      newMessage.revokeExtendedData = rv.revokeExtendedData;
      newMessage.originalMessageType = rv.originalMessageType;
      newMessage.originalTextMessageContent = rv.originalTextMessageContent;
      return newMessage;
    } else if (runtimeType == ZIMSystemMessage) {
      return ZIMSystemMessage(message: (this as ZIMSystemMessage).message);
    } else if (runtimeType == ZIMImageMessage) {
      var rv = (this as ZIMImageMessage);
      var newMessage = ZIMImageMessage(rv.fileLocalPath);
      newMessage.thumbnailDownloadUrl = rv.thumbnailDownloadUrl;
      newMessage.thumbnailLocalPath = rv.thumbnailLocalPath;
      newMessage.largeImageDownloadUrl = rv.largeImageDownloadUrl;
      newMessage.largeImageLocalPath = rv.largeImageLocalPath;
      newMessage.originalImageWidth = rv.originalImageWidth;
      newMessage.originalImageHeight = rv.originalImageHeight;
      newMessage.largeImageWidth = rv.largeImageWidth;
      newMessage.largeImageHeight = rv.largeImageHeight;
      newMessage.thumbnailWidth = rv.thumbnailWidth;
      newMessage.thumbnailHeight = rv.thumbnailHeight;
      newMessage = _cloneMediaDetail(newMessage) as ZIMImageMessage;
      return newMessage;
    } else if (runtimeType == ZIMVideoMessage) {
      var rv = (this as ZIMVideoMessage);
      var newMessage = ZIMVideoMessage(rv.fileLocalPath);
      newMessage.videoDuration = rv.videoDuration;
      newMessage.videoFirstFrameDownloadUrl = rv.videoFirstFrameDownloadUrl;
      newMessage.videoFirstFrameLocalPath = rv.videoFirstFrameLocalPath;
      newMessage.videoFirstFrameWidth = rv.videoFirstFrameWidth;
      newMessage.videoFirstFrameHeight = rv.videoFirstFrameHeight;
      newMessage = _cloneMediaDetail(newMessage) as ZIMVideoMessage;
      return newMessage;
    } else if (runtimeType == ZIMAudioMessage) {
      var rv = (this as ZIMAudioMessage);
      var newMessage = ZIMAudioMessage(rv.fileLocalPath);
      newMessage.audioDuration = rv.audioDuration;
      newMessage = _cloneMediaDetail(newMessage) as ZIMAudioMessage;
      return newMessage;
    } else if (runtimeType == ZIMFileMessage) {
      var rv = (this as ZIMFileMessage);
      var newMessage = ZIMFileMessage(rv.fileLocalPath);
      newMessage = _cloneMediaDetail(newMessage) as ZIMFileMessage;
      return newMessage;
    } else {
      throw UnimplementedError();
    }
  }

  ZIMMessage clone() {
    var newMessage = _cloneDetail();
    newMessage.type = type;
    newMessage.messageID = messageID;
    newMessage.localMessageID = localMessageID;
    newMessage.senderUserID = senderUserID;
    newMessage.conversationID = conversationID;
    newMessage.direction = direction;
    newMessage.sentStatus = sentStatus;
    newMessage.conversationType = conversationType;
    newMessage.timestamp = timestamp;
    newMessage.conversationSeq = conversationSeq;
    newMessage.orderKey = orderKey;
    newMessage.isUserInserted = isUserInserted;
    newMessage.receiptStatus = receiptStatus;
    return newMessage;
  }
}

extension ZIMImageMessageExtend on ZIMImageMessage {
  double get aspectRatio => (originalImageWidth / originalImageHeight) > 0
      ? (originalImageWidth / originalImageHeight)
      : 1.0;
}

extension ZIMUserFullInfoExtend on ZIMUserFullInfo {
  // TODO use ValueListenableBuilder
  // or ZIMUserFullInfo -> ZegoIMKitUser
  Widget get icon {
    Widget placeholder = const Icon(Icons.person);
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

  equal(ZIMConversation other) => id == other.id && type == other.type;

  Widget get icon {
    late Widget placeholder;
    switch (type) {
      case ZIMConversationType.peer:
        return ZegoIMKitAvatar(userID: id);
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
    var newConversation = ZIMConversation();
    newConversation.conversationID = conversationID;
    newConversation.conversationName = conversationName;
    newConversation.conversationAvatarUrl = conversationAvatarUrl;
    newConversation.type = type;
    newConversation.notificationStatus = notificationStatus;
    newConversation.unreadMessageCount = unreadMessageCount;
    newConversation.lastMessage = lastMessage;
    newConversation.orderKey = orderKey;
    return newConversation;
  }

  ZegoIMKitConversation tokit() => ZegoIMKitConversation(ValueNotifier(this));
}

extension ZIMGroupFullInfoExtension on ZIMGroupFullInfo {
  ZIMConversation toConversation() {
    var newConversation = ZIMConversation();
    newConversation.id = baseInfo.groupID;
    newConversation.name = baseInfo.groupName;
    newConversation.url = baseInfo.groupAvatarUrl;
    newConversation.type = ZIMConversationType.group;
    return newConversation;
  }
}
