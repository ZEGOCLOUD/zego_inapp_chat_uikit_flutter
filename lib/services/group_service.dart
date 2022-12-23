part of 'services.dart';

mixin ZIMKitGroupService {
  Future<String?> createGroup(String name, List<String> inviteUserIDs,
      {String id = ''}) async {
    return ZIMKitCore.instance.coreData
        .createGroup(name, inviteUserIDs, id: id);
  }

  Future<int> joinGroup(String conversationID) async {
    return ZIMKitCore.instance.coreData.joinGroup(conversationID);
  }

  Future<int> inviteUsersToJoinGroup(
      String conversationID, List<String> inviteUserIDs) async {
    return ZIMKitCore.instance.coreData
        .inviteUsersToJoinGroup(conversationID, inviteUserIDs);
  }

  Future<int> leaveGroup(String conversationID) async {
    return ZIMKitCore.instance.coreData.leaveGroup(conversationID);
  }
}
