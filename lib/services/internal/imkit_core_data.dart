import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:async/async.dart';

import 'package:zego_zimkit/services/internal/imkit_core_defines.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

const int kdefaultLoadCount = 30; // default is 30
const bool kEnableAutoDownload = true; // TODO use flutter cache manager

class ZIMKitCoreData {
  int appID = 0;
  String appSign = '';
  String appSecret = '';
  bool useToken = false;

  bool isInited = false;
  ZIMUserFullInfo? currentUser;

  Completer? loginCompleter;
  ZIMConnectionState connectionState = ZIMConnectionState.disconnected;
  StreamController<Map> connectionStateCtrl = StreamController<Map>.broadcast();

  ZIMKitDB db = ZIMKitDB();

  Future<String> getVersion() async {
    final zimVersion = await ZIM.getVersion();
    return 'imkit:0.1.1;zim:$zimVersion';
  }

  void clear() {
    connectionState = ZIMConnectionState.disconnected;
    db.clear();
    currentUser = null;
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
  }) async {
    this.appID = appID;
    this.appSign = appSign;
    this.appSecret = appSecret;

    if (isInited) {
      ZIMKitLogger.info('has inited.');
      return;
    }

    ZIMKitLogger.info('init, appID:$appID');
    isInited = true;

    final appConfig = ZIMAppConfig()
      ..appID = appID
      ..appSign = appSign;
    ZIM.create(appConfig);

    getVersion().then((value) {
      ZIMKitLogger.info('Zego IM SDK version: $value');
    });
  }

  Future<void> uninit() async {
    if (!isInited) {
      ZIMKitLogger.info('is not inited.');
      return;
    }
    ZIMKitLogger.info('destroy.');
    isInited = false;
    await disconnectUser();
    ZIM.getInstance()?.destroy();
  }

  Future<int> tryReloginOrNot(Exception error) async {
    if (error is PlatformException &&
        int.parse(error.code) == ZIMErrorCode.networkModuleUserIsNotLogged &&
        currentUser != null) {
      ZIMKitLogger.info('try auto relogin.');
      return connectUser(
          id: currentUser!.baseInfo.userID,
          name: currentUser!.baseInfo.userName);
    } else {
      return -1;
    }
  }

  Future<int> connectUser(
      {required String id, String name = '', String token = ''}) async {
    if (!isInited) {
      ZIMKitLogger.info('is not inited.');
      throw Exception('ZIMKit is not inited.');
    }
    if (currentUser != null) {
      ZIMKitLogger.info('has login, auto logout');
      await disconnectUser();
    }

    ZIMKitLogger.info('login request, user id:$id, user name:$name');
    currentUser = ZIMUserFullInfo()
      ..baseInfo.userID = id
      ..baseInfo.userName = name.isNotEmpty ? name : id;

    ZIMKitLogger.info('ready to login..');
    final _token = token.isNotEmpty
        ? token
        : (appSign.isEmpty || kIsWeb)
            ? await ZIMKitTokenUtils.generateZIMKitToken(appID, appSecret, id)
            : null;
    return ZIM
        .getInstance()!
        .login(currentUser!.baseInfo, _token)
        .then((value) {
      ZIMKitLogger.info('login success');

      // query currentUser's full info
      queryUser(currentUser!.baseInfo.userID).then((ZIMUserFullInfo zimResult) {
        currentUser = zimResult;
        loginCompleter?.complete();
      });

      return 0;
    }).catchError((error, stackTrace) {
      ZIMKitLogger.info('login error, $error');
      return int.parse((error as PlatformException).code);
    });
  }

  Future<void> disconnectUser() async {
    ZIMKitLogger.info('logout.');
    clear();
    ZIM.getInstance()!.logout();

    // waitForDisconnect
    if (connectionState != ZIMConnectionState.disconnected) {
      final completer = Completer();
      final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (connectionState == ZIMConnectionState.disconnected) {
          if (timer.isActive) timer.cancel();
          if (!completer.isCompleted) completer.complete();
          ZIMKitLogger.info('waitForDisconnect success');
        }
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (timer.isActive) timer.cancel();
        if (!completer.isCompleted) completer.complete();
        ZIMKitLogger.info('waitForDisconnect timeout');
      });
      await completer.future;
    }
  }

  // TODO 优化，如果短时间内来了大量请求，合并请求再调sdk
  final Map<int, AsyncCache<ZIMUserFullInfo>> _queryUserCache = {};
  Future<ZIMUserFullInfo> queryUser(String id,
      {bool isQueryFromServer = true}) async {
    final queryHash = Object.hash(id, isQueryFromServer);
    if (_queryUserCache[queryHash] == null) {
      _queryUserCache[queryHash] = AsyncCache(const Duration(minutes: 5));
    }
    return _queryUserCache[queryHash]!.fetch(() async {
      ZIMKitLogger.info(
          'queryUser, id:$id, isQueryFromServer:$isQueryFromServer');
      final config = ZIMUserInfoQueryConfig()
        ..isQueryFromServer = isQueryFromServer;
      return ZIM.getInstance()!.queryUsersInfo([id], config).then(
          (ZIMUsersInfoQueriedResult result) {
        return result.userList.first;
      }).catchError((error) {
        if (error is PlatformException && int.parse(error.code) == 6000012) {
          if (isQueryFromServer) {
            ZIMKitLogger.info('queryUser faild, retry queryUser from sdk');
            return queryUser(id, isQueryFromServer: false);
          } else {
            ZIMKitLogger.info(
                'queryUser from sdk faild, retry queryUser from server later');
            // TODO test me
            return Future.delayed(
                const Duration(seconds: 1), () => ZIMKit().queryUser(id));
          }
        }

        return tryReloginOrNot(error).then((retryCode) {
          if (retryCode == 0) {
            ZIMKitLogger.info('relogin success, retry queryUser');
            return queryUser(id);
          } else {
            _queryUserCache[queryHash]!.invalidate();
            ZIMKitLogger.severe('queryUser faild', error);
            throw error;
          }
        });
      });
    });
  }

  Future<ListNotifier<ZIMKitConversation>> getConversationListNotifier() async {
    if (db.conversations.inited) return db.conversations.data;
    if (currentUser == null) {
      loginCompleter ??= Completer();
      await loginCompleter!.future;
      loginCompleter = null;
    }

    final config = ZIMConversationQueryConfig()..count = kdefaultLoadCount;
    return ZIM.getInstance()!.queryConversationList(config).then((zimResult) {
      ZIMKitLogger.info(
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
          ZIMKitLogger.info('relogin success, retry loadConversationList');
          return getConversationListNotifier();
        } else {
          ZIMKitLogger.severe('loadConversationList faild', error);
          throw error;
        }
      });
    });
  }

  Future<int> loadMoreConversation() async {
    if (db.conversations.noMore || db.conversations.loading) return 0;
    if (db.conversations.notInited) await getConversationListNotifier();
    if (db.conversations.isEmpty) return 0;
    ZIMKitLogger.info('loadMoreConversation start');

    db.conversations.loading = true;
    // start loading
    final config = ZIMConversationQueryConfig()
      ..count = kdefaultLoadCount
      ..nextConversation = db.conversations.data.value.last.zim;
    return ZIM.getInstance()!.queryConversationList(config).then((zimResult) {
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
          ZIMKitLogger.info('relogin success, retry loadConversationList');
          return loadMoreConversation();
        } else {
          ZIMKitLogger.severe('loadConversationList faild', error);
          throw error;
        }
      });
    });
  }

  Future<void> deleteConversation(String id, ZIMConversationType type,
      {bool isAlsoDeleteServerConversation = true}) async {
    db.conversations.delete(id, type);

    final deleteConfig = ZIMConversationDeleteConfig()
      ..isAlsoDeleteServerConversation = isAlsoDeleteServerConversation;
    await ZIM.getInstance()!.deleteConversation(id, type, deleteConfig);
  }

  void onConversationChanged(
      ZIM zim, List<ZIMConversationChangeInfo> conversationChangeInfoList) {
    for (final changeInfo in conversationChangeInfoList) {
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

  Future<ListNotifier<ZIMKitMessage>> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) async {
    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.inited) return dbMessages.data;
    if (currentUser == null) {
      loginCompleter ??= Completer();
      await loginCompleter!.future;
      loginCompleter = null;
    }

    // start load
    dbMessages.loading = true;
    final config = ZIMMessageQueryConfig()
      ..reverse = true
      ..count = kdefaultLoadCount;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMKitLogger.info('queryHistoryMessage: ${zimResult.messageList.length}');
      dbMessages.init(zimResult.messageList);
      // auto download media message
      for (final kitMessage in dbMessages.data.value) {
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
          ZIMKitLogger.info('relogin success, retry loadMessageList');
          return getMessageListNotifier(conversationID, conversationType);
        } else {
          ZIMKitLogger.severe('loadMessageList faild', error);
          throw error;
        }
      });
    });
  }

  Future<int> loadMoreMessage(
      String conversationID, ZIMConversationType conversationType) async {
    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.notInited) {
      await getMessageListNotifier(conversationID, conversationType);
    }
    if (dbMessages.noMore || dbMessages.loading) return 0;
    dbMessages.loading = true;
    ZIMKitLogger.info('loadMoreMessage start');

    final config = ZIMMessageQueryConfig()
      ..count = kdefaultLoadCount
      ..reverse = true
      ..nextMessage = dbMessages.data.value.first.zim;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMKitLogger.info('queryHistoryMessage: ${zimResult.messageList.length}');

      dbMessages.insertAll(zimResult.messageList);
      // auto download media message
      for (final kitMessage in dbMessages.data.value) {
        if (kitMessage.zim is ZIMMediaMessage) downloadMediaFile(kitMessage);
      }
      ZIMKitLogger.info(
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
          ZIMKitLogger.info('relogin success, retry loadMessageList');
          return loadMoreMessage(conversationID, conversationType);
        } else {
          ZIMKitLogger.severe('loadMessageList faild', error);
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
    ZIMKitLogger.info(
        'onReceiveMessage: $id, $type, ${receiveMessages.length}');

    if (db.conversations.notInited) {
      await getConversationListNotifier();
    }

    if (db.messages(id, type).notInited) {
      ZIMKitLogger.info('onReceiveMessage: notInited, loadMessageList first');
      await getMessageListNotifier(id, type);
    } else {
      db.messages(id, type).receive(receiveMessages);
    }

    // auto download media message
    for (final kitMessage in db.messages(id, type).data.value) {
      if (kitMessage.zim is ZIMMediaMessage) downloadMediaFile(kitMessage);
    }
  }

  void onError(ZIM zim, ZIMError errorInfo) {
    ZIMKitLogger.severe(
        'error, code:${errorInfo.code} ,message:${errorInfo.message}');
  }

  void onTokenWillExpire(ZIM zim, int second) {
    ZIMKitLogger.info('onTokenWillExpire, second:$second');
  }

  void onConversationTotalUnreadMessageCountUpdated(
      ZIM zim, int totalUnreadMessageCount) {
    ZIMKitLogger.info(
        'onConversationTotalUnreadMessageCountUpdated: $totalUnreadMessageCount');
  }

  // need zim 2.5
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

  // need zim 2.5
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

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String mediaPath,
    ZIMMessageType messageType, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage message)? preMessageSending,
    Function(ZIMKitMessage message)? onMessageSent,
  }) async {
    if (mediaPath.isEmpty || !File(mediaPath).existsSync()) {
      ZIMKitLogger.info(
          "sendMediaMessage: mediaPath is empty or file doesn't exits");
      return;
    }
    // 1. create message
    var kitMessage =
        ZIMKitMessageUtils.mediaMessageFactory(mediaPath, messageType).tokit();
    kitMessage.zim.conversationID = conversationID;
    kitMessage.zim.conversationType = conversationType;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;
    ZIMKitLogger.info('sendMediaMessage: $mediaPath');

    // 3. call service
    await ZIM
        .getInstance()!
        .sendMediaMessage(
          kitMessage.zim as ZIMMediaMessage,
          conversationID,
          conversationType,
          ZIMMessageSendConfig(),
          ZIMMediaMessageSendNotification(
            onMediaUploadingProgress:
                (message, currentFileSize, totalFileSize) {
              final zimMessage = message as ZIMMediaMessage;
              ZIMKitLogger.info(
                  'onMediaUploadingProgress: ${zimMessage.fileName}, $currentFileSize/$totalFileSize');
              kitMessage.updateExtraInfo({
                'upload': {
                  ZIMMediaFileType.originalFile.name: {
                    'currentFileSize': currentFileSize,
                    'totalFileSize': totalFileSize,
                  }
                }
              });
            },
            onMessageAttached: (message) {
              final zimMessage = message as ZIMMediaMessage;
              ZIMKitLogger.info(
                  'sendMediaMessage.onMessageAttached: ${zimMessage.fileName}');
              kitMessage.data.value = zimMessage;
              db.messages(conversationID, conversationType).attach(kitMessage);
            },
          ),
        )
        .then((result) {
      ZIMKitLogger.info('sendMediaMessage: success, $mediaPath}');
      kitMessage.data.value = result.message.clone();
    }).catchError((error) {
      kitMessage.sendFaild();
      return tryReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry sendMediaMessage');
          sendMediaMessage(
              conversationID, conversationType, mediaPath, messageType,
              preMessageSending: preMessageSending,
              onMessageSent: onMessageSent);
        } else {
          ZIMKitLogger.severe(
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
      {FutureOr<ZIMKitMessage> Function(ZIMKitMessage message)?
          preMessageSending,
      Function(ZIMKitMessage message)? onMessageSent}) async {
    if (text.isEmpty) {
      ZIMKitLogger.info('sendTextMessage: message is empty');
      return;
    }
    // 1. create message
    var kitMessage = ZIMTextMessage(message: text).tokit();
    final sendConfig = ZIMMessageSendConfig();
    final pushConfig = ZIMPushConfig();
    sendConfig.pushConfig = pushConfig;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;
    ZIMKitLogger.info('sendTextMessage: $text');

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
      ZIMKitLogger.info('sendTextMessage: success, $text');
      kitMessage.data.value = result.message.clone();
    }).catchError((error) {
      kitMessage.sendFaild();
      return tryReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry sendTextMessage');
          sendTextMessage(conversationID, conversationType, text,
              preMessageSending: preMessageSending,
              onMessageSent: onMessageSent);
        } else {
          ZIMKitLogger.severe('sendTextMessage: faild, $text,error:$error');
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

  // TODO use flutter cache manager.
  void downloadMediaFile(ZIMKitMessage kitMessage) {
    if (kitMessage.zim is! ZIMMediaMessage) {
      ZIMKitLogger.severe(
          'downloadMediaFile: ${kitMessage.zim.runtimeType} is not ZIMMediaMessage');
      return;
    }

    final downloadTypes = <ZIMMediaFileType>[];

    switch (kitMessage.zim.runtimeType) {
      case ZIMVideoMessage:
        if ((kitMessage.zim as ZIMVideoMessage)
            .videoFirstFrameLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.videoFirstFrame);
        }
        if ((kitMessage.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMImageMessage:
        // just use flutter cache manager
        break;
      case ZIMAudioMessage:
        if ((kitMessage.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMFileMessage:
        if ((kitMessage.zim as ZIMMediaMessage).fileLocalPath.isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;

      default:
        ZIMKitLogger.severe(
            'not support download ${kitMessage.zim.runtimeType}');
        return;
    }

    for (final downloadType in downloadTypes) {
      ZIMKitLogger.info(
          'downloadMediaFile: ${(kitMessage.zim as ZIMMediaMessage).fileName} - ${downloadType.name} start');
      ZIM
          .getInstance()!
          .downloadMediaFile(kitMessage.zim as ZIMMediaMessage, downloadType,
              (ZIMMessage zimMessage, int currentFileSize, int totalFileSize) {
        ZIMKitLogger.info(
            'downloadMediaFile: ${(kitMessage.zim as ZIMMediaMessage).fileName} - ${downloadType.name} $currentFileSize/$totalFileSize');
        kitMessage.updateExtraInfo({
          'download': {
            downloadType.name: {
              'currentFileSize': currentFileSize,
              'totalFileSize': totalFileSize,
            }
          }
        });
      }).then((ZIMMediaDownloadedResult result) {
        ZIMKitLogger.info(
            'downloadMediaFile: ${(kitMessage.zim as ZIMMediaMessage).fileName} - ${downloadType.name} success');
        kitMessage.downloadDone(downloadType, result.message);
      });
    }
  }

  void onConnectionStateChanged(ZIM zim, ZIMConnectionState state,
      ZIMConnectionEvent event, Map extendedData) {
    ZIMKitLogger.info(
        'onConnectionStateChanged ${state.name}, ${event.name}, $extendedData');
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
      ZIMKitLogger.severe('clearUnreadCount: $e');
    }
  }

  Future<String?> createGroup(String name, List<String> inviteUserIDs,
      {String id = ''}) async {
    String? ret;
    final groupInfo = ZIMGroupInfo()
      ..groupName = name
      ..groupID = id;
    await ZIM
        .getInstance()!
        .createGroup(groupInfo, inviteUserIDs)
        .then((ZIMGroupCreatedResult zimResult) {
      ZIMKitLogger.info(
          'createGroup: success, groupID: ${zimResult.groupInfo.baseInfo.groupID}');
      db.conversations.insert(zimResult.groupInfo.toConversation());
      ret = zimResult.groupInfo.baseInfo.groupID;
    }).catchError((error) {
      ZIMKitLogger.severe('createGroup: faild, name: $name, error: $error');
    });
    return ret;
  }

  Future<int> joinGroup(String conversationID) async {
    late int errorCode;

    await ZIM
        .getInstance()!
        .joinGroup(conversationID)
        .then((ZIMGroupJoinedResult zimResult) {
      ZIMKitLogger.info(
          'joinGroup: success, groupID: ${zimResult.groupInfo.baseInfo.groupID}');
      db.conversations.insert(zimResult.groupInfo.toConversation());
      errorCode = 0;
    }).catchError((error) {
      errorCode = int.parse(error.code);
      if (errorCode == ZIMErrorCode.groupModuleMemberIsAlreadyInTheGroup) {
        ZIM
            .getInstance()!
            .queryGroupList()
            .then((ZIMGroupListQueriedResult zimResult) {
          var gotIt = false;
          // TODO db.groupList
          for (final group in zimResult.groupList) {
            if (group.baseInfo!.id == conversationID) {
              db.conversations.insert(group.toConversation());
              gotIt = true;
              break;
            }
          }
          if (!gotIt) {
            ZIMKitLogger.info(
                'joinGroup: warning, already in, but query faild: $conversationID, insert a dummy conversation');
            db.conversations.insert(
              ZIMConversation()
                ..id = conversationID
                ..type = ZIMConversationType.group,
            );
          }
        }).catchError((error) {
          ZIMKitLogger.severe(
              'joinGroup: faild, already in, but query faild: $conversationID, error: $error');
        });
      } else {
        ZIMKitLogger.severe(
            'joinGroup: faild, groupID: $conversationID, error: $error');
      }
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
      ZIMKitLogger.info(
          'inviteUsersToJoinGroup: success, groupID: $conversationID');
      errorCode = 0;
    }).catchError((error) {
      errorCode = int.parse(error.code);
      ZIMKitLogger.severe(
          'inviteUsersToJoinGroup: faild, groupID: $conversationID, error: $error');
    });
    return errorCode;
  }

  Future<int> leaveGroup(String conversationID) async {
    late int errorCode;
    await ZIM
        .getInstance()!
        .leaveGroup(conversationID)
        .then((ZIMGroupLeftResult zimResult) {
      ZIMKitLogger.info('leaveGroup: success, groupID: $conversationID');
      db.conversations.remove(conversationID, ZIMConversationType.group);
      errorCode = 0;
    }).catchError((error) {
      errorCode = int.parse(error.code);
      if (errorCode == ZIMErrorCode.groupModuleUserIsNotInTheGroup) {
        db.conversations.remove(conversationID, ZIMConversationType.group);
      }
      ZIMKitLogger.severe(
          'leaveGroup: faild, groupID: $conversationID, error: $error');
    });
    return errorCode;
  }
}
