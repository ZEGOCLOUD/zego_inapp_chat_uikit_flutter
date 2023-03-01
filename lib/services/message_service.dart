part of 'services.dart';

mixin ZIMKitMessageService {
  Future<ZIMKitMessageListNotifier> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) {
    return ZIMKitCore.instance
        .getMessageListNotifier(conversationID, conversationType);
  }

  Future<int> loadMoreMessage(
      String conversationID, ZIMConversationType conversationType) async {
    return ZIMKitCore.instance
        .loadMoreMessage(conversationID, conversationType);
  }

  Future<void> sendTextMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String text, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    return ZIMKitCore.instance.sendTextMessage(
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
    List<PlatformFile> files, {
    bool audoDetectType = true,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    if (kIsWeb) {
    } else {
      for (final file in files) {
        ZIMKitCore.instance.sendMediaMessage(
          conversationID,
          conversationType,
          file.path!,
          ZIMMessageType.file,
          preMessageSending: preMessageSending,
          onMessageSent: onMessageSent,
        );
      }
    }
  }

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    List<PlatformFile> files, {
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    if (kIsWeb) {
    } else {
      ZIMKitLogger.info(
          'sendMediaMessage: ${DateTime.now().millisecondsSinceEpoch}');
      for (final file in files) {
        await ZIMKitCore.instance.sendMediaMessage(
          conversationID,
          conversationType,
          file.path!,
          ZIMKit().getMessageTypeByFileExtension(file),
          preMessageSending: preMessageSending,
          onMessageSent: onMessageSent,
        );
      }
      return;
    }
  }

  void downloadMediaFile(ZIMKitMessage message) {

    return ZIMKitCore.instance.downloadMediaFile(message);
  }
}
