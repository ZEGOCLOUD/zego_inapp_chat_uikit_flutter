part of 'core.dart';

extension ZIMKitCoreMessageReaction on ZIMKitCore {
  Future<void> addMessageReaction(
      ZIMKitMessage message, String reactionType) async {
    if (reactionType.isEmpty) {
      ZIMKitLogger.warning("addMessageReaction: reactionType is empty");
      return Future.error(
          PlatformException(code: '-1', message: 'reactionType is empty'));
    }
    ZIMKitLogger.info(
        'addMessageReaction: $reactionType, messageID:${message.info.messageID}');

    await ZIM
        .getInstance()!
        .addMessageReaction(reactionType, message.zim)
        .then((result) {
      ZIMKitLogger.info(
          'addMessageReaction: success, $reactionType, messageID:${message.info.messageID}');
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry addMessageReaction');
        } else {
          ZIMKitLogger.severe(
              'addMessageReaction: failed, error:$error, $reactionType, messageID:${message.info.messageID}');
          throw error;
        }
      });
    });
  }

  Future<void> deleteMessageReaction(
      ZIMKitMessage message, String reactionType) async {
    if (reactionType.isEmpty) {
      ZIMKitLogger.warning("deleteMessageReaction: reactionType is empty");
      return Future.error(
          PlatformException(code: '-1', message: 'reactionType is empty'));
    }
    ZIMKitLogger.info(
        'deleteMessageReaction: $reactionType, messageID:${message.info.messageID}');

    await ZIM
        .getInstance()!
        .deleteMessageReaction(reactionType, message.zim)
        .then((result) {
      ZIMKitLogger.info(
          'deleteMessageReaction: success, $reactionType, messageID:${message.info.messageID}');
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry deleteMessageReaction');
        } else {
          ZIMKitLogger.severe(
              'deleteMessageReaction: failed, error:$error, $reactionType, messageID:${message.info.messageID}');
          throw error;
        }
      });
    });
  }

  void onMessageReactionsChanged(
      ZIM zim, List<ZIMMessageReaction> reactions) async {
    ZIMKitLogger.info('onMessageReactionsChanged: ${reactions.length}');
    if (reactions.isEmpty) return;

    for (final reaction in reactions) {
      final conversationID = reaction.conversationID;
      final conversationType = reaction.conversationType;

      final messageList = db.messages(conversationID, conversationType);

      if (messageList.notInited) {
        ZIMKitLogger.info(
            'onMessageReactionsChanged: notInited, loadMessageList first');
        await getMessageListNotifier(conversationID, conversationType);
      }

      messageList.onMessageReactionsChanged(reaction);
    }
  }
}
