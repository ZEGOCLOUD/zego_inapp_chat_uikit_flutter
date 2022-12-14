part of 'services.dart';

mixin ZegoConversationService {
  Future<ValueNotifier<List<ZegoIMKitConversation>>> getConversationListNotifier() {
    return ZegoIMKitCore.instance.coreData.getConversationListNotifier();
  }

  ZegoIMKitConversation getConversation(String id, ZIMConversationType type) {
    return ZegoIMKitCore.instance.coreData.db.conversations.get(id, type);
  }

  Future<void> deleteConversation(String id, ZIMConversationType type) async {
    await ZegoIMKitCore.instance.coreData.deleteConversation(id, type);
  }

  Future<void> clearUnreadCount(String conversationID, ZIMConversationType conversationType) async {
    ZegoIMKitCore.instance.coreData.clearUnreadCount(conversationID, conversationType);
  }

  Future<int> loadMoreConversation() async {
    return await ZegoIMKitCore.instance.coreData.loadMoreConversation();
  }

  Future<int> loadMoreMessage(String conversationID, ZIMConversationType conversationType) async {
    return await ZegoIMKitCore.instance.coreData.loadMoreMessage(conversationID, conversationType);
  }

  Future<String?> createGroup(String name, List<String> inviteUserIDs) async {
    return await ZegoIMKitCore.instance.coreData.createGroup(name, inviteUserIDs);
  }

  Future<int> joinGroup(String conversationID) async {
    return await ZegoIMKitCore.instance.coreData.joinGroup(conversationID);
  }

  Future<int> inviteUsersToJoinGroup(String conversationID, List<String> inviteUserIDs) async {
    return await ZegoIMKitCore.instance.coreData.inviteUsersToJoinGroup(conversationID, inviteUserIDs);
  }

  Future<int> leaveGroup(String conversationID) async {
    return await ZegoIMKitCore.instance.coreData.leaveGroup(conversationID);
  }
}
