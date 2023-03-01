import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/services/internal/imkit_core.dart';

mixin ZIMKitCoreEvent {
  void initEventHandler() {
    ZIMKitLogger.info('register event handle.');
    final target = ZIMKitCore.instance;
    ZegoUIKitSignalingPlugin().eventCenter.passthrougnEvent
      /*Conversation*/
      ..onConversationChanged = target.onConversationChanged
      ..onConversationTotalUnreadMessageCountUpdated =
          target.onConversationTotalUnreadMessageCountUpdated

      /*Message*/
      ..onReceivePeerMessage = target.onReceivePeerMessage
      ..onReceiveRoomMessage = target.onReceiveRoomMessage
      ..onReceiveGroupMessage = target.onReceiveGroupMessage

      /*Group*/
      ..onGroupStateChanged = target.onGroupStateChanged
      ..onGroupNameUpdated = target.onGroupNameUpdated
      ..onGroupAvatarUrlUpdated = target.onGroupAvatarUrlUpdated
      ..onGroupNoticeUpdated = target.onGroupNoticeUpdated
      ..onGroupAttributesUpdated = target.onGroupAttributesUpdated
      ..onGroupMemberStateChanged = target.onGroupMemberStateChanged
      ..onGroupMemberInfoUpdated = target.onGroupMemberInfoUpdated;
  }

  void uninitEventHandler() {
    ZIMKitLogger.info('unregister event handle.');
    ZegoUIKitSignalingPlugin().eventCenter.passthrougnEvent
      /*Conversation*/
      ..onConversationChanged = null
      ..onConversationTotalUnreadMessageCountUpdated = null

      /*Message*/
      ..onReceivePeerMessage = null
      ..onReceiveRoomMessage = null
      ..onReceiveGroupMessage = null

      /*Group*/
      ..onGroupStateChanged = null
      ..onGroupNameUpdated = null
      ..onGroupAvatarUrlUpdated = null
      ..onGroupNoticeUpdated = null
      ..onGroupAttributesUpdated = null
      ..onGroupMemberStateChanged = null
      ..onGroupMemberInfoUpdated = null;
  }
}
