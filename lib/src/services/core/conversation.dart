part of 'core.dart';

extension ZIMKitCoreConversation on ZIMKitCore {
  Future<ZIMKitConversationListNotifier> getConversationListNotifier() async {
    await waitForLoginOrNot();
    if (db.conversations.inited) {
      return db.conversations.notifier;
    }

    final config = ZIMConversationQueryConfig()..count = kDefaultLoadCount;
    return ZIM.getInstance()!.queryConversationList(config).then((zimResult) {
      ZIMKitLogger.info(
        'queryHistoryMessage: ${zimResult.conversationList.length}',
      );

      db.conversations.init(zimResult.conversationList);
      if (zimResult.conversationList.isEmpty ||
          zimResult.conversationList.length < config.count) {
        db.conversations.noMore = true;
      }
      db.conversations.loading = false;

      return db.conversations.notifier;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        db.conversations.loading = false;
        if (retryCode == 0) {
          ZIMKitLogger.info('re-login success, retry loadConversationList');
          return getConversationListNotifier();
        } else {
          ZIMKitLogger.severe('loadConversationList failed', error);
          throw error;
        }
      });
    });
  }

  ValueNotifier<int> getTotalUnreadMessageCount() {
    return totalUnreadMessageCountNotifier;
  }

  Future<int> loadMoreConversation() async {
    await waitForLoginOrNot();

    if (db.conversations.noMore || db.conversations.loading) {
      return 0;
    }

    if (db.conversations.notInited) {
      await getConversationListNotifier();
    }

    if (db.conversations.isEmpty) {
      return 0;
    }

    ZIMKitLogger.info('loadMoreConversation start');

    db.conversations.loading = true;
    // start loading
    final config = ZIMConversationQueryConfig()
      ..count = kDefaultLoadCount
      ..nextConversation = db.conversations.notifier.value.last.value.toZIM();
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
      return checkNeedReloginOrNot(error).then((retryCode) {
        db.conversations.loading = false;
        if (retryCode == 0) {
          ZIMKitLogger.info('re-login success, retry loadConversationList');
          return loadMoreConversation();
        } else {
          ZIMKitLogger.severe('loadConversationList failed', error);
          throw error;
        }
      });
    });
  }

  Future<void> deleteAllConversation({
    bool isAlsoDeleteFromServer = true,
    bool isAlsoDeleteMessages = true,
  }) async {
    if (currentUser == null) return;
    if (isAlsoDeleteMessages) {
      for (var conversation in db.conversations.notifier.value) {
        await ZIM
            .getInstance()!
            .deleteAllMessage(
              conversation.value.id,
              conversation.value.type,
              ZIMMessageDeleteConfig()
                ..isAlsoDeleteServerMessage = isAlsoDeleteFromServer,
            )
            .then((ZIMMessageDeletedResult result) {
          debugPrint(
              'deleteAllConversation, deleteAllMessage success, id:${conversation.value.id}');
          db.messages(conversation.value.id, conversation.value.type).clear();
        }).catchError((error) {
          debugPrint(
              'deleteAllConversation, deleteAllMessage failed: $error, id:${conversation.value.id}');
        });
      }
    }

    ZIM
        .getInstance()!
        .deleteAllConversations(
          ZIMConversationDeleteConfig()
            ..isAlsoDeleteServerConversation = isAlsoDeleteFromServer,
        )
        .then((void _) {
      debugPrint('deleteAllConversation, success');
      db.conversations.deleteAll();
    }).catchError((error) {
      debugPrint('deleteAllConversation, failed: $error');
    });
  }

  Future<void> deleteConversation(
    String id,
    ZIMConversationType type, {
    bool isAlsoDeleteMessages = false,
    bool isAlsoDeleteFromServer = true,
  }) async {
    if (currentUser == null) {
      return;
    }

    if (isAlsoDeleteMessages) {
      db.messages(id, type).clear();
      final config = ZIMMessageDeleteConfig()
        ..isAlsoDeleteServerMessage = isAlsoDeleteFromServer;
      await ZIM
          .getInstance()!
          .deleteAllMessage(id, type, config)
          .then((ZIMMessageDeletedResult result) {
        debugPrint('deleteAllMessage success');
      }).catchError((error) {
        debugPrint('deleteAllMessage failed: $error');
      });
    }

    db.conversations.delete(id, type);
    final deleteConfig = ZIMConversationDeleteConfig()
      ..isAlsoDeleteServerConversation = isAlsoDeleteFromServer;
    await ZIM
        .getInstance()!
        .deleteConversation(id, type, deleteConfig)
        .then((ZIMConversationDeletedResult result) {
      debugPrint('deleteConversation success');
    }).catchError((error) {
      debugPrint('deleteConversation failed: $error');
    });
  }

  void clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) {
    final conversation = db.conversations.get(conversationID, conversationType);

    try {
      if (conversation.value.unreadMessageCount > 0) {
        ZIM.getInstance()!.clearConversationUnreadMessageCount(
              conversationID,
              conversationType,
            );
      }
    } catch (e) {
      ZIMKitLogger.severe('clearUnreadCount: $e');
    }
  }
}

extension ZIMKitCoreConversationEvent on ZIMKitCore {
  void onConversationChanged(
    ZIM zim,
    List<ZIMConversationChangeInfo> conversationChangeInfoList,
  ) {
    for (final changeInfo in conversationChangeInfoList) {
      switch (changeInfo.event) {
        case ZIMConversationEvent.added:
          db.conversations.insertOrUpdate(changeInfo.conversation!.toKIT());
          break;
        case ZIMConversationEvent.updated:
          db.conversations.insertOrUpdate(changeInfo.conversation!.toKIT());
          break;
        case ZIMConversationEvent.disabled:
          db.conversations.disable(changeInfo.conversation!.toKIT());
          break;
        case ZIMConversationEvent.deleted:
          db.conversations.remove(
              changeInfo.conversation!.id, changeInfo.conversation!.type);
          break;
      }
    }
  }

  void onConversationTotalUnreadMessageCountUpdated(
    ZIM zim,
    int totalUnreadMessageCount,
  ) {
    totalUnreadMessageCountNotifier.value = totalUnreadMessageCount;
    ZIMKitLogger.info('onConversationTotalUnreadMessageCountUpdated: '
        '$totalUnreadMessageCount');
  }
}
