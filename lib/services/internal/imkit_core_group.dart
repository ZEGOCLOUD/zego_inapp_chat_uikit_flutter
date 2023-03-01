part of 'imkit_core.dart';

extension ZIMKitCoreGroup on ZIMKitCore {
  // TODO return ZIMGroupCreatedResult
  Future<String?> createGroup(String name, List<String> inviteUserIDs,
      {String id = ''}) async {
    if (currentUser == null) return null;
    String? ret;
    final groupInfo = ZIMGroupInfo()
      ..groupName = name
      ..groupID = id;
    await ZIM
        .getInstance()!
        .createGroup(groupInfo, inviteUserIDs)
        .then((ZIMGroupCreatedResult zimResult) {
      ZIMKitLogger.info('createGroup: success, groupID: $id');
      db.conversations.insert(zimResult.groupInfo.toConversation());
      ret = zimResult.groupInfo.baseInfo.groupID;
    }).catchError((error) {
      ZIMKitLogger.severe('createGroup: faild, name: $name, error: $error');
    });
    return ret;
  }

  // TODO return ZIMGroupJoinedResult
  Future<int> joinGroup(String id) async {
    if (currentUser == null) return -1;
    late int errorCode;
    await ZIM
        .getInstance()!
        .joinGroup(id)
        .then((ZIMGroupJoinedResult zimResult) {
      ZIMKitLogger.info('joinGroup: success, groupID: $id');
      db.conversations.insert(zimResult.groupInfo.toConversation());
      errorCode = 0;
    }).catchError((error) {
      errorCode = int.tryParse(error.code) ?? -1;
      if (errorCode == ZIMErrorCode.groupModuleMemberIsAlreadyInTheGroup) {
        ZIM
            .getInstance()!
            .queryGroupList()
            .then((ZIMGroupListQueriedResult zimResult) {
          var gotIt = false;
          for (final group in zimResult.groupList) {
            if (group.baseInfo!.id == id) {
              final kitConversation =
                  db.conversations.get(id, ZIMConversationType.group);
              kitConversation.value = kitConversation.value.clone()
                ..name = group.baseInfo!.name
                ..avatarUrl = group.baseInfo!.url;
              gotIt = true;
              break;
            }
          }
          if (!gotIt) {
            ZIMKitLogger.info(
                'joinGroup: warning, already in, but query faild: $id, '
                'insert a dummy conversation');
            db.conversations.insert(
              (ZIMConversation()
                    ..id = id
                    ..type = ZIMConversationType.group)
                  .tokit(),
            );
          }
        }).catchError((error) {
          ZIMKitLogger.severe('joinGroup: faild, already in, but query '
              'faild: $id, error: $error');
        });
      } else {
        ZIMKitLogger.severe('joinGroup: faild, groupID: $id, error: $error');
      }
    });
    return errorCode;
  }

// TODO return ZIMGroupUsersInvitedResult
  Future<int> inviteUsersToJoinGroup(
      String id, List<String> inviteUserIDs) async {
    if (currentUser == null) return -1;
    late int errorCode;
    await ZIM
        .getInstance()!
        .inviteUsersIntoGroup(inviteUserIDs, id)
        .then((ZIMGroupUsersInvitedResult zimResult) {
      ZIMKitLogger.info('inviteUsersToJoinGroup: success, groupID: $id');
      errorCode = 0;
    }).catchError((error) {
      errorCode = int.parse(error.code);
      ZIMKitLogger.severe(
          'inviteUsersToJoinGroup: faild, groupID: $id, error: $error');
    });
    return errorCode;
  }

// TODO return ZIMGroupLeftResult
  Future<int> leaveGroup(String id) async {
    if (currentUser == null) return -1;
    late int errorCode;
    await ZIM
        .getInstance()!
        .leaveGroup(id)
        .then((ZIMGroupLeftResult zimResult) {
      ZIMKitLogger.info('leaveGroup: success, groupID: $id');
      db.conversations.remove(id, ZIMConversationType.group);
      errorCode = 0;
    }).catchError((error) {
      errorCode = int.parse(error.code);
      if (errorCode == ZIMErrorCode.groupModuleUserIsNotInTheGroup) {
        db.conversations.remove(id, ZIMConversationType.group);
      }
      ZIMKitLogger.severe('leaveGroup: faild, groupID: $id, error: $error');
    });
    return errorCode;
  }

  Future<ZIMGroupFullInfo?> queryGroup(String id) async {
    final queryHash = id;
    if (_queryGroupCache[queryHash] == null) {
      _queryGroupCache[queryHash] = AsyncCache(const Duration(minutes: 5));
    }
    if (currentUser == null) {
      _queryGroupCache.clear();
      return null;
    }

    return _queryGroupCache[queryHash]!.fetch(() async {
      ZIMKitLogger.info('queryGroup, id:$id');
      return ZIM
          .getInstance()!
          .queryGroupInfo(id)
          .then<ZIMGroupFullInfo?>((ZIMGroupInfoQueriedResult result) {
        return Future.value(result.groupInfo);
      });
    }).catchError((error) {
      if (error is PlatformException && int.parse(error.code) == 6000012) {
        ZIMKitLogger.info('queryGroup faild, retry later');

        return Future.delayed(
          Duration(milliseconds: Random().nextInt(5000)),
          () => queryGroup(id),
        );
      }

      return ZIMKitCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry queryUser');
          return queryGroup(id);
        } else {
          Timer.run(() => _queryGroupCache[queryHash]?.invalidate());
          ZIMKitLogger.severe('queryGroup faild', error);
          throw error;
        }
      });
    });
  }
}

extension ZIMKitCoreGroupEvent on ZIMKitCore {
  void onGroupStateChanged(ZIM zim, ZIMGroupState state, ZIMGroupEvent event,
      ZIMGroupOperatedInfo operatedInfo, ZIMGroupFullInfo groupInfo) {
    ZIMKitLogger.info('onGroupStateChanged');
  }

  void onGroupNameUpdated(ZIM zim, String groupName,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupNameUpdated');
  }

  void onGroupAvatarUrlUpdated(ZIM zim, String groupAvatarUrl,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupAvatarUrlUpdated');
  }

  void onGroupNoticeUpdated(ZIM zim, String groupNotice,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupNoticeUpdated');
  }

  void onGroupAttributesUpdated(
      ZIM zim,
      List<ZIMGroupAttributesUpdateInfo> updateInfo,
      ZIMGroupOperatedInfo operatedInfo,
      String groupID) {
    ZIMKitLogger.info('onGroupAttributesUpdated');
  }

  void onGroupMemberStateChanged(
      ZIM zim,
      ZIMGroupMemberState state,
      ZIMGroupMemberEvent event,
      List<ZIMGroupMemberInfo> userList,
      ZIMGroupOperatedInfo operatedInfo,
      String groupID) {
    ZIMKitLogger.info('onGroupMemberStateChanged');
  }

  void onGroupMemberInfoUpdated(ZIM zim, List<ZIMGroupMemberInfo> userInfo,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupMemberInfoUpdated');
  }
}
