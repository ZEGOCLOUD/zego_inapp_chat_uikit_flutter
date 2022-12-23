part of 'services.dart';

mixin ZIMKitConversationService {
  Future<ValueNotifier<List<ZIMKitConversation>>>
      getConversationListNotifier() {
    return ZIMKitCore.instance.coreData.getConversationListNotifier();
  }

  ZIMKitConversation getConversation(String id, ZIMConversationType type) {
    return ZIMKitCore.instance.coreData.db.conversations.get(id, type);
  }

  Future<void> deleteConversation(String id, ZIMConversationType type) async {
    await ZIMKitCore.instance.coreData.deleteConversation(id, type);
  }

  Future<void> clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) async {
    ZIMKitCore.instance.coreData
        .clearUnreadCount(conversationID, conversationType);
  }

  Future<int> loadMoreConversation() async {
    return ZIMKitCore.instance.coreData.loadMoreConversation();
  }
}
