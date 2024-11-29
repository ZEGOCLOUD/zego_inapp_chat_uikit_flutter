part of 'event.dart';

class ZIMKitEventGroupStateChanged {
  ZIMKitEventGroupStateChanged({
    required this.state,
    required this.event,
    required this.operatedInfo,
    required this.groupInfo,
  });
  final ZIMGroupState state;
  final ZIMGroupEvent event;
  final ZIMGroupOperatedInfo operatedInfo;
  final ZIMGroupFullInfo groupInfo;
}

class ZIMKitEventGroupNameUpdated {
  ZIMKitEventGroupNameUpdated({
    required this.groupName,
    required this.operatedInfo,
    required this.groupID,
  });
  final String groupName;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

class ZIMKitEventGroupAvatarUrlUpdated {
  ZIMKitEventGroupAvatarUrlUpdated({
    required this.groupAvatarUrl,
    required this.operatedInfo,
    required this.groupID,
  });
  final String groupAvatarUrl;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

class ZIMKitEventGroupNoticeUpdated {
  ZIMKitEventGroupNoticeUpdated({
    required this.groupNotice,
    required this.operatedInfo,
    required this.groupID,
  });
  final String groupNotice;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

class ZIMKitEventGroupAttributesUpdated {
  ZIMKitEventGroupAttributesUpdated({
    required this.updateInfo,
    required this.operatedInfo,
    required this.groupID,
  });
  final List<ZIMGroupAttributesUpdateInfo> updateInfo;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

class ZIMKitEventGroupMemberStateChanged {
  ZIMKitEventGroupMemberStateChanged({
    required this.state,
    required this.event,
    required this.userList,
    required this.operatedInfo,
    required this.groupID,
  });
  final ZIMGroupMemberState state;
  final ZIMGroupMemberEvent event;
  final List<ZIMGroupMemberInfo> userList;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

class ZIMKitEventGroupMemberInfoUpdated {
  ZIMKitEventGroupMemberInfoUpdated({
    required this.userInfo,
    required this.operatedInfo,
    required this.groupID,
  });
  final List<ZIMGroupMemberInfo> userInfo;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}
