part of 'services.dart';

mixin ZIMKitMessageService {
  Future<ValueNotifier<List<ZIMKitMessage>>> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) {
    return ZIMKitCore.instance.coreData
        .getMessageListNotifier(conversationID, conversationType);
  }

  Future<int> loadMoreMessage(
      String conversationID, ZIMConversationType conversationType) async {
    return ZIMKitCore.instance.coreData
        .loadMoreMessage(conversationID, conversationType);
  }

  Future<void> sendTextMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String text, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    return ZIMKitCore.instance.coreData.sendTextMessage(
      conversationID,
      conversationType,
      text,
      preMessageSending: preMessageSending,
      onMessageSent: onMessageSent,
    );
  }

  Future<void> sendFileMessage(
    String conversationID,
    ZIMConversationType conversationType,
    PlatformFile file, {
    bool audoDetectType = true,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    if (kIsWeb) {
    } else {
      return ZIMKitCore.instance.coreData.sendMediaMessage(
        conversationID,
        conversationType,
        file.path!,
        ZIMMessageType.file,
        preMessageSending: preMessageSending,
        onMessageSent: onMessageSent,
      );
    }
  }

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    List<PlatformFile> files, {
    bool audoDetectType = true,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    if (kIsWeb) {
    } else {
      for (final file in files) {
        await ZIMKitCore.instance.coreData.sendMediaMessage(
          conversationID,
          conversationType,
          file.path!,
          audoDetectType
              ? ZIMKit().getMessageTypeByFileExtension(file)
              : ZIMMessageType.file,
          preMessageSending: preMessageSending,
          onMessageSent: onMessageSent,
        );
      }
      return;
    }
  }

  void downloadMediaFile(ZIMKitMessage message) {
    return ZIMKitCore.instance.coreData.downloadMediaFile(message);
  }
}
