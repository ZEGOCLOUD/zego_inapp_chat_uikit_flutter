part of 'services.dart';

mixin ZIMKitConversationService {
  Future<ZIMKitConversationListNotifier> getConversationListNotifier() {
    return ZIMKitCore.instance.getConversationListNotifier();
  }

  ValueNotifier<ZIMKitConversation> getConversation(
      String id, ZIMConversationType type) {
    return ZIMKitCore.instance.db.conversations.get(id, type);
  }

  Future<void> deleteConversation(String id, ZIMConversationType type) async {
    await ZIMKitCore.instance.deleteConversation(id, type);
  }

  Future<void> clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) async {
    ZIMKitCore.instance.clearUnreadCount(conversationID, conversationType);
  }

  Future<int> loadMoreConversation() async {
    return ZIMKitCore.instance.loadMoreConversation();
  }
}
