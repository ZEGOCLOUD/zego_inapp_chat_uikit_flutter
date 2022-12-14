import 'package:zego_zim/zego_zim.dart';
import 'imkit_core.dart';

mixin ZegoIMKitCoreEvent {
  void initEventHandler() {
    ZegoIMKitLogger.info("register event handle.");

    /*Main*/
    ZIMEventHandler.onError = ZegoIMKitCore.instance.coreData.onError;
    ZIMEventHandler.onTokenWillExpire = ZegoIMKitCore.instance.coreData.onTokenWillExpire;
    ZIMEventHandler.onConnectionStateChanged = ZegoIMKitCore.instance.coreData.onConnectionStateChanged;

    /*Conversation*/
    ZIMEventHandler.onConversationChanged = ZegoIMKitCore.instance.coreData.onConversationChanged;
    ZIMEventHandler.onConversationTotalUnreadMessageCountUpdated =
        ZegoIMKitCore.instance.coreData.onConversationTotalUnreadMessageCountUpdated;

    /*Message*/
    ZIMEventHandler.onReceivePeerMessage = ZegoIMKitCore.instance.coreData.onReceivePeerMessage;
    ZIMEventHandler.onReceiveRoomMessage = ZegoIMKitCore.instance.coreData.onReceiveRoomMessage;
    ZIMEventHandler.onReceiveGroupMessage = ZegoIMKitCore.instance.coreData.onReceiveGroupMessage;

    /*Group*/
    ZIMEventHandler.onGroupStateChanged = ZegoIMKitCore.instance.coreData.onGroupStateChanged;
    ZIMEventHandler.onGroupNameUpdated = ZegoIMKitCore.instance.coreData.onGroupNameUpdated;
    ZIMEventHandler.onGroupAvatarUrlUpdated = ZegoIMKitCore.instance.coreData.onGroupAvatarUrlUpdated;
    ZIMEventHandler.onGroupNoticeUpdated = ZegoIMKitCore.instance.coreData.onGroupNoticeUpdated;
    ZIMEventHandler.onGroupAttributesUpdated = ZegoIMKitCore.instance.coreData.onGroupAttributesUpdated;
    ZIMEventHandler.onGroupMemberStateChanged = ZegoIMKitCore.instance.coreData.onGroupMemberStateChanged;
    ZIMEventHandler.onGroupMemberInfoUpdated = ZegoIMKitCore.instance.coreData.onGroupMemberInfoUpdated;
  }

  void uninitEventHandler() {
    ZegoIMKitLogger.info("unregister event handle.");
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
