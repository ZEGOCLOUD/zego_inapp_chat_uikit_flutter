import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

part 'event_domain.dart';

mixin ZIMKitCoreEvent {
  void initEventHandler() {
    ZIMKitLogger.info('register event handle.');
    final target = ZIMKitCore.instance;
    ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent
      /*Conversation*/
      ..onConversationChanged = target.onConversationChanged
      ..onConversationTotalUnreadMessageCountUpdated =
          target.onConversationTotalUnreadMessageCountUpdated

      /*Message*/
      ..onReceivePeerMessage = target.onReceivePeerMessage
      ..onReceiveRoomMessage = target.onReceiveRoomMessage
      ..onReceiveGroupMessage = target.onReceiveGroupMessage
      ..onMessageRevokeReceived = target.onMessageRevokeReceived
      ..onMessageReactionsChanged = target.onMessageReactionsChanged

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
    ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent
      /*Conversation*/
      ..onConversationChanged = null
      ..onConversationTotalUnreadMessageCountUpdated = null

      /*Message*/
      ..onReceivePeerMessage = null
      ..onReceiveRoomMessage = null
      ..onReceiveGroupMessage = null
      ..onMessageRevokeReceived = null
      ..onMessageReactionsChanged = null

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
