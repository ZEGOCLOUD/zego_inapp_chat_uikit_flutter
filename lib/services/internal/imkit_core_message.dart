part of 'imkit_core.dart';

extension ZIMKitCoreMessage on ZIMKitCore {
  Future<ZIMKitMessageListNotifier> getMessageListNotifier(
      String conversationID, ZIMConversationType conversationType) async {
    await waitForLoginOrNot();
    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.inited) return dbMessages.notifier;

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
      autoDownloadMessage(dbMessages.notifier.value);
      if (zimResult.messageList.isEmpty ||
          zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;
      return dbMessages.notifier;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
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
    await waitForLoginOrNot();
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
      ..nextMessage = dbMessages.notifier.value.first.value.zim;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMKitLogger.info('queryHistoryMessage: ${zimResult.messageList.length}');

      dbMessages.insertAll(zimResult.messageList);
      autoDownloadMessage(dbMessages.notifier.value);
      ZIMKitLogger.info(
          'loadMoreMessage success, length ${zimResult.messageList.length}');
      if (zimResult.messageList.isEmpty ||
          zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;
      return zimResult.messageList.length;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
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
    late ZIMKitMessageNotifier kitMessageNotifier;
    await ZIM
        .getInstance()!
        .sendMediaMessage(
          kitMessage.zim as ZIMMediaMessage,
          conversationID,
          conversationType,
          ZIMMessageSendConfig(),
          ZIMMediaMessageSendNotification(
            onMessageAttached: (zimMessage) {
              ZIMKitLogger.info('sendMediaMessage.onMessageAttached: '
                  '${(zimMessage as ZIMMediaMessage).fileName}');
              kitMessageNotifier = db
                  .messages(conversationID, conversationType)
                  .onAttach(zimMessage);
            },
            onMediaUploadingProgress:
                (message, currentFileSize, totalFileSize) {
              final zimMessage = message as ZIMMediaMessage;
              ZIMKitLogger.info(
                  'onMediaUploadingProgress: ${zimMessage.fileName}, $currentFileSize/$totalFileSize');

              kitMessageNotifier.value = (kitMessageNotifier.value.clone()
                ..updateExtraInfo({
                  'upload': {
                    ZIMMediaFileType.originalFile.name: {
                      'currentFileSize': currentFileSize,
                      'totalFileSize': totalFileSize,
                    }
                  }
                }));
            },
          ),
        )
        .then((result) {
      ZIMKitLogger.info('sendMediaMessage: success, $mediaPath}');
      kitMessageNotifier.value = result.message.tokit();
    }).catchError((error) {
      kitMessageNotifier.value =
          (kitMessageNotifier.value.clone()..sendFaild());
      return checkNeedReloginOrNot(error).then((retryCode) {
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
    late ZIMKitMessageNotifier kitMessageNotifier;
    await ZIM.getInstance()!.sendMessage(
      kitMessage.zim,
      conversationID,
      conversationType,
      sendConfig,
      ZIMMessageSendNotification(
        onMessageAttached: (zimMessage) {
          kitMessageNotifier = db
              .messages(conversationID, conversationType)
              .onAttach(zimMessage);
        },
      ),
    ).then((result) {
      ZIMKitLogger.info('sendTextMessage: success, $text');
      kitMessageNotifier.value = (kitMessageNotifier.value.clone()
        ..info.sentStatus = ZIMMessageSentStatus.success);
    }).catchError((error) {
      kitMessageNotifier.value = (kitMessageNotifier.value.clone()
        ..info.sentStatus = ZIMMessageSentStatus.failed);
      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry sendTextMessage');
          sendTextMessage(conversationID, conversationType, text,
              preMessageSending: preMessageSending,
              onMessageSent: onMessageSent);
        } else {
          ZIMKitLogger.severe('sendTextMessage: faild, $text,error:$error');
          onMessageSent?.call(kitMessageNotifier.value);
          throw error;
        }
      });
    });
  }

  void addMessage(String id, ZIMConversationType type, ZIMMessage message) {
    onReceiveMessage(id, type, [message]);
  }

  // TODO use flutter cache manager.
  void downloadMediaFile(ZIMKitMessage kitMessage) {
    final kitMessageNotifier = db
        .messages(
          kitMessage.info.conversationID,
          kitMessage.info.conversationType,
        )
        .notifier
        .value
        .firstWhere((element) =>
            element.value.info.localMessageID ==
            kitMessage.info.localMessageID);
    _downloadMediaFile(kitMessageNotifier);
  }

  void _downloadMediaFile(ZIMKitMessageNotifier kitMessageNotifier) {
    if (kitMessageNotifier.value.zim is! ZIMMediaMessage) {
      ZIMKitLogger.severe(
          'downloadMediaFile: ${kitMessageNotifier.value.zim.runtimeType} '
          'is not ZIMMediaMessage');
      return;
    }

    final downloadTypes = <ZIMMediaFileType>[];

    switch (kitMessageNotifier.value.zim.runtimeType) {
      case ZIMVideoMessage:
        if ((kitMessageNotifier.value.zim as ZIMVideoMessage)
            .videoFirstFrameLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.videoFirstFrame);
        }
        if ((kitMessageNotifier.value.zim as ZIMMediaMessage)
            .fileLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMImageMessage:
        // just use flutter cache manager
        break;
      case ZIMAudioMessage:
        if ((kitMessageNotifier.value.zim as ZIMMediaMessage)
            .fileLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMFileMessage:
        if ((kitMessageNotifier.value.zim as ZIMMediaMessage)
            .fileLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;

      default:
        ZIMKitLogger.severe(
            'not support download ${kitMessageNotifier.value.zim.runtimeType}');
        return;
    }

    for (final downloadType in downloadTypes) {
      final zimMediaMessage = kitMessageNotifier.value.zim as ZIMMediaMessage;
      ZIMKitLogger.info('downloadMediaFile: ${zimMediaMessage.fileName} - '
          '${downloadType.name} start');
      ZIM.getInstance()!.downloadMediaFile(
          kitMessageNotifier.value.zim as ZIMMediaMessage, downloadType,
          (ZIMMessage zimMessage, int currentFileSize, int totalFileSize) {
        ZIMKitLogger.info('downloadMediaFile: ${zimMediaMessage.fileName} - '
            '${downloadType.name} $currentFileSize/$totalFileSize');

        kitMessageNotifier.value = (kitMessageNotifier.value.clone()
          ..updateExtraInfo({
            'download': {
              downloadType.name: {
                'currentFileSize': currentFileSize,
                'totalFileSize': totalFileSize,
              }
            }
          }));
      }).then((ZIMMediaDownloadedResult result) {
        ZIMKitLogger.info('downloadMediaFile: ${zimMediaMessage.fileName} - '
            '${downloadType.name} success');
        kitMessageNotifier.value = (kitMessageNotifier.value.clone()
          ..downloadDone(downloadType, result.message));
      });
    }
  }
}

extension ZIMKitCoreMessageEvent on ZIMKitCore {
  void onReceivePeerMessage(
          ZIM zim, List<ZIMMessage> messageList, String fromUserID) =>
      onReceiveMessage(fromUserID, ZIMConversationType.peer, messageList);

  void onReceiveRoomMessage(
          ZIM zim, List<ZIMMessage> messageList, String fromRoomID) =>
      onReceiveMessage(fromRoomID, ZIMConversationType.group, messageList);

  void onReceiveGroupMessage(
          ZIM zim, List<ZIMMessage> messageList, String fromGroupID) =>
      onReceiveMessage(fromGroupID, ZIMConversationType.group, messageList);

  Future<void> onReceiveMessage(String id, ZIMConversationType type,
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

    db.conversations.sort();

    autoDownloadMessage(db.messages(id, type).notifier.value);
  }

  void autoDownloadMessage(List<ZIMKitMessageNotifier> kitMessages) {
    if (!kEnableAutoDownload) return;
    for (final kitMessage in kitMessages) {
      if (kitMessage.value.zim is ZIMMediaMessage) {
        _downloadMediaFile(kitMessage);
      }
    }
  }
}
