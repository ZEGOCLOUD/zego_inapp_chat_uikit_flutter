import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/services/internal/imkit_core.dart';

mixin ZIMKitCoreEvent {
  void initEventHandler() {
    ZIMKitLogger.info('register event handle.');

    /*Main*/
    ZIMEventHandler.onError = ZIMKitCore.instance.coreData.onError;
    ZIMEventHandler.onTokenWillExpire =
        ZIMKitCore.instance.coreData.onTokenWillExpire;
    ZIMEventHandler.onConnectionStateChanged =
        ZIMKitCore.instance.coreData.onConnectionStateChanged;

    /*Conversation*/
    ZIMEventHandler.onConversationChanged =
        ZIMKitCore.instance.coreData.onConversationChanged;
    ZIMEventHandler.onConversationTotalUnreadMessageCountUpdated = ZIMKitCore
        .instance.coreData.onConversationTotalUnreadMessageCountUpdated;

    /*Message*/
    ZIMEventHandler.onReceivePeerMessage =
        ZIMKitCore.instance.coreData.onReceivePeerMessage;
    ZIMEventHandler.onReceiveRoomMessage =
        ZIMKitCore.instance.coreData.onReceiveRoomMessage;
    ZIMEventHandler.onReceiveGroupMessage =
        ZIMKitCore.instance.coreData.onReceiveGroupMessage;

    /*Group*/
    ZIMEventHandler.onGroupStateChanged =
        ZIMKitCore.instance.coreData.onGroupStateChanged;
    ZIMEventHandler.onGroupNameUpdated =
        ZIMKitCore.instance.coreData.onGroupNameUpdated;
    ZIMEventHandler.onGroupAvatarUrlUpdated =
        ZIMKitCore.instance.coreData.onGroupAvatarUrlUpdated;
    ZIMEventHandler.onGroupNoticeUpdated =
        ZIMKitCore.instance.coreData.onGroupNoticeUpdated;
    ZIMEventHandler.onGroupAttributesUpdated =
        ZIMKitCore.instance.coreData.onGroupAttributesUpdated;
    ZIMEventHandler.onGroupMemberStateChanged =
        ZIMKitCore.instance.coreData.onGroupMemberStateChanged;
    ZIMEventHandler.onGroupMemberInfoUpdated =
        ZIMKitCore.instance.coreData.onGroupMemberInfoUpdated;
  }

  void uninitEventHandler() {
    ZIMKitLogger.info('unregister event handle.');
    ZIMEventHandler.onError = null;
    ZIMEventHandler.onTokenWillExpire = null;
    ZIMEventHandler.onConversationChanged = null;
    ZIMEventHandler.onConversationTotalUnreadMessageCountUpdated = null;
    ZIMEventHandler.onReceivePeerMessage = null;
    ZIMEventHandler.onReceiveRoomMessage = null;
    ZIMEventHandler.onReceiveGroupMessage = null;
    ZIMEventHandler.onGroupStateChanged = null;
    ZIMEventHandler.onGroupNameUpdated = null;
    ZIMEventHandler.onGroupAvatarUrlUpdated = null;
    ZIMEventHandler.onGroupNoticeUpdated = null;
    ZIMEventHandler.onGroupAttributesUpdated = null;
    ZIMEventHandler.onGroupMemberStateChanged = null;
    ZIMEventHandler.onGroupMemberInfoUpdated = null;
  }
}
