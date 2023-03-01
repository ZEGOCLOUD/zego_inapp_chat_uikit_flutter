part of 'imkit_core.dart';

extension ZIMKitCoreConversation on ZIMKitCore {
  Future<ZIMKitConversationListNotifier> getConversationListNotifier() async {
    await waitForLoginOrNot();
    if (db.conversations.inited) return db.conversations.notifier;

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
      return db.conversations.notifier;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
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
    await waitForLoginOrNot();
    if (db.conversations.noMore || db.conversations.loading) return 0;
    if (db.conversations.notInited) await getConversationListNotifier();
    if (db.conversations.isEmpty) return 0;
    ZIMKitLogger.info('loadMoreConversation start');

    db.conversations.loading = true;
    // start loading
    final config = ZIMConversationQueryConfig()
      ..count = kdefaultLoadCount
      ..nextConversation = db.conversations.notifier.value.last.value.tozim();
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
    if (currentUser == null) return;
    db.conversations.delete(id, type);

    final deleteConfig = ZIMConversationDeleteConfig()
      ..isAlsoDeleteServerConversation = isAlsoDeleteServerConversation;
    await ZIM.getInstance()!.deleteConversation(id, type, deleteConfig);
  }

  void clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) {
    final conversation = db.conversations.get(conversationID, conversationType);

    try {
      if (conversation.value.unreadMessageCount > 0) {
        ZIM.getInstance()!.clearConversationUnreadMessageCount(
            conversationID, conversationType);
      }
    } catch (e) {
      ZIMKitLogger.severe('clearUnreadCount: $e');
    }
  }
}

extension ZIMKitCoreConversationEvent on ZIMKitCore {
  void onConversationChanged(
      ZIM zim, List<ZIMConversationChangeInfo> conversationChangeInfoList) {
    for (final changeInfo in conversationChangeInfoList) {
      switch (changeInfo.event) {
        case ZIMConversationEvent.added:
          db.conversations.insert(changeInfo.conversation!.tokit());
          break;
        case ZIMConversationEvent.updated:
          db.conversations.update(changeInfo.conversation!.tokit());
          break;
        case ZIMConversationEvent.disabled:
          db.conversations.disable(changeInfo.conversation!.tokit());
          break;
      }
    }
  }

  void onConversationTotalUnreadMessageCountUpdated(
      ZIM zim, int totalUnreadMessageCount) {
    ZIMKitLogger.info('onConversationTotalUnreadMessageCountUpdated: '
        '$totalUnreadMessageCount');
  }
}
