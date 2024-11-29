part of 'zimkit_services.dart';

mixin ZIMKitConversationService {
  Future<ZIMKitConversationListNotifier> getConversationListNotifier() {
    return ZIMKitCore.instance.getConversationListNotifier();
  }

  ValueNotifier<ZIMKitConversation> getConversation(
    String id,
    ZIMConversationType type,
  ) {
    return ZIMKitCore.instance.db.conversations.get(id, type);
  }

  ValueNotifier<int> getTotalUnreadMessageCount() {
    return ZIMKitCore().totalUnreadMessageCountNotifier;
  }

  Future<void> deleteConversation(
    String id,
    ZIMConversationType type, {
    bool isAlsoDeleteMessages = false,
    bool isAlsoDeleteFromServer = true,
  }) async {
    await ZIMKitCore.instance.deleteConversation(
      id,
      type,
      isAlsoDeleteMessages: isAlsoDeleteMessages,
      isAlsoDeleteFromServer: isAlsoDeleteFromServer,
    );
  }

  Future<void> deleteAllConversation({
    bool isAlsoDeleteFromServer = true,
    bool isAlsoDeleteMessages = false,
  }) async {
    await ZIMKitCore.instance.deleteAllConversation(
        isAlsoDeleteFromServer: isAlsoDeleteFromServer,
        isAlsoDeleteMessages: isAlsoDeleteMessages);
  }

  Future<void> clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) async {
    ZIMKitCore.instance.clearUnreadCount(conversationID, conversationType);
  }

  Future<int> loadMoreConversation() async {
    return ZIMKitCore.instance.loadMoreConversation();
  }
}
