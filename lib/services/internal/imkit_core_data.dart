import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zego_imkit/zego_imkit.dart';
import 'package:async/async.dart';
import 'imkit_core_defines.dart';

const int kdefaultLoadCount = 30; // default is 30
const bool kEnableAutoDownload = false; // default is 30

class ZegoIMKitCoreData {
  int appID = 0;
  String appSign = '';
  String appSecret = '';
  bool useToken = false;

  bool isInited = false;
  ZIMUserFullInfo? loginUser;

  Completer? connectionStateWaiter;
  var connectionState = ZIMConnectionState.disconnected;
  var connectionStateCtrl = StreamController<Map>.broadcast();

  ZegoIMKitDB db = ZegoIMKitDB();

  Future<String> getVersion() async {
    var zimVersion = await ZIM.getVersion();
    return 'imkit:0.1.1;zim:$zimVersion';
  }

  void clear() {
    connectionState = ZIMConnectionState.disconnected;
    db.clear();
    loginUser = null;
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    bool useToken = false,
  }) async {
    this.appID = appID;
    this.appSign = appSign;
    this.appSecret = appSecret;
    this.useToken = useToken;

    if (isInited) {
      ZegoIMKitLogger.info("has inited.");
      return;
    }

    ZegoIMKitLogger.info('init, appID:$appID');
    isInited = true;

    var appConfig = ZIMAppConfig();
    appConfig.appID = appID;
    appConfig.appSign = appSign;
    ZIM.create(appConfig);

    getVersion().then((value) {
      ZegoIMKitLogger.info("Zego IM SDK version: $value");
    });
  }

  Future<void> uninit() async {
    if (!isInited) {
      ZegoIMKitLogger.info("is not inited.");
      return;
    }
    ZegoIMKitLogger.info("destroy.");
    isInited = false;
    await logout();
    ZIM.getInstance()?.destroy();
  }

  Future<int> tryReloginOrNot(error) async {
    if (error is PlatformException &&
        error.code == ZIMErrorCode.networkModuleUserIsNotLogged.toString() &&
        loginUser != null) {
      ZegoIMKitLogger.info("try auto relogin.");
      return await login(
          id: loginUser!.baseInfo.userID, name: loginUser!.baseInfo.userName);
    } else {
      return -1;
    }
  }

  Future<int> login({required String id, String name = ''}) async {
    if (!isInited) {
      ZegoIMKitLogger.info("is not inited.");
      throw Exception("ZegoIMKit is not inited.");
    }
    if (loginUser != null) {
      ZegoIMKitLogger.info("has login, auto logout");
      await logout();
    }

    ZegoIMKitLogger.info("login request, user id:$id, user name:$name");
    loginUser = ZIMUserFullInfo();
    loginUser!.baseInfo.userID = id;
    loginUser!.baseInfo.userName = name.isNotEmpty ? name : id;

    ZegoIMKitLogger.info("ready to login..");
    String? token = (useToken || kIsWeb)
        ? await ZegoTokenUtils.generateZegoToken(appID, appSecret, id)
        : null;
    return ZIM.getInstance()!.login(loginUser!.baseInfo, token).then((value) {
      ZegoIMKitLogger.info('login success');

      // query loginUser's full info
      queryUser(loginUser!.baseInfo.userID).then((ZIMUserFullInfo value) {
        loginUser = value;
      });

      return 0;
    }).catchError((error, stackTrace) {
      ZegoIMKitLogger.info('login error, $error');
      return int.parse((error as PlatformException).code);
    });
  }

  Future<void> logout() async {
    ZegoIMKitLogger.info("logout.");
    clear();
    ZIM.getInstance()!.logout();

    // waitForDisconnect
    if (connectionState != ZIMConnectionState.disconnected) {
      var completer = Completer();
      var timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (connectionState == ZIMConnectionState.disconnected) {
          if (timer.isActive) timer.cancel();
          if (!completer.isCompleted) completer.complete();
          ZegoIMKitLogger.info('waitForDisconnect success');
        }
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (timer.isActive) timer.cancel();
        if (!completer.isCompleted) completer.complete();
        ZegoIMKitLogger.info('waitForDisconnect timeout');
      });
      await completer.future;
    }
  }

  final Map<String, AsyncCache<ZIMUserFullInfo>> _queryUserCache = {};
  Future<ZIMUserFullInfo> queryUser(String id) async {
    if (_queryUserCache[id] == null) {
      _queryUserCache[id] = AsyncCache(const Duration(minutes: 5));
    }
    return await _queryUserCache[id]!.fetch(() async {
      ZIMUserInfoQueryConfig config = ZIMUserInfoQueryConfig();
      config.isQueryFromServer = true;

      return ZIM.getInstance()!.queryUsersInfo([id], config).then(
          (ZIMUsersInfoQueriedResult result) {
        return result.userList.first;
      }).catchError((error) {
        _queryUserCache[id]!.invalidate();
        return tryReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZegoIMKitLogger.info('relogin success, retry queryUser');
            return queryUser(id);
          } else {
            ZegoIMKitLogger.severe('queryUser faild', error);
            // throw error;
            return Future.value(ZIMUserFullInfo());
          }
        });
      });
    });
  }

  Future<ListNotifier<ZegoIMKitConversation>>
      getConversationListNotifier() async {
    if (db.conversations.inited) return db.conversations.data;

    db.conversations.loading = true;
    var config = ZIMConversationQueryConfig();
    config.count = kdefaultLoadCount;
    return await ZIM
        .getInstance()!
        .queryConversationList(config)
        .then((zimResult) {
      ZegoIMKitLogger.info(
          'queryHistoryMessage: ${zimResult.conversationList.length}');
      db.conversations.init(zimResult.conversationList);
      if (zimResult.conversationList.isEmpty ||
          zimResult.conversationList.length < config.count) {
        db.conversations.noMore = true;
      }
      db.conversations.loading = false;
      return db.conversations.data;
    }).catchError((error) {
      return tryReloginOrNot(error).then((retryCode) {
        db.conversations.loading = false;
        if (retryCode == 0) {
          ZegoIMKitLogger.info('relogin success, retry loadConversationList');
          return getConversationListNotifier();
        } else {
          ZegoIMKitLogger.severe('loadConversationList faild', error);
          throw error;
        }
      });
    });
  }

  Future<int> loadMoreConversation() async {
    if (db.conversations.noMore || db.conversations.loading) return 0;
    if (db.conversations.notInited) await getConversationListNotifier();
    if (db.conversations.isEmpty) return 0;
    ZegoIMKitLogger.info('loadMoreConversation start');

    db.conversations.loading = true;
    // start loading
    var config = ZIMConversationQueryConfig();
    config.count = kdefaultLoadCount;
    config.nextConversation = db.conversations.data.value.last.zim;
    return await ZIM
        .getInstance()!
        .queryConversationList(config)
        .then((zimResult) {
      db.conversations.addAll(zimResult.conversationList);
      db.conversations.loading = false;
      if (zimResult.conversationList.isEmpty ||
          zimResult.conversationList.length < config.count) {
        db.conversations.noMore = true;
      }
      db.conversations.loading = false;
      return zimResult.conversationList.length;
    }).catchError((error) {
      return tryReloginOrNot(error).then((retryCode) {
        db.conversations.loading = false;
        if (retryCode == 0) {
          ZegoIMKitLogger.info('relogin success, retry loadConversationList');
          return loadMoreConversation();
        } else {
          ZegoIMKitLogger.severe('loadConversationList faild', error);
          throw error;
        }
      });
    });
  }

  Future<void> deleteConversation(String id, ZIMConversationType type,
      {bool isAlsoDeleteServerConversation = true}) async {
    db.conversations.delete(id, type);

    ZIMConversationDeleteConfig deleteConfig = ZIMConversationDeleteConfig();
    deleteConfig.isAlsoDeleteServerConversation =
        isAlsoDeleteServerConversation;
    await ZIM.getInstance()!.deleteConversation(id, type, deleteConfig);
  }

  void onConversationChanged(
      ZIM zim, List<ZIMConversationChangeInfo> conversationChangeInfoList) {
    for (ZIMConversationChangeInfo changeInfo in conversationChangeInfoList) {
      switch (changeInfo.event) {
        case ZIMConversationEvent.added:
          db.conversations.insert(changeInfo.conversation!);
          break;
        case ZIMConversationEvent.updated:
          db.conversations.update(changeInfo.conversation!);
          break;
        case ZIMConversationEvent.disabled:
          db.conversations.disable(changeInfo.conversation!);
          break;
      }
    }
  }

  Future<ListNotifier<ZegoIMKitMessage>> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) async {
    var dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.inited) return dbMessages.data;

    // start load
    dbMessages.loading = true;
    var config = ZIMMessageQueryConfig();
    config.reverse = true;
    config.count = kdefaultLoadCount;
    return await ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZegoIMKitLogger.info(
          'queryHistoryMessage: ${zimResult.messageList.length}');
      dbMessages.init(zimResult.messageList);
      // auto download media message
      for (var kitMessage in dbMessages.data.value) {
        if (kitMessage.zim is ZIMMediaMessage) downloadMediaFile(kitMessage);
      }
      if (zimResult.messageList.isEmpty ||
          zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;
      return dbMessages.data;
    }).catchError((error) {
      return tryReloginOrNot(error).then((retryCode) {
        dbMessages.loading = false;
        if (retryCode == 0) {
          ZegoIMKitLogger.info('relogin success, retry loadMessageList');
          return getMessageListNotifier(conversationID, conversationType);
        } else {
          ZegoIMKitLogger.severe('loadMessageList faild', error);
          throw error;
        }
      });
    });
  }

  Future<int> loadMoreMessage(
      String conversationID, ZIMConversationType conversationType) async {
    var dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.notInited) {
      await getMessageListNotifier(conversationID, conversationType);
    }
    if (dbMessages.noMore || dbMessages.loading) return 0;
    dbMessages.loading = true;
    ZegoIMKitLogger.info('loadMoreMessage start');

    var config = ZIMMessageQueryConfig();
    config.count = kdefaultLoadCount;
    config.reverse = true;
    config.nextMessage = dbMessages.data.value.first.zim;
    return await ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZegoIMKitLogger.info(
          'queryHistoryMessage: ${zimResult.messageList.length}');

      dbMessages.insertAll(zimResult.messageList);
      // auto download media message
      for (var kitMessage in dbMessages.data.value) {
        if (kitMessage.zim is ZIMMediaMessage) downloadMediaFile(kitMessage);
      }
      ZegoIMKitLogger.info(
          'loadMoreMessage success, length ${zimResult.messageList.length}');
      if (zimResult.messageList.isEmpty ||
          zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;
      return zimResult.messageList.length;
    }).catchError((error) {
      return tryReloginOrNot(error).then((retryCode) {
        dbMessages.loading = false;
        if (retryCode == 0) {
          ZegoIMKitLogger.info('relogin success, retry loadMessageList');
          return loadMoreMessage(conversationID, conversationType);
        } else {
          ZegoIMKitLogger.severe('loadMessageList faild', error);
          throw error;
        }
      });
    });
  }

  void onReceivePeerMessage(
          ZIM zim, List<ZIMMessage> messageList, String fromUserID) =>
      onReceiveMessage(fromUserID, ZIMConversationType.peer, messageList);

  void onReceiveRoomMessage(
          ZIM zim, List<ZIMMessage> messageList, String fromRoomID) =>
      onReceiveMessage(fromRoomID, ZIMConversationType.group, messageList);

  void onReceiveGroupMessage(
          ZIM zim, List<ZIMMessage> messageList, String fromGroupID) =>
      onReceiveMessage(fromGroupID, ZIMConversationType.group, messageList);

  void onReceiveMessage(String id, ZIMConversationType type,
      List<ZIMMessage> receiveMessages) async {
    ZegoIMKitLogger.info(
        'onReceiveMessage: $id, $type, ${receiveMessages.length}');

    if (db.conversations.notInited) {
      await getConversationListNotifier();
    }

    if (db.messages(id, type).notInited) {
      ZegoIMKitLogger.info(
          'onReceiveMessage: notInited, loadMessageList first');
      await getMessageListNotifier(id, type);
    } else {
      db.messages(id, type).receive(receiveMessages);
    }

    // auto download media message
    for (var kitMessage in db.messages(id, type).data.value) {
      if (kitMessage.zim is ZIMMediaMessage) downloadMediaFile(kitMessage);
    }
  }

  void onError(ZIM zim, ZIMError errorInfo) {
    ZegoIMKitLogger.severe(
        "error, code:${errorInfo.code} ,message:${errorInfo.message}");
  }

  void onTokenWillExpire(ZIM zim, int second) {
    ZegoIMKitLogger.info("onTokenWillExpire, second:$second");
  }

  void onConversationTotalUnreadMessageCountUpdated(
      ZIM zim, int totalUnreadMessageCount) {
    ZegoIMKitLogger.info(
        "onConversationTotalUnreadMessageCountUpdated: $totalUnreadMessageCount");
  }

  // need zim 2.5
  void onGroupStateChanged(ZIM zim, ZIMGroupState state, ZIMGroupEvent event,
      ZIMGroupOperatedInfo operatedInfo, ZIMGroupFullInfo groupInfo) {
    ZegoIMKitLogger.info("onGroupStateChanged");
  }

  void onGroupNameUpdated(ZIM zim, String groupName,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZegoIMKitLogger.info("onGroupNameUpdated");
  }

  void onGroupAvatarUrlUpdated(ZIM zim, String groupAvatarUrl,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZegoIMKitLogger.info("onGroupAvatarUrlUpdated");
  }

  void onGroupNoticeUpdated(ZIM zim, String groupNotice,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZegoIMKitLogger.info("onGroupNoticeUpdated");
  }

  void onGroupAttributesUpdated(
      ZIM zim,
      List<ZIMGroupAttributesUpdateInfo> updateInfo,
      ZIMGroupOperatedInfo operatedInfo,
      String groupID) {
    ZegoIMKitLogger.info("onGroupAttributesUpdated");
  }

  // need zim 2.5
  void onGroupMemberStateChanged(
      ZIM zim,
      ZIMGroupMemberState state,
      ZIMGroupMemberEvent event,
      List<ZIMGroupMemberInfo> userList,
      ZIMGroupOperatedInfo operatedInfo,
      String groupID) {
    ZegoIMKitLogger.info("onGroupMemberStateChanged");
  }

  void onGroupMemberInfoUpdated(ZIM zim, List<ZIMGroupMemberInfo> userInfo,
      ZIMGroupOperatedInfo operatedInfo, String groupID) {
    ZegoIMKitLogger.info("onGroupMemberInfoUpdated");
  }

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String mediaPath,
    ZIMMessageType messageType, {
    FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage message)?
        preMessageSending,
    Function(ZegoIMKitMessage message)? onMessageSent,
  }) async {
    if (mediaPath.isEmpty || !File(mediaPath).existsSync()) {
      ZegoIMKitLogger.info(
          "sendMediaMessage: mediaPath is empty or file doesn't exits");
      return;
    }
    // 1. create message
    ZegoIMKitMessage kitMessage =
        ZegoMessageUtils.mediaMessageFactory(mediaPath, messageType).tokit();
    kitMessage.zim.conversationID = conversationID;
    kitMessage.zim.conversationType = conversationType;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;
    ZegoIMKitLogger.info('sendMediaMessage: $mediaPath');

    // 3. call service
    await ZIM
        .getInstance()!
        .sendMediaMessage(
          kitMessage.zim,
          conversationID,
          conversationType,
          ZIMMessageSendConfig(),
          ZIMMediaMessageSendNotification(
            onMediaUploadingProgress:
                ((message, currentFileSize, totalFileSize) {
              final zimMessage = message as ZIMMediaMessage;
              ZegoIMKitLogger.info(
                  "onMediaUploadingProgress: ${zimMessage.fileName}, $currentFileSize/$totalFileSize");
              kitMessage.updateExtraInfo({
                'upload': {
                  ZIMMediaFileType.originalFile.name: {
                    'currentFileSize': currentFileSize,
                    'totalFileSize': totalFileSize,
                  }
                }
              });
            }),
            onMessageAttached: (message) {
              final zimMessage = message as ZIMMediaMessage;
              ZegoIMKitLogger.info(
                  "sendMediaMessage.onMessageAttached: ${zimMessage.fileName}");
              kitMessage.data.value = zimMessage;
              db.messages(conversationID, conversationType).attach(kitMessage);
            },
          ),
        )
        .then((result) {
      ZegoIMKitLogger.info("sendMediaMessage: success, $mediaPath}");
      kitMessage.uploadDone(result.message);
    }).catchError((error) {
      kitMessage.sendFaild();
      return tryReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZegoIMKitLogger.info('relogin success, retry sendMediaMessage');
          sendMediaMessage(
              conversationID, conversationType, mediaPath, messageType,
              preMessageSending: preMessageSending,
              onMessageSent: onMessageSent);
        } else {
          ZegoIMKitLogger.severe(
              'sendMediaMessage: faild, $mediaPath, error:$error');
          throw error;
        }
      });
    });

    // 4. onMessageSent
    onMessageSent?.call(kitMessage);
  }

  Future<void> sendTextMessage(
      String conversationID, ZIMConversationType conversationType, String text,
      {FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage message)?
          preMessageSending,
      Function(ZegoIMKitMessage message)? onMessageSent}) async {
    if (text.isEmpty) {
      ZegoIMKitLogger.info('sendTextMessage: message is empty');
      return;
    }
    // 1. create message
    ZegoIMKitMessage kitMessage = ZIMTextMessage(message: text).tokit();
    ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig();
    ZIMPushConfig pushConfig = ZIMPushConfig();
    sendConfig.pushConfig = pushConfig;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;
    ZegoIMKitLogger.info('sendTextMessage: ${kitMessage.zim.message}');

    // 3. call service
    await ZIM.getInstance()!.sendMessage(
      kitMessage.zim,
      conversationID,
      conversationType,
      sendConfig,
      ZIMMessageSendNotification(
        onMessageAttached: (message) {
          kitMessage.data.value = message as ZIMTextMessage;
          db.messages(conversationID, conversationType).data.add(kitMessage);
        },
      ),
    ).then((result) {
      final zimMessage = result.message as ZIMTextMessage;
      ZegoIMKitLogger.info('sendTextMessage: success, ${zimMessage.message}');
      kitMessage.data.value = zimMessage;
    }).catchError((error) {
      kitMessage.sendFaild();
      return tryReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZegoIMKitLogger.info('relogin success, retry sendTextMessage');
          sendTextMessage(conversationID, conversationType, text,
              preMessageSending: preMessageSending,
              onMessageSent: onMessageSent);
        } else {
          ZegoIMKitLogger.severe('sendTextMessage: faild, $text,error:$error');
          throw error;
        }
      });
    });
    // 4. onMessageSent
    onMessageSent?.call(kitMessage);
  }

  void addMessage(String id, ZIMConversationType type, ZIMMessage message) {
    onReceiveMessage(id, type, [message]);
  }

  void downloadMediaFile(ZegoIMKitMessage kitMessage) {
    if (kitMessage.zim is! ZIMMediaMessage) {
      ZegoIMKitLogger.severe(
          "downloadMediaFile: ${kitMessage.zim.runtimeType} is not ZIMMediaMessage");
      return;
    }

    List<ZIMMediaFileType> downloadTypes = [];

    if ((kitMessage.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
      downloadTypes.add(ZIMMediaFileType.originalFile);
    }
    switch (kitMessage.zim.runtimeType) {
      case ZIMVideoMessage:
        if ((kitMessage.zim as ZIMVideoMessage)
            .videoFirstFrameLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.videoFirstFrame);
        }
        break;
      case ZIMImageMessage:
        if ((kitMessage.zim as ZIMImageMessage).thumbnailLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.thumbnail);
        }
        if ((kitMessage.zim as ZIMImageMessage).largeImageLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.largeImage);
        }
        break;
      case ZIMAudioMessage:
        break;
      case ZIMFileMessage:
        break;

      default:
        ZegoIMKitLogger.severe(
            "not support download ${kitMessage.zim.runtimeType}");
        return;
    }

    for (var downloadType in downloadTypes) {
      ZegoIMKitLogger.info(
          "downloadMediaFile: ${(kitMessage.zim as ZIMMediaMessage).fileName} - ${downloadType.name} start");
      ZIM.getInstance()!.downloadMediaFile(kitMessage.zim, downloadType,
          (ZIMMessage zimMessage, int currentFileSize, int totalFileSize) {
        ZegoIMKitLogger.info(
            "downloadMediaFile: ${(kitMessage.zim as ZIMMediaMessage).fileName} - ${downloadType.name} $currentFileSize/$totalFileSize");
        kitMessage.updateExtraInfo({
          'download': {
            downloadType.name: {
              'currentFileSize': currentFileSize,
              'totalFileSize': totalFileSize,
            }
          }
        });
      }).then((ZIMMediaDownloadedResult result) {
        ZegoIMKitLogger.info(
            "downloadMediaFile: ${(kitMessage.zim as ZIMMediaMessage).fileName} - ${downloadType.name} success");
        kitMessage.downloadDone(downloadType, result.message);
      });
    }
  }

  void onConnectionStateChanged(ZIM zim, ZIMConnectionState state,
      ZIMConnectionEvent event, Map extendedData) {
    ZegoIMKitLogger.info(
        "onConnectionStateChanged ${state.name}, ${event.name}, $extendedData");
    connectionState = state;
    connectionStateCtrl
        .add({'state': state, 'event': event, 'extendedData': extendedData});
  }

  void clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) {
    final conversation = db.conversations.get(conversationID, conversationType);

    try {
      if (conversation.unreadMessageCount > 0) {
        ZIM.getInstance()!.clearConversationUnreadMessageCount(
            conversationID, conversationType);
      }
    } catch (e) {
      ZegoIMKitLogger.severe("clearUnreadCount: $e");
    }
  }

  Future<String?> createGroup(String name, List<String> inviteUserIDs) async {
    String? ret;
    ZIMGroupInfo groupInfo = ZIMGroupInfo();
    groupInfo.groupName = name;
    await ZIM
        .getInstance()!
        .createGroup(groupInfo, inviteUserIDs)
        .then((ZIMGroupCreatedResult zimResult) {
      ZegoIMKitLogger.info(
          "createGroup: success, groupID: ${zimResult.groupInfo.baseInfo.groupID}");
      db.conversations.insert(zimResult.groupInfo.toConversation());
      ret = zimResult.groupInfo.baseInfo.groupID;
    }).catchError((error) {
      ZegoIMKitLogger.severe("createGroup: faild, name: $name, error: $error");
    });
    return ret;
  }

  Future<int> joinGroup(String conversationID) async {
    late int errorCode;

    await ZIM
        .getInstance()!
        .joinGroup(conversationID)
        .then((ZIMGroupJoinedResult zimResult) {
      ZegoIMKitLogger.info(
          "joinGroup: success, groupID: ${zimResult.groupInfo.baseInfo.groupID}");
      db.conversations.insert(zimResult.groupInfo.toConversation());
      errorCode = 0;
    }).catchError((error) {
      errorCode = error.code;
      ZegoIMKitLogger.severe(
          "joinGroup: faild, groupID: $conversationID, error: $error");
    });
    return errorCode;
  }

  Future<int> inviteUsersToJoinGroup(
      String conversationID, List<String> inviteUserIDs) async {
    late int errorCode;
    await ZIM
        .getInstance()!
        .inviteUsersIntoGroup(inviteUserIDs, conversationID)
        .then((ZIMGroupUsersInvitedResult zimResult) {
      ZegoIMKitLogger.info(
          "inviteUsersToJoinGroup: success, groupID: $conversationID");
      errorCode = 0;
    }).catchError((error) {
      errorCode = error.code;
      ZegoIMKitLogger.severe(
          "inviteUsersToJoinGroup: faild, groupID: $conversationID, error: $error");
    });
    return errorCode;
  }

  Future<int> leaveGroup(String conversationID) async {
    late int errorCode;
    await ZIM
        .getInstance()!
        .leaveGroup(conversationID)
        .then((ZIMGroupLeftResult zimResult) {
      ZegoIMKitLogger.info("leaveGroup: success, groupID: $conversationID");
      db.conversations.remove(conversationID, ZIMConversationType.group);
      errorCode = 0;
    }).catchError((error) {
      errorCode = error.code;
      ZegoIMKitLogger.severe(
          "leaveGroup: faild, groupID: $conversationID, error: $error");
    });
    return errorCode;
  }
}
