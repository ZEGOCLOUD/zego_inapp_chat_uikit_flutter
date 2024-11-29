import 'dart:async';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/events/events.dart';
import 'package:zego_zimkit/src/services/services.dart';

/// if your text flows is right to left:
///
/// ``` dart
/// Directionality(
///   textDirection: TextDirection.rtl,
///   child: ZIMKitMessageListPage(
///
///   ),
/// );
/// ```
class ZIMKitMessageListPage extends StatefulWidget {
  const ZIMKitMessageListPage({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.appBarBuilder,
    this.appBarActions,
    this.messageInputActions,
    this.onMessageSent,
    this.events,
    this.preMessageSending,
    this.messageInputHeight,
    this.inputDecoration,
    this.showPickFileButton = true,
    this.showPickMediaButton = true,
    this.showMoreButton = true,
    this.showRecordButton = true,
    this.editingController,
    this.messageListScrollController,
    this.onMessageItemPressed,
    this.onMessageItemLongPress,
    this.messageItemBuilder,
    this.messageContentBuilder,
    this.messageListErrorBuilder,
    this.messageListLoadingBuilder,
    this.messageListBackgroundBuilder,
    this.theme,
    this.onMediaFilesPicked,
    this.sendButtonWidget,
    this.pickMediaButtonWidget,
    this.pickFileButtonWidget,
    this.inputFocusNode,
    this.inputBackgroundDecoration,
    this.messageInputContainerPadding,
    this.messageInputContainerDecoration,
    this.messageInputKeyboardType,
    this.messageInputMaxLines,
    this.messageInputMinLines,
    this.messageInputTextInputAction,
    this.messageInputTextCapitalization,
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

  /// events.
  final ZIMKitMessageListPageEvents? events;

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

  /// By default, [ZIMKitMessageInput] will show a button to pop more.
  /// If you don't want to show this button, set [showMoreButton] to false.
  final bool showMoreButton;

  /// By default, [ZIMKitMessageInput] will show a button to record.
  /// If you don't want to show this button, set [showRecordButton] to false.
  final bool showRecordButton;

  ///
  final double? messageInputHeight;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use.
  /// if not provided, a default one will be created.
  final TextEditingController? editingController;

  /// The [ScrollController] to use.
  /// if not provided, a default one will be created.
  final ScrollController? messageListScrollController;

  /// The default config is
  /// ```dart
  /// const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
  /// ```
  final EdgeInsetsGeometry? messageInputContainerPadding;

  /// The default config is
  /// ```dart
  /// BoxDecoration(
  ///   color: Theme.of(context).scaffoldBackgroundColor,
  ///   boxShadow: [
  ///     BoxShadow(
  ///       offset: const Offset(0, 4),
  ///       blurRadius: 32,
  ///       color: Theme.of(context).primaryColor.withOpacity(0.15),
  ///     ),
  ///   ],
  /// )
  /// ```
  final Decoration? messageInputContainerDecoration;

  /// default is TextInputType.multiline
  final TextInputType? messageInputKeyboardType;

  // default is 3
  final int? messageInputMaxLines;

  // default is 1
  final int? messageInputMinLines;

  // default is TextInputAction.newline
  final TextInputAction? messageInputTextInputAction;

  // default is TextCapitalization.sentences
  final TextCapitalization? messageInputTextCapitalization;

  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onMessageItemPressed;
  final void Function(BuildContext context, LongPressStartDetails details,
      ZIMKitMessage message, Function defaultAction)? onMessageItemLongPress;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      messageItemBuilder;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      messageContentBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      messageListErrorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      messageListLoadingBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      messageListBackgroundBuilder;

  final void Function(BuildContext context, List<PlatformFile> files,
      Function defaultAction)? onMediaFilesPicked;

  // theme
  final ThemeData? theme;

  final Widget? sendButtonWidget;

  final Widget? pickMediaButtonWidget;

  final Widget? pickFileButtonWidget;

  final FocusNode? inputFocusNode;

  final BoxDecoration? inputBackgroundDecoration;

  @override
  State<ZIMKitMessageListPage> createState() => _ZIMKitMessageListPageState();
}

/// @nodoc
class _ZIMKitMessageListPageState extends State<ZIMKitMessageListPage> {
  final recordProcessor = ZIMKitRecordStatus();

  final defaultInputFocusNode = FocusNode();
  final defaultListScrollController = ScrollController();

  FocusNode get inputFocusNode =>
      widget.inputFocusNode ?? defaultInputFocusNode;

  ScrollController get listScrollController =>
      widget.messageListScrollController ?? defaultListScrollController;

  @override
  void initState() {
    super.initState();

    recordProcessor.register();
  }

  @override
  void dispose() {
    super.dispose();

    recordProcessor.unregister();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: Scaffold(
        appBar: widget.appBarBuilder?.call(context, buildAppBar(context)) ??
            buildAppBar(context),
        body: SafeArea(
          child: Stack(
            children: [
              messageListView(),
              messageInput(),
              messageRecordLocker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageRecordLocker() {
    return Positioned(
      bottom: widget.messageInputHeight ?? ZIMKitMessageStyle.height - 5,
      right: 5,
      child: SizedBox(
        width: ZIMKitRecordStyle.lockerIconSize,
        height: ZIMKitRecordStyle.lockerIconSize,
        child: ZIMKitRecordLocker(
          processor: recordProcessor,
        ),
      ),
    );
  }

  Widget messageListView() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: widget.messageInputHeight ?? ZIMKitMessageStyle.height,
      child: ZIMKitMessageListView(
        key: ValueKey(
          'ZIMKitMessageListView:${Object.hash(
            widget.conversationID,
            widget.conversationType,
          )}',
        ),
        conversationID: widget.conversationID,
        conversationType: widget.conversationType,
        onPressed: widget.onMessageItemPressed,
        itemBuilder: widget.messageItemBuilder,
        messageContentBuilder: widget.messageContentBuilder,
        onLongPress: widget.onMessageItemLongPress,
        loadingBuilder: widget.messageListLoadingBuilder,
        errorBuilder: widget.messageListErrorBuilder,
        scrollController: listScrollController,
        theme: widget.theme,
        backgroundBuilder: widget.messageListBackgroundBuilder,
      ),
    );
  }

  Widget messageInput() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: widget.messageInputHeight ?? ZIMKitMessageStyle.height,
        child: ZIMKitMessageInput(
          key: ValueKey(
            'ZIMKitMessageInput:${Object.hash(
              widget.conversationID,
              widget.conversationType,
            )}',
          ),
          events: widget.events,
          recordStatus: recordProcessor,
          conversationID: widget.conversationID,
          conversationType: widget.conversationType,
          actions: widget.messageInputActions,
          onMessageSent: widget.onMessageSent,
          preMessageSending: widget.preMessageSending,
          inputDecoration: widget.inputDecoration,
          showPickFileButton: widget.showPickFileButton,
          showPickMediaButton: widget.showPickMediaButton,
          showRecordButton: widget.showRecordButton,
          showMoreButton: widget.showMoreButton,
          editingController: widget.editingController,
          listScrollController: listScrollController,
          theme: widget.theme,
          onMediaFilesPicked: widget.onMediaFilesPicked,
          sendButtonWidget: widget.sendButtonWidget,
          pickMediaButtonWidget: widget.pickMediaButtonWidget,
          pickFileButtonWidget: widget.pickFileButtonWidget,
          inputFocusNode: inputFocusNode,
          inputBackgroundDecoration: widget.inputBackgroundDecoration,
          containerPadding: widget.messageInputContainerPadding,
          containerDecoration: widget.messageInputContainerDecoration,
          keyboardType: widget.messageInputKeyboardType,
          maxLines: widget.messageInputMaxLines,
          minLines: widget.messageInputMinLines,
          textInputAction: widget.messageInputTextInputAction,
          textCapitalization: widget.messageInputTextCapitalization,
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: ValueListenableBuilder<ZIMKitConversation>(
        valueListenable: ZIMKit().getConversation(
          widget.conversationID,
          widget.conversationType,
        ),
        builder: (context, conversation, child) {
          const avatarNameFontSize = 16.0;
          return Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: conversation.icon,
              ),
              child!,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: const TextStyle(
                      fontSize: avatarNameFontSize,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                  // Text(conversation.id,
                  //     style: const TextStyle(fontSize: 12),
                  //     overflow: TextOverflow.clip)
                ],
              )
            ],
          );
        },
        child: const SizedBox(width: 20 * 0.75),
      ),
      actions: widget.appBarActions,
    );
  }
}
