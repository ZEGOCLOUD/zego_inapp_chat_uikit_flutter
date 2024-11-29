import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/src/services/extensions/extensions.dart';

typedef ZIMKitMessageNotifier = ValueNotifier<ZIMKitMessage>;
typedef ZIMKitMessageListNotifier = ListNotifier<ZIMKitMessageNotifier>;
typedef ZIMKitConversationNotifier = ValueNotifier<ZIMKitConversation>;
typedef ZIMKitConversationListNotifier
    = ListNotifier<ZIMKitConversationNotifier>;

class ZIMKitConversation {
  ZIMConversationType type = ZIMConversationType.peer;

  // conversation
  String id = '';
  String name = '';
  String avatarUrl = '';
  ZIMConversationNotificationStatus notificationStatus =
      ZIMConversationNotificationStatus.notify;
  int unreadMessageCount = 0;
  int orderKey = 0;
  bool disable = false;
  ZIMKitMessage? lastMessage;
}

class ZIMKitGroupInfo {
  String notice = "";
  Map<String, String> attributes = {};
  ZIMGroupState state = ZIMGroupState.enter;
  ZIMGroupEvent event = ZIMGroupEvent.created;
}

typedef ZIMKitMessageType = ZIMMessageType;

class ZIMKitMessage {
  ZIMKitMessageType type = ZIMKitMessageType.unknown;

  ZIMKitMessageBaseInfo info = ZIMKitMessageBaseInfo();

  ZIMKitMessageImageContent? imageContent;
  ZIMKitMessageVideoContent? videoContent;
  ZIMKitMessageAudioContent? audioContent;
  ZIMKitMessageFileContent? fileContent;
  ZIMKitMessageTextContent? textContent;
  ZIMKitMessageSystemContent? systemContent;
  ZIMKitMessageCustomContent? customContent;

  ListNotifier<ZIMMessageReaction> reactions = ListNotifier([]);

  ValueNotifier<String> localExtendedData = ValueNotifier('');

  Map zimkitExtraInfo = {}; // ZIMKit Internal Use Only.
  ZIMMessage zim = ZIMMessage(); // ZIMKit Internal Use Only.

  @override
  String toString() {
    return 'ZIMKitMessage{'
        'type:$type, '
        'info:$info, '
        'imageContent:$imageContent, '
        'videoContent:$videoContent, '
        'audioContent:$audioContent, '
        'fileContent:$fileContent, '
        'textContent:$textContent, '
        'systemContent:$systemContent, '
        'customContent:$customContent, '
        'reactions:$reactions, '
        'localExtendedData:$localExtendedData, '
        'zimkitExtraInfo:$zimkitExtraInfo, '
        'zim:${zim.toStringX()}, '
        '}';
  }
}

extension ZIMMessageExtensionString on ZIMMessage {
  String toStringX() {
    return 'ZIMMessage{'
        'type:$type, '
        'messageID:$messageID, '
        'localMessageID:$localMessageID, '
        'senderUserID:$senderUserID, '
        'conversationID:$conversationID, '
        'direction:$direction, '
        'sentStatus:$sentStatus, '
        'conversationType:$conversationType, '
        'timestamp:$timestamp, '
        'conversationSeq:$conversationSeq, '
        'orderKey:$orderKey, '
        'isUserInserted:$isUserInserted, '
        'receiptStatus:$receiptStatus, '
        'extendedData:$extendedData, '
        'localExtendedData:$localExtendedData, '
        'isBroadcastMessage:$isBroadcastMessage, '
        'reactions:$reactions, '
        '}';
  }
}

class ZIMKitMessageTextContent {
  late String text;

  @override
  String toString() {
    return 'ZIMKitMessageTextContent{text:$text}';
  }
}

class ZIMKitMessageBaseInfo {
  int messageID = 0;
  int localMessageID = 0;
  String senderUserID = '';
  String conversationID = '';
  ZIMMessageDirection direction = ZIMMessageDirection.send;
  ZIMMessageSentStatus sentStatus = ZIMMessageSentStatus.sending;
  ZIMConversationType conversationType = ZIMConversationType.peer;
  int timestamp = 0;
  int conversationSeq = 0;
  int orderKey = 0;
  bool isUserInserted = false;
  PlatformException? error;
  ZIMMessageReceiptStatus receiptStatus = ZIMMessageReceiptStatus.none;

  @override
  String toString() {
    return 'ZIMKitMessageBaseInfo{'
        'messageID:$messageID, '
        'localMessageID:$localMessageID, '
        'senderUserID:$senderUserID, '
        'conversationID:$conversationID, '
        'direction:$direction, '
        'sentStatus:$sentStatus, '
        'conversationType:$conversationType, '
        'timestamp:$timestamp, '
        'conversationSeq:$conversationSeq, '
        'orderKey:$orderKey, '
        'isUserInserted:$isUserInserted, '
        'error:$error, '
        'receiptStatus:$receiptStatus, '
        '}';
  }
}

class ZIMKitMessageImageContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

  // image
  String thumbnailDownloadUrl = '';
  String thumbnailLocalPath = '';
  String largeImageDownloadUrl = '';
  String largeImageLocalPath = '';
  int originalImageWidth = 0;
  int originalImageHeight = 0;
  int largeImageWidth = 0;
  int largeImageHeight = 0;
  int thumbnailWidth = 0;
  int thumbnailHeight = 0;

  double get aspectRatio => (originalImageWidth / originalImageHeight) > 0
      ? (originalImageWidth / originalImageHeight)
      : 1.0;

  @override
  String toString() {
    return 'ZIMKitMessageImageContent{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        'thumbnailDownloadUrl:$thumbnailDownloadUrl, '
        'thumbnailLocalPath:$thumbnailLocalPath, '
        'largeImageDownloadUrl:$largeImageDownloadUrl, '
        'largeImageLocalPath:$largeImageLocalPath, '
        'originalImageWidth:$originalImageWidth, '
        'originalImageHeight:$originalImageHeight, '
        'largeImageWidth:$largeImageWidth, '
        'largeImageHeight:$largeImageHeight, '
        'thumbnailWidth:$thumbnailWidth, '
        'thumbnailHeight:$thumbnailHeight, '
        '}';
  }
}

class ZIMKitMessageVideoContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

  // video
  int videoDuration = 0;
  String videoFirstFrameDownloadUrl = '';
  String videoFirstFrameLocalPath = '';
  int videoFirstFrameWidth = 0;
  int videoFirstFrameHeight = 0;

  double get aspectRatio => (videoFirstFrameWidth / videoFirstFrameHeight) > 0
      ? (videoFirstFrameWidth / videoFirstFrameHeight)
      : 1.0;

  @override
  String toString() {
    return 'ZIMKitMessageVideoContent{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        'videoDuration:$videoDuration, '
        'videoFirstFrameDownloadUrl:$videoFirstFrameDownloadUrl, '
        'videoFirstFrameLocalPath:$videoFirstFrameLocalPath, '
        'videoFirstFrameWidth:$videoFirstFrameWidth, '
        'videoFirstFrameHeight:$videoFirstFrameHeight, '
        '}';
  }
}

class ZIMKitMessageAudioContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

  int audioDuration = 0;

  @override
  String toString() {
    return 'ZIMKitMessageAudioContent:{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        '}';
  }
}

class ZIMKitMessageFileContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

  @override
  String toString() {
    return 'ZIMKitMessageFileContent{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        '}';
  }
}

class ZIMKitMessageSystemContent {
  late String info;

  @override
  String toString() {
    return 'ZIMKitMessageSystemContent{info:$info}';
  }
}

class ZIMKitMessageCustomContent {
  late String message;
  late int type;
  late String searchedContent;

  @override
  String toString() {
    return 'ZIMKitMessageCustomContent{'
        'message:$message, '
        'type:$type, '
        'searchedContent:$searchedContent, '
        '}';
  }
}

class MediaTransferProgress {
  int totalSize = 0;
  int transferredSize = 0;
  double get progress => totalSize == 0 ? 0 : transferredSize / totalSize;

  @override
  String toString() {
    return 'MediaTransferProgress{'
        'totalSize:$totalSize, '
        'transferredSize:$transferredSize, '
        '}';
  }
}

class ZIMKitInvitationProtocolKey {
  static String operationType = 'operation_type';
}
