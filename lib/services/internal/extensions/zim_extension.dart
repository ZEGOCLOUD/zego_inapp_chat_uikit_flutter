import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

extension ZIMMessageExtend on ZIMMessage {
  ZIMKitMessage tokit() {
    final ret = ZIMKitMessage()
      ..zim = this
      ..type = type
      ..info = (ZIMKitMessageBaseInfo()
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
        ..receiptStatus = receiptStatus);

    switch (type) {
      case ZIMMessageType.text:
        final zimMessage = this as ZIMTextMessage;
        ret.textContent = ZIMKitMessageTextContent()..text = zimMessage.message;
        break;
      case ZIMMessageType.image:
        final zimMessage = this as ZIMImageMessage;
        ret.imageContent = (ZIMKitMessageImageContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize
          ..thumbnailDownloadUrl = zimMessage.thumbnailDownloadUrl
          ..thumbnailLocalPath = zimMessage.thumbnailLocalPath
          ..largeImageDownloadUrl = zimMessage.largeImageDownloadUrl
          ..largeImageLocalPath = zimMessage.largeImageLocalPath
          ..originalImageWidth = zimMessage.originalImageWidth
          ..originalImageHeight = zimMessage.originalImageHeight
          ..largeImageWidth = zimMessage.largeImageWidth
          ..largeImageHeight = zimMessage.largeImageHeight
          ..thumbnailWidth = zimMessage.thumbnailWidth
          ..thumbnailHeight = zimMessage.thumbnailHeight);
        break;
      case ZIMMessageType.file:
        final zimMessage = this as ZIMFileMessage;
        ret.fileContent = (ZIMKitMessageFileContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize);
        break;
      case ZIMMessageType.audio:
        final zimMessage = this as ZIMAudioMessage;
        ret.audioContent = (ZIMKitMessageAudioContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize
          ..audioDuration = zimMessage.audioDuration);
        break;
      case ZIMMessageType.video:
        final zimMessage = this as ZIMVideoMessage;
        ret.videoContent = (ZIMKitMessageVideoContent()
          ..fileLocalPath = zimMessage.fileLocalPath
          ..fileDownloadUrl = zimMessage.fileDownloadUrl
          ..fileUID = zimMessage.fileUID
          ..fileName = zimMessage.fileName
          ..fileSize = zimMessage.fileSize
          ..videoDuration = zimMessage.videoDuration
          ..videoFirstFrameDownloadUrl = zimMessage.videoFirstFrameDownloadUrl
          ..videoFirstFrameLocalPath = zimMessage.videoFirstFrameLocalPath
          ..videoFirstFrameWidth = zimMessage.videoFirstFrameWidth
          ..videoFirstFrameHeight = zimMessage.videoFirstFrameHeight);
        break;
      case ZIMMessageType.system:
        final zimMessage = this as ZIMSystemMessage;
        ret.systemContent =
            (ZIMKitMessageSystemContent()..info = zimMessage.message);
        break;
      default:
        break;
    }

    return ret;
  }
}

extension ZIMKitMessageExtend on ZIMKitMessage {
  bool get isMine => info.direction == ZIMMessageDirection.send;

  String tostr() {
    switch (type) {
      case ZIMKitMessageType.text:
        return textContent!.text;
      default:
        return '[${type.name}]';
    }
  }

  ZIMKitMessage clone() {
    return ZIMKitMessage()
      ..type = type
      ..info = info
      ..imageContent = imageContent
      ..videoContent = videoContent
      ..audioContent = audioContent
      ..fileContent = fileContent
      ..textContent = textContent
      ..systemContent = systemContent
      ..zim = zim;
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
  ZIMKitConversation tokit() {
    return ZIMKitConversation()
      ..type = type
      ..id = id
      ..name = name.isEmpty ? 'Chat' : name
      ..avatarUrl = conversationAvatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..disable = false
      ..lastMessage = lastMessage?.tokit();
  }

  String get id => conversationID;
  set id(String value) => conversationID = value;
  String get name => conversationName;
  set name(String value) => conversationName = value;
  String get avatarUrl => conversationAvatarUrl;
  set avatarUrl(String value) => conversationAvatarUrl = value;
}

extension ZIMKitConversationExtend on ZIMKitConversation {
  ZIMConversation tozim() {
    return ZIMConversation()
      ..type = type
      ..id = id
      ..name = name
      ..avatarUrl = avatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..lastMessage = lastMessage?.zim;
  }

  bool equal(String id, ZIMConversationType type) =>
      (this.id == id) && (this.type == type);

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

    return avatarUrl.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.cover,
            errorWidget: (context, _, __) => placeholder,
            placeholder: (context, url) => placeholder,
          );
  }

  ZIMKitConversation clone() {
    return ZIMKitConversation()
      ..type = type
      ..id = id
      ..name = name
      ..avatarUrl = avatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..disable = disable
      ..lastMessage = lastMessage;
  }
}

extension ZIMGroupFullInfoExtension on ZIMGroupFullInfo {
  ZIMKitConversation toConversation() {
    return baseInfo.toConversation();
  }

  String get id => baseInfo.groupID;
  String get name => baseInfo.groupName;
  String get url => baseInfo.groupAvatarUrl;
  String get notice => groupNotice;
  Map<String, String> get attributes => groupAttributes;
}

extension ZIMGroupExtension on ZIMGroup {
  ZIMKitConversation toConversation() {
    return ZIMKitConversation()
      ..id = baseInfo?.groupID ?? ''
      ..name = baseInfo?.groupName ?? ''
      ..avatarUrl = baseInfo?.groupAvatarUrl ?? ''
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
  ZIMKitConversation toConversation() {
    return ZIMKitConversation()
      ..id = groupID
      ..name = groupName
      ..avatarUrl = groupAvatarUrl
      ..type = ZIMConversationType.group;
  }

  String get id => groupID;
  String get name => groupName;
  String get url => groupAvatarUrl;
}
