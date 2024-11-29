## 1.18.13

- Fix the issue that the chat list does not automatically jump to the bottom

## 1.18.12

- Update dependency


## 1.18.11

- Update dependency

## 1.18.10

- Fix the issue of incomplete display on iPhone Pro Max

## 1.18.9

- Update dependency

## 1.18.8

- Features
  - time display added to message list

## 1.18.3-1.18.7

- Update dependency.

## 1.18.2

- Features
  - Add `messageInputHeight` in `ZIMKitMessageListPage` to control height of input container.
  
## 1.18.1

- Features
  - Add `showRecordButton` and `showMoreButton` in `ZIMKitMessageListPage` to control visibility of record button or more button.

## 1.18.0

- Features
  - Add `ZIMKitAudioRecordEvents`, support listening to voice recording related callbacks, such as `onFailed`, `onCountdownTick`.
  - Add `ZIMKitMessageListPageEvents` to support `audioRecord(ZIMKitAudioRecordEvents)` event listen.
  - Add `events(ZIMKitMessageListPageEvents)` property in `ZIMKitMessageListPage`
  - Add **more** in `ZIMKitMessageInputAction`, which will display in more pop-ups
  - Optimized bottom input-board style
  - 
## 1.17.2

 - fix compile issue.

## 1.17.1

 - ignore non-zego fcm message.

## 1.17.0

 - support group manager.

## 1.16.1

 - support ZIMKit().deleteAllConversastions().

## 1.16.0

  1. Add the "ZIMKit().deleteAllMessage()" API to delete the conversation message history.

  2. Add the "ZIMKit().sendCustomMessage()" API to send custom message types, such as red envelope messages or exit group messages.

  3. Add the "messageContentBuilder" custom View callback. After receiving a CustomMessage, you can use the messageContentBuilder to customize the message body, or use the messageItemBuilder to completely redraw the item (message body + avatar + username).

  4. Add "ZIMKit().updateLocalExtendedData()" to update the localExtendedData of the message.


## 1.15.0

 - Support Group Management.

## 1.14.0

 - Add commonly used TextFiled parameters to ZIMKitMessageInput and ZIMKitMessageListPage.

## 1.13.4

- Fix the issue of setting the icon for offline notifications failure.

## 1.13.3

- fix deleteConversation isAlsoDeleteMessages issue.

## 1.13.2

- Update dependency.

## 1.13.1

- update log.

## 1.13.0

- support message notifications

## 1.12.0

- Added error code field to onMessageSent

## 1.11.1

- Update dependency.

## 1.11.0

- Support display nick name in group chat

## 1.10.1

- Optimization warnings from analysis

## 1.10.0

- Support offline push notification, configure it through the **notificationConfig** parameter in **ZIMKit().init()**.

## 1.9.4

- fix some issue.

## 1.9.3

- Optimization warnings from analysis

## 1.9.2

- update avatar radius

## 1.9.1

- Update video_player deps.

## 1.9.0

- support the following method: addUsersToGroup, removeUsersFromGroup, queryGroupMemberList, queryGroupMemberCount, queryGroupMemberInfo, disbandGroup, transferGroupOwner.

## 1.8.2

- fix onMessageSent issue.

## 1.8.1

- Update zim version to 2.10.0+4

## 1.8.0

- support messageListBackgroundBuilder; fix video player issue

## 1.7.0

- support recall message.

## 1.6.0

- Add `inputBackgroundDecoration`

## 1.5.0

- Add `sendButtonWidget`, `pickMediaButtonWidget`, `pickFileButtonWidget`, `inputFocusNode`

## 1.4.2

- Fix UI bugs.

## 1.4.1

- Update dependencies

## 1.4.0

- Add `getTotalUnreadMessageCount` api
- Add `getConnectionStateChangedEventStream` api
- Bug fix

## 1.3.1

- Update dependency

## 1.3.0

- Add `updateUserInfo` api.

## 1.2.0

- delete messages when call `deleteConversation`
- Add `deleteMessage` api
- Add `onMediaFilesPicked` callback

## 1.1.0

- support send image by network url.

## 1.0.0

- first release

## 0.9.8-prerelease

- publish pre-release version

## 0.0.1

- TODO: Describe initial release.
