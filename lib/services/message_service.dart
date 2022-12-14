part of 'services.dart';

mixin ZegoMessageService {
  Future<ValueNotifier<List<ZegoIMKitMessage>>> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) {
    return ZegoIMKitCore.instance.coreData.getMessageListNotifier(conversationID, conversationType);
  }

  Future<void> sendTextMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String text, {
    FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage)? preMessageSending,
    Function(ZegoIMKitMessage)? onMessageSent,
  }) async {
    return ZegoIMKitCore.instance.coreData.sendTextMessage(
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
    FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage)? preMessageSending,
    Function(ZegoIMKitMessage)? onMessageSent,
  }) async {
    if (kIsWeb) {
    } else {
      return await ZegoIMKitCore.instance.coreData.sendMediaMessage(
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
    FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage)? preMessageSending,
    Function(ZegoIMKitMessage)? onMessageSent,
  }) async {
    if (kIsWeb) {
    } else {
      for (var file in files) {
        await ZegoIMKitCore.instance.coreData.sendMediaMessage(
          conversationID,
          conversationType,
          file.path!,
          audoDetectType ? ZegoIMKit().getMessageTypeByFileExtension(file) : ZIMMessageType.file,
          preMessageSending: preMessageSending,
          onMessageSent: onMessageSent,
        );
      }
      return;
    }
  }

  void downloadMediaFile(ZegoIMKitMessage message) {
    return ZegoIMKitCore.instance.coreData.downloadMediaFile(message);
  }
}
