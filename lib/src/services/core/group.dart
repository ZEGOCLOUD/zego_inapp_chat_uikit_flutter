part of 'core.dart';

extension ZIMKitCoreGroup on ZIMKitCore {
  Future<String?> createGroup(String name, List<String> inviteUserIDs,
      {String id = ''}) async {
    if (currentUser == null) return null;
    final groupInfo = ZIMGroupInfo()
      ..groupName = name
      ..groupID = id;
    return ZIM
        .getInstance()!
        .createGroup(groupInfo, inviteUserIDs)
        .then((ZIMGroupCreatedResult zimResult) {
      ZIMKitLogger.info('createGroup: success, groupID: $id');
      db.groupInfo(id).update(zimResult.groupInfo);
      db.conversations.insertOrUpdate(zimResult.groupInfo.toConversation());
      return Future<String?>.value(zimResult.groupInfo.baseInfo.groupID);
    }).catchError((error) {
      ZIMKitLogger.severe('createGroup: failed, name: $name, error: $error');
      return Future<String?>.error(error);
    });
  }

  Future<int> joinGroup(String id) async {
    if (currentUser == null) return -1;

    return ZIM
        .getInstance()!
        .joinGroup(id)
        .then((ZIMGroupJoinedResult zimResult) {
      ZIMKitLogger.info('joinGroup: success, groupID: $id');
      db.groupInfo(id).update(zimResult.groupInfo);
      db.conversations.insertOrUpdate(zimResult.groupInfo.toConversation());
      return 0;
    }).catchError((error) {
      final errorCode = int.tryParse(error.code) ?? -2;
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
                'joinGroup: warning, already in, but query failed: $id, '
                'insert a dummy conversation');
            db.conversations.insertOrUpdate(
              (ZIMConversation()
                    ..id = id
                    ..type = ZIMConversationType.group)
                  .toKIT(),
            );
          }
        }).catchError((error) {
          ZIMKitLogger.severe('joinGroup: failed, already in, but query '
              'failed: $id, error: $error');
        });
      } else {
        ZIMKitLogger.severe('joinGroup: failed, groupID: $id, error: $error');
      }
      return errorCode;
    });
  }

// TODO return ZIMGroupUsersInvitedResult
  Future<int> addUsersToGroup(String id, List<String> userIDs) async {
    if (currentUser == null) return -1;
    return ZIM
        .getInstance()!
        .inviteUsersIntoGroup(userIDs, id)
        .then((ZIMGroupUsersInvitedResult zimResult) {
      ZIMKitLogger.info('addUsersToGroup: success, groupID: $id');
      return 0;
    }).catchError((error) {
      ZIMKitLogger.severe(
          'addUsersToGroup: failed, groupID: $id, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> leaveGroup(String groupID) async {
    if (currentUser == null) return -1;

    return ZIM
        .getInstance()!
        .leaveGroup(groupID)
        .then((ZIMGroupLeftResult zimResult) {
      ZIMKitLogger.info('leaveGroup: success, groupID: $groupID');
      db.conversations.remove(groupID, ZIMConversationType.group);
      return 0;
    }).catchError((error) {
      final errorCode = int.tryParse(error.code) ?? -2;
      if (errorCode == ZIMErrorCode.groupModuleUserIsNotInTheGroup) {
        db.conversations.remove(groupID, ZIMConversationType.group);
        return 0;
      }
      ZIMKitLogger.severe(
          'leaveGroup: failed, groupID: $groupID, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> removeUsersFromGroup(String groupID, List<String> userIDs) async {
    if (currentUser == null) return -1;
    return ZIM
        .getInstance()!
        .kickGroupMembers(userIDs, groupID)
        .then((ZIMGroupMemberKickedResult zimResult) {
      ZIMKitLogger.info('removeUsersFromGroup: success');
      return 0;
    }).catchError((error) {
      ZIMKitLogger.severe('removeUsersFromGroup: failed, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> disbandGroup(String groupID) async {
    if (currentUser == null) return -1;

    return ZIM
        .getInstance()!
        .dismissGroup(groupID)
        .then((ZIMGroupDismissedResult zimResult) {
      ZIMKitLogger.info('disbandGroup: success');
      return 0;
    }).catchError((error) {
      ZIMKitLogger.severe('disbandGroup: failed, error: $error');
      return int.tryParse(error.code) ?? -2;
    });
  }

  Future<int> transferGroupOwner(String groupID, String toUserID) async {
    if (currentUser == null) return -1;
    return ZIM
        .getInstance()!
        .transferGroupOwner(toUserID, groupID)
        .then((ZIMGroupOwnerTransferredResult zimResult) {
      ZIMKitLogger.info('transferGroupOwner: success');
      return 0;
    }).catchError((error) {
      return ZIMKitCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('re-login success, retry transferGroupOwner');
          return transferGroupOwner(groupID, toUserID);
        } else {
          ZIMKitLogger.severe('transferGroupOwner failed', error);
          return Future.value(int.tryParse(error.code) ?? -2);
        }
      });
    });
  }

  Future<ZIMGroupMemberInfo?> queryGroupMemberInfo(
      String groupID, String userID) async {
    final queryHash = '$groupID,$userID';
    _queryGroupMemberInfoCache[queryHash] ??=
        AsyncCache(const Duration(minutes: 1));
    if (currentUser == null) {
      _queryGroupMemberInfoCache.clear();
      return null;
    }

    return _queryGroupMemberInfoCache[queryHash]!.fetch(() async {
      return ZIM
          .getInstance()!
          .queryGroupMemberInfo(userID, groupID)
          .then((ZIMGroupMemberInfoQueriedResult zimResult) {
        ZIMKitLogger.info('queryGroupMemberInfo: success');
        return Future<ZIMGroupMemberInfo?>.value(zimResult.userInfo);
      }).catchError((error) async {
        final errorCode = int.tryParse(error.code) ?? -2;
        if (ZIMErrorCodeExtension.isFreqLimit(errorCode)) {
          ZIMKitLogger.info('queryGroupMemberInfo failed, retry later');

          return Future.delayed(
            Duration(milliseconds: Random().nextInt(5000)),
            () => queryGroupMemberInfo(groupID, userID),
          );
        }

        return ZIMKitCore.instance
            .checkNeedReloginOrNot(error)
            .then((retryCode) async {
          if (retryCode == 0) {
            ZIMKitLogger.info('re-login success, retry queryUser');
            return queryGroupMemberInfo(groupID, userID);
          } else {
            ZIMKitLogger.severe('queryGroupMemberInfo failed', error);
            return Future<ZIMGroupMemberInfo?>.value(null);
          }
        });
      });
    });
  }

  ValueNotifier<ZIMGroupMemberInfo?> queryGroupOwner(String groupID) {
    queryGroupMemberList(groupID);
    return db.groupMemberList(groupID).owner;
  }

  ListNotifier<ZIMGroupMemberInfo> queryGroupMemberList(String groupID,
      {int nextFlag = 0}) {
    if (currentUser == null) return ListNotifier([]);

    if (!db.groupMemberList(groupID).fetched || nextFlag != 0) {
      db.groupMemberList(groupID).fetched = true;
      ZIM
          .getInstance()!
          .queryGroupMemberList(
            groupID,
            ZIMGroupMemberQueryConfig()
              ..count = 100
              ..nextFlag = nextFlag,
          )
          .then((ZIMGroupMemberListQueriedResult zimResult) {
        final list = db.groupMemberList(groupID)..addAll(zimResult.userList);
        ZIMKitLogger.info(
            'queryGroupMemberList succeess, member count:${list.notifier.length},nextFlag:$nextFlag, newNextFlag:${zimResult.nextFlag}');
        if ((zimResult.nextFlag != 0) && (zimResult.nextFlag != nextFlag)) {
          ZIMKitLogger.info(
              'queryGroupMemberList next, nextFlag:$nextFlag, newNextFlag:${zimResult.nextFlag}');
          queryGroupMemberList(groupID, nextFlag: zimResult.nextFlag);
        }
      }).catchError((error) {
        final errorCode = int.tryParse(error.code) ?? -2;
        if (ZIMErrorCodeExtension.isFreqLimit(errorCode)) {
          ZIMKitLogger.info('queryGroupInfo failed, retry later');

          Future.delayed(
            Duration(milliseconds: Random().nextInt(5000)),
            () => queryGroupMemberList(groupID, nextFlag: nextFlag),
          );
        }

        ZIMKitCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZIMKitLogger.info('re-login success, retry queryUser');
            queryGroupMemberList(groupID, nextFlag: nextFlag);
          } else {
            db.groupMemberList(groupID).fetched = false;
            ZIMKitLogger.severe('queryGroupMemberList: failed, error: $error');
            throw error;
          }
        });
      });
    }
    return db.groupMemberList(groupID).notifier;
  }

  ValueNotifier<ZIMKitGroupInfo> queryGroupInfo(String groupID) {
    if (currentUser == null) {
      return ValueNotifier<ZIMKitGroupInfo>(ZIMKitGroupInfo());
    }

    ZIMKitLogger.info('queryGroupInfo groupID:$groupID');
    ZIM
        .getInstance()!
        .queryGroupInfo(groupID)
        .then((ZIMGroupInfoQueriedResult result) {
      db.groupInfo(groupID).update(result.groupInfo);
    }).catchError((error) {
      final errorCode = int.tryParse(error.code) ?? -2;
      if (ZIMErrorCodeExtension.isFreqLimit(errorCode)) {
        ZIMKitLogger.info('queryGroupInfo failed, retry later');

        Future.delayed(
          Duration(milliseconds: Random().nextInt(5000)),
          () => queryGroupInfo(groupID),
        );
      }
      if (errorCode == ZIMErrorCode.groupModuleGroupDoseNotExist) {
        return; // group not exist
      }

      ZIMKitCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('re-login success, retry queryUser');
          queryGroupInfo(groupID);
        } else {
          ZIMKitLogger.severe('queryGroupInfo failed', error);
        }
      });
    });
    return db.groupInfo(groupID).notifier;
  }

  ValueNotifier<int> queryGroupMemberCount(String groupID) {
    if (currentUser == null) return ValueNotifier(0);

    if (db.groupMemberList(groupID).count.value != -1) {
      return db.groupMemberList(groupID).count;
    } else {
      ZIM
          .getInstance()!
          .queryGroupMemberCount(groupID)
          .then((ZIMGroupMemberCountQueriedResult zimResult) {
        ZIMKitLogger.info('queryGroupMemberCount: success');
        db.groupMemberList(groupID).count.value = zimResult.count;
      }).catchError((error) {
        ZIMKitCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZIMKitLogger.info('re-login success, retry queryGroupMemberCount');
            queryGroupMemberCount(groupID);
          } else {
            ZIMKitLogger.severe('queryGroupMemberCount failed', error);
            Future<int?>.value(0);
          }
        });
      });
    }
    return db.groupMemberList(groupID).count;
  }

  Future<int> setGroupMemberRole(
      String conversationID, String userID, int role) async {
    if (currentUser == null) return -1;
    return ZIM
        .getInstance()!
        .setGroupMemberRole(role, userID, conversationID)
        .then((_) {
      ZIMKitLogger.info('setGroupMemberRole: success');
      return 0;
    }).catchError((error) {
      return ZIMKitCore.instance.checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('re-login success, retry setGroupMemberRole');
          return setGroupMemberRole(conversationID, userID, role);
        } else {
          ZIMKitLogger.severe('setGroupMemberRole failed', error);
          return Future.value(int.tryParse(error.code) ?? -2);
        }
      });
    });
  }
}

// event
extension ZIMKitCoreGroupEvent on ZIMKitCore {
  void onGroupStateChanged(ZIM zim, ZIMGroupState state, ZIMGroupEvent event,
      ZIMGroupOperatedInfo operatedInfo, ZIMGroupFullInfo groupInfo) {
    db.groupInfo(groupInfo.id).onGroupStateChanged(state, event, groupInfo);
    if (state == ZIMGroupState.enter) {
      db.conversations.insertOrUpdate(groupInfo.toConversation());
    }

    ZIMKitLogger.info('onGroupStateChanged, state: $state, event: $event');
    onGroupStateChangedEventController.add(ZIMKitEventGroupStateChanged(
      groupInfo: groupInfo,
      state: state,
      operatedInfo: operatedInfo,
      event: event,
    ));
  }

  void onGroupNameUpdated(ZIM zim, String groupName,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupNameUpdated, groupName: $groupName');
    final notifier =
        ZIMKitCore().db.conversations.get(groupID, ZIMConversationType.group);
    notifier.value = notifier.value.clone()..name = groupName;

    onGroupNameUpdatedEventController.add(ZIMKitEventGroupNameUpdated(
      groupName: groupName,
      operatedInfo: operatedInfo,
      groupID: groupID,
    ));
  }

  void onGroupAvatarUrlUpdated(ZIM zim, String groupAvatarUrl,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupAvatarUrlUpdated');
    final notifier =
        ZIMKitCore().db.conversations.get(groupID, ZIMConversationType.group);
    notifier.value = notifier.value.clone()..avatarUrl = groupAvatarUrl;

    onGroupAvatarUrlUpdatedEventController.add(ZIMKitEventGroupAvatarUrlUpdated(
      groupAvatarUrl: groupAvatarUrl,
      operatedInfo: operatedInfo,
      groupID: groupID,
    ));
  }

  void onGroupNoticeUpdated(ZIM zim, String groupNotice,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZIMKitLogger.info('onGroupNoticeUpdated');
    db.groupInfo(groupID).onGroupNoticeUpdated(groupNotice);
    onGroupNoticeUpdatedEventController.add(ZIMKitEventGroupNoticeUpdated(
      groupNotice: groupNotice,
      operatedInfo: operatedInfo,
      groupID: groupID,
    ));
  }

  void onGroupAttributesUpdated(
      ZIM zim,
      List<ZIMGroupAttributesUpdateInfo> updateInfo,
      ZIMGroupOperatedInfo operatedInfo,
      String groupID) {
    db.groupInfo(groupID).onGroupAttributesUpdated(updateInfo);
    onGroupAttributesUpdatedEventController
        .add(ZIMKitEventGroupAttributesUpdated(
      updateInfo: updateInfo,
      operatedInfo: operatedInfo,
      groupID: groupID,
    ));
  }

  void onGroupMemberStateChanged(
      ZIM zim,
      ZIMGroupMemberState state,
      ZIMGroupMemberEvent event,
      List<ZIMGroupMemberInfo> userList,
      ZIMGroupOperatedInfo operatedInfo,
      String groupID) {
    ZIMKitLogger.info('onGroupMemberStateChanged');
    if (state == ZIMGroupMemberState.enter) {
      db.groupMemberList(groupID).addAll(userList);
    } else {
      db.groupMemberList(groupID).removeAll(userList);
    }
    onGroupMemberStateChangedEventController
        .add(ZIMKitEventGroupMemberStateChanged(
      state: state,
      event: event,
      userList: userList,
      operatedInfo: operatedInfo,
      groupID: groupID,
    ));
  }

  void onGroupMemberInfoUpdated(ZIM zim, List<ZIMGroupMemberInfo> userInfo,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    queryGroupMemberList(groupID);
    db.groupMemberList(groupID).addAll(userInfo);
    ZIMKitLogger.info('onGroupMemberInfoUpdated');
    onGroupMemberInfoUpdatedEventController
        .add(ZIMKitEventGroupMemberInfoUpdated(
      userInfo: userInfo,
      operatedInfo: operatedInfo,
      groupID: groupID,
    ));
  }
}
