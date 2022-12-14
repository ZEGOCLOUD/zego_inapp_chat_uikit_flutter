import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_imkit/zego_imkit.dart';

class ZegoMessageListPage extends StatelessWidget {
  const ZegoMessageListPage({
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
  ///   ZegoMessageInputAction.left(
  ///     IconButton(icon: Icon(Icons.mic), onPressed: () {})
  ///   ),
  ///   ZegoMessageInputAction.leftInside(
  ///     IconButton(icon: Icon(Icons.sentiment_satisfied_alt_outlined), onPressed: () {})
  ///   ),
  ///   ZegoMessageInputAction.rightInside(
  ///     IconButton(icon: Icon(Icons.cabin), onPressed: () {})
  ///   ),
  ///   ZegoMessageInputAction.right(
  ///     IconButton(icon: Icon(Icons.sd), onPressed: () {})
  ///   ),
  /// ],
  final List<ZegoMessageInputAction>? messageInputActions;

  /// Called when a message is sent.
  final void Function(ZegoIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage)?
      preMessageSending;

  /// By default, [ZegoMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use. if not provided, a default one will be created.
  final TextEditingController? editingController;

  /// The [ScrollController] to use. if not provided, a default one will be created.
  final ScrollController? messageListScrollController;

  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onMessageItemPressd;
  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onMessageItemLongPress;
  final Widget Function(
          BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)?
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
            ZegoMessageListView(
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
            ZegoMessageInput(
              conversationID: conversationID,
              conversationType: conversationType,
              actions: messageInputActions,
              onMessageSent: onMessageSent,
              preMessageSending: preMessageSending,
              inputDecoration: inputDecoration,
              showPickFileButton: showPickFileButton,
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
            ZegoIMKit().getConversation(conversationID, conversationType).data,
        builder: (context, ZIMConversation conversation, child) {
          return Row(
            children: [
              CircleAvatar(child: conversation.icon),
              child!,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.name, style: const TextStyle(fontSize: 16)),
                  Text(conversation.id, style: const TextStyle(fontSize: 12))
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
