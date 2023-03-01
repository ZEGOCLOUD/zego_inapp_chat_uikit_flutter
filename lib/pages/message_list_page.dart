import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

class ZIMKitMessageListPage extends StatelessWidget {
  const ZIMKitMessageListPage({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.appBarBuilder,
    this.appBarActions,
    this.messageInputActions,
    this.onMessageSent,
    this.preMessageSending,
    this.inputDecoration,
    this.showPickFileButton = true,
    this.showPickMediaButton = true,
    this.editingController,
    this.messageListScrollController,
    this.onMessageItemPressd,
    this.onMessageItemLongPress,
    this.messageItemBuilder,
    this.messageListErrorBuilder,
    this.messageListLoadingBuilder,
    this.theme,
  }) : super(key: key);

  /// this page's conversationID
  final String conversationID;

  /// this page's conversationType
  final ZIMConversationType conversationType;

  /// if you just want add some actions to the appBar, use [appBarActions].
  ///
  /// use it like this:
  /// appBarActions:[
  ///   IconButton(icon: const Icon(Icons.local_phone), onPressed: () {}),
  ///   IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
  /// ],
  final List<Widget>? appBarActions;

  // if you want customize the appBar, use appBarBuilder return your custom appBar
  // if you don't want use appBar, return null
  final AppBar? Function(BuildContext context, AppBar defaultAppBar)?
      appBarBuilder;

  /// To add your own action, use the [messageInputActions] parameter like this:
  ///
  /// use [messageInputActions] like this to add your custom actions:
  ///
  /// actions: [
  ///   ZIMKitMessageInputAction.left(
  ///     IconButton(icon: Icon(Icons.mic), onPressed: () {})
  ///   ),
  ///   ZIMKitMessageInputAction.leftInside(
  ///     IconButton(icon: Icon(Icons.sentiment_satisfied_alt_outlined), onPressed: () {})
  ///   ),
  ///   ZIMKitMessageInputAction.rightInside(
  ///     IconButton(icon: Icon(Icons.cabin), onPressed: () {})
  ///   ),
  ///   ZIMKitMessageInputAction.right(
  ///     IconButton(icon: Icon(Icons.sd), onPressed: () {})
  ///   ),
  /// ],
  final List<ZIMKitMessageInputAction>? messageInputActions;

  /// Called when a message is sent.
  final void Function(ZIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending;

  /// By default, [ZIMKitMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

  /// By default, [ZIMKitMessageInput] will show a button to pick media.
  /// If you don't want to show this button, set [showPickMediaButton] to false.
  final bool showPickMediaButton;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use.
  /// if not provided, a default one will be created.
  final TextEditingController? editingController;

  /// The [ScrollController] to use.
  /// if not provided, a default one will be created.
  final ScrollController? messageListScrollController;

  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onMessageItemPressd;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onMessageItemLongPress;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      messageItemBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      messageListErrorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      messageListLoadingBuilder;

  // theme
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme ?? Theme.of(context),
      child: Scaffold(
        appBar: appBarBuilder != null
            ? appBarBuilder!.call(context, buildAppBar(context))
            : buildAppBar(context),
        body: Column(
          children: [
            ZIMKitMessageListView(
              key: ValueKey('ZIMKitMessageListView:${Object.hash(
                conversationID,
                conversationType,
              )}'),
              conversationID: conversationID,
              conversationType: conversationType,
              onPressed: onMessageItemPressd,
              itemBuilder: messageItemBuilder,
              onLongPress: onMessageItemLongPress,
              loadingBuilder: messageListLoadingBuilder,
              errorBuilder: messageListErrorBuilder,
              scrollController: messageListScrollController,
              theme: theme,
            ),
            ZIMKitMessageInput(
              key: ValueKey('ZIMKitMessageInput:${Object.hash(
                conversationID,
                conversationType,
              )}'),
              conversationID: conversationID,
              conversationType: conversationType,
              actions: messageInputActions,
              onMessageSent: onMessageSent,
              preMessageSending: preMessageSending,
              inputDecoration: inputDecoration,
              showPickFileButton: showPickFileButton,
              showPickMediaButton: showPickMediaButton,
              editingController: editingController,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: ValueListenableBuilder(
        valueListenable:
            ZIMKit().getConversation(conversationID, conversationType),
        builder: (context, ZIMKitConversation conversation, child) {
          return Row(
            children: [
              CircleAvatar(child: conversation.icon),
              child!,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.name,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.clip),
                  Text(conversation.id,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.clip)
                ],
              )
            ],
          );
        },
        child: const SizedBox(width: 20 * 0.75),
      ),
      actions: appBarActions,
    );
  }
}
