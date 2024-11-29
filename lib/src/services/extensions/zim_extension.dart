import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/common/avatar.dart';
import 'package:zego_zimkit/src/services/services.dart';

extension ZIMUserInfoExtension on ZIMUserInfo {
  String toStringX() {
    return 'ZIMUserInfo:{'
        'userID:$userID, '
        'userName:$userName, '
        'userAvatarUrl:$userAvatarUrl, '
        '}';
  }
}

extension ZIMGroupMemberInfoExtension on ZIMGroupMemberInfo {
  String toStringX() {
    return 'ZIMGroupMemberInfo:{'
        'userID:$userID, '
        'userName:$userName, '
        'userAvatarUrl:$userAvatarUrl, '
        'memberNickname:$memberNickname, '
        'memberRole:$memberRole, '
        'memberAvatarUrl:$memberAvatarUrl, '
        'muteExpiredTime:$muteExpiredTime, '
        'groupEnterInfo:${groupEnterInfo?.toStringX()}, '
        '}';
  }
}

extension ZIMGroupEnterInfoExtension on ZIMGroupEnterInfo {
  String toStringX() {
    return 'ZIMGroupEnterInfo:{'
        'enterTime:$enterTime, '
        'enterType:$enterType, '
        'operatedUser:$operatedUser, '
        '}';
  }
}

extension ZIMMessageExtend on ZIMMessage {
  ZIMKitMessage toKIT() {
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
      case ZIMMessageType.custom:
        final zimMessage = this as ZIMCustomMessage;
        ret.customContent = (ZIMKitMessageCustomContent()
          ..message = zimMessage.message
          ..type = zimMessage.subType
          ..searchedContent = zimMessage.searchedContent);
        break;
      default:
        break;
    }

    if (this is ZIMMediaMessage &&
        ret.isNetworkUrl &&
        ret.autoContent.fileDownloadUrl.isNotEmpty) {
      ret.autoContent.fileName =
          Uri.parse(ret.autoContent.fileDownloadUrl).pathSegments.last;
    }

    return ret;
  }
}

extension ZIMKitMessageExtend on ZIMKitMessage {
  bool get isMine => info.direction == ZIMMessageDirection.send;

  String toStringValue() {
    switch (type) {
      case ZIMKitMessageType.text:
        return textContent!.text;
      case ZIMKitMessageType.revoke:
        return 'Recalled a message';
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
      ..customContent = customContent
      ..reactions = reactions
      ..zimkitExtraInfo = zimkitExtraInfo
      ..zim = zim;
  }

  // if the media message send with fileDownloadUrl
  // the fileUID will be empty
  bool get isNetworkUrl {
    return (zim is ZIMMediaMessage) && autoContent.fileUID.isEmpty;
  }

  void reGenerateZIMMessage() {
    switch (type) {
      case ZIMKitMessageType.text:
        zim = ZIMTextMessage(message: textContent?.text ?? '');
        break;
      case ZIMMessageType.audio:
      case ZIMMessageType.video:
      case ZIMMessageType.file:
      case ZIMMessageType.image:
        zim = ZIMKitMessageUtils.mediaMessageFactory(
          autoContent.fileLocalPath,
          type,
          audioDuration: audioContent?.audioDuration ?? 0,
        )
          ..fileDownloadUrl = autoContent.fileDownloadUrl
          ..fileName = autoContent.fileName
          ..fileSize = autoContent.fileSize;
        break;
      case ZIMMessageType.custom:
        zim = ZIMCustomMessage(
            message: customContent!.message, subType: customContent!.type)
          ..searchedContent = customContent!.searchedContent;
        break;
      case ZIMMessageType.unknown:
      case ZIMMessageType.command:
      case ZIMMessageType.barrage:
      case ZIMMessageType.system:
      case ZIMMessageType.revoke:
        break;
      case ZIMMessageType.tips:
        // TODO: Handle this case.
        break;
      case ZIMMessageType.combine:
        // TODO: Handle this case.
        break;
    }
    if (zim is ZIMVideoMessage) {
      (zim as ZIMVideoMessage).videoFirstFrameDownloadUrl =
          videoContent!.videoFirstFrameDownloadUrl;
    }
  }
}

extension ZIMImageMessageExtend on ZIMImageMessage {
  double get aspectRatio => (originalImageWidth / originalImageHeight) > 0
      ? (originalImageWidth / originalImageHeight)
      : 1.0;
}

extension ZIMUserFullInfoExtend on ZIMUserFullInfo {
  Widget get icon {
    Widget placeholder = CircleAvatar(
        child: Text(baseInfo.userName.isNotEmpty
            ? baseInfo.userName[0]
            : baseInfo.userID[0]));

    return baseInfo.userAvatarUrl.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: baseInfo.userAvatarUrl,
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
  ZIMKitConversation toKIT() {
    return ZIMKitConversation()
      ..type = type
      ..id = id
      ..name = name.isEmpty ? 'Chat' : name
      ..avatarUrl = conversationAvatarUrl
      ..notificationStatus = notificationStatus
      ..unreadMessageCount = unreadMessageCount
      ..orderKey = orderKey
      ..disable = false
      ..lastMessage = lastMessage?.toKIT();
  }

  String get id => conversationID;

  set id(String value) => conversationID = value;

  String get name => conversationName;

  set name(String value) => conversationName = value;

  String get avatarUrl => conversationAvatarUrl;

  set avatarUrl(String value) => conversationAvatarUrl = value;
}

extension ZIMKitConversationExtend on ZIMKitConversation {
  ZIMConversation toZIM() {
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
        return ZIMKitAvatar(userID: id, name: name);
      case ZIMConversationType.room:
        placeholder =
            CircleAvatar(child: Text(name.isNotEmpty ? name[0] : id[0]));
        break;
      case ZIMConversationType.group:
        placeholder =
            CircleAvatar(child: Text(name.isNotEmpty ? name[0] : id[0]));
        break;
      case ZIMConversationType.unknown:
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

extension ZIMKitGroupInfoExtend on ZIMKitGroupInfo {
  ZIMKitGroupInfo copyWith({
    String? notice,
    Map<String, String>? attributes,
    ZIMGroupState? state,
    ZIMGroupEvent? event,
  }) {
    return ZIMKitGroupInfo()
      ..notice = notice ?? this.notice
      ..attributes = attributes ?? this.attributes
      ..state = state ?? this.state
      ..event = event ?? this.event;
  }
}

extension ZIMGroupFullInfoExtension on ZIMGroupFullInfo {
  ZIMKitConversation toConversation() {
    return baseInfo.toConversation();
  }

  ZIMKitGroupInfo toKit() {
    return ZIMKitGroupInfo()
      ..notice = groupNotice
      ..attributes = groupAttributes;
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

extension ZIMErrorCodeExtension on ZIMErrorCode {
  static bool isFreqLimit(int code) {
    return code == ZIMErrorCode.commonModuleUserIsOperationLimit;
  }
}
