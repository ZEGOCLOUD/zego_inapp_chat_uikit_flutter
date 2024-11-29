part of 'core.dart';

extension ZIMKitCoreMessageMedia on ZIMKitCore {
  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String mediaPath,
    ZIMMessageType messageType, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage message)? preMessageSending,
    Function(ZIMKitMessage message)? onMessageSent,
    int audioDuration = 0,
  }) async {
    if (mediaPath.isEmpty || !File(mediaPath).existsSync()) {
      ZIMKitLogger.warning(
          "sendMediaMessage: mediaPath is empty or file doesn't exits");
      return;
    }
    if (conversationID.isEmpty) {
      ZIMKitLogger.warning('sendCustomMessage: conversationID is empty');
      return;
    }

    // 1. create message
    var kitMessage = ZIMKitMessageUtils.mediaMessageFactory(
      mediaPath,
      messageType,
      audioDuration: audioDuration,
    ).toKIT();
    kitMessage.zim.conversationID = conversationID;
    kitMessage.zim.conversationType = conversationType;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;

    // 3. re-generate zim
    // ignore: cascade_invocations
    kitMessage.reGenerateZIMMessage();

    final sendConfig = ZIMMessageSendConfig();
    if (ZegoZIMKitNotificationManager.instance.resourceID?.isNotEmpty ??
        false) {
      final pushConfig = ZIMPushConfig()
        ..resourcesID = ZegoZIMKitNotificationManager.instance.resourceID!
        ..title = ZIMKit().currentUser()?.baseInfo.userName ?? ''

        /// media only show [type] for offline message
        ..content = '[${messageType.name}]'
        ..payload = const JsonEncoder().convert(
          {
            ZIMKitInvitationProtocolKey.operationType:
                BackgroundMessageType.mediaMessage.text,
            'id': conversationID,
            'sender': {
              'id': ZIMKit().currentUser()?.baseInfo.userID ?? '',
              'name': ZIMKit().currentUser()?.baseInfo.userName ?? '',
            },
            'type': conversationType.index,
          },
        );
      sendConfig.pushConfig = pushConfig;
    }

    final mediaMessagePath =
        // ignore: avoid_dynamic_calls
        kitMessage.autoContent.fileDownloadUrl.isNotEmpty
            // ignore: avoid_dynamic_calls
            ? kitMessage.autoContent.fileDownloadUrl
            : mediaPath;
    ZIMKitLogger.info('sendMediaMessage: $mediaMessagePath');

    // 3. call service
    late ZIMKitMessageNotifier kitMessageNotifier;
    await ZIM
        .getInstance()!
        .sendMediaMessage(
          kitMessage.zim as ZIMMediaMessage,
          conversationID,
          conversationType,
          sendConfig,
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
      kitMessageNotifier.value = result.message.toKIT();
      onMessageSent?.call(kitMessageNotifier.value);
    }).catchError((error) {
      kitMessageNotifier.value =
          (kitMessageNotifier.value.clone()..sendFailed(error));
      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.info('relogin success, retry sendMediaMessage');
          sendMediaMessage(
            conversationID,
            conversationType,
            mediaPath,
            messageType,
            preMessageSending: preMessageSending,
            onMessageSent: onMessageSent,
          );
        } else {
          ZIMKitLogger.severe(
              'sendMediaMessage: failed, $mediaPath, error:$error');
          onMessageSent?.call(kitMessageNotifier.value);
          throw error;
        }
      });
    });
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

    if (kitMessageNotifier.value.isNetworkUrl) {
      ZIMKitLogger.severe(
          'downloadMediaFile: ${kitMessageNotifier.value.zim.runtimeType} '
          'is network url.');
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

  void autoDownloadMessage(List<ZIMKitMessageNotifier> kitMessages) {
    if (!kEnableAutoDownload) {
      return;
    }

    for (final kitMessage in kitMessages) {
      if (kitMessage.value.zim is ZIMMediaMessage) {
        _downloadMediaFile(kitMessage);
      }
    }
  }
}
