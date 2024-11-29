import 'dart:async';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/events/events.dart';
import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitMessageInput extends StatefulWidget {
  const ZIMKitMessageInput({
    Key? key,
    required this.conversationID,
    required this.recordStatus,
    this.conversationType = ZIMConversationType.peer,
    this.onMessageSent,
    this.events,
    this.preMessageSending,
    this.editingController,
    this.showPickFileButton = true,
    this.showPickMediaButton = true,
    this.showMoreButton = true,
    this.showRecordButton = true,
    this.actions = const [],
    this.inputDecoration,
    this.theme,
    this.onMediaFilesPicked,
    this.sendButtonWidget,
    this.pickMediaButtonWidget,
    this.pickFileButtonWidget,
    this.inputFocusNode,
    this.inputBackgroundDecoration,
    this.containerPadding,
    this.containerDecoration,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.textCapitalization,
    this.listScrollController,
  }) : super(key: key);

  /// The conversationID of the conversation to send message.
  final String conversationID;

  /// The conversationType of the conversation to send message.
  final ZIMConversationType conversationType;

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

  /// To add your own action, use the [actions] parameter like this:
  ///
  /// use [actions] like this to add your custom actions:
  ///
  /// actions: [
  ///   ZIMKitMessageInputAction.left(IconButton(
  ///     icon: Icon(
  ///       Icons.mic,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMKitMessageInputAction.leftInside(IconButton(
  ///     icon: Icon(
  ///       Icons.sentiment_satisfied_alt_outlined,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMKitMessageInputAction.rightInside(IconButton(
  ///     icon: Icon(
  ///       Icons.cabin,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMKitMessageInputAction.right(IconButton(
  ///     icon: Icon(
  ///       Icons.sd,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  /// ],
  final List<ZIMKitMessageInputAction>? actions;

  /// events
  final ZIMKitMessageListPageEvents? events;

  /// Called when a message is sent.
  final void Function(ZIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending;

  final void Function(BuildContext context, List<PlatformFile> files,
      Function defaultAction)? onMediaFilesPicked;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use. if not provided, a default one will be created.
  final TextEditingController? editingController;

  final ScrollController? listScrollController;

  // theme
  final ThemeData? theme;

  final Widget? sendButtonWidget;

  final Widget? pickMediaButtonWidget;

  final Widget? pickFileButtonWidget;

  final FocusNode? inputFocusNode;

  final BoxDecoration? inputBackgroundDecoration;

  /// The default config is
  /// ```dart
  /// const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
  /// ```
  final EdgeInsetsGeometry? containerPadding;

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
  final Decoration? containerDecoration;

  /// default is TextInputType.multiline
  final TextInputType? keyboardType;

  // default is 3
  final int? maxLines;

  // default is 1
  final int? minLines;

  // default is TextInputAction.newline
  final TextInputAction? textInputAction;

  // default is TextCapitalization.sentences
  final TextCapitalization? textCapitalization;

  final ZIMKitRecordStatus recordStatus;

  @override
  State<ZIMKitMessageInput> createState() => _ZIMKitMessageInputState();
}

class _ZIMKitMessageInputState extends State<ZIMKitMessageInput> {
  // TODO RestorableTextEditingController
  final TextEditingController _defaultEditingController =
      TextEditingController();

  TextEditingController get _editingController =>
      widget.editingController ?? _defaultEditingController;

  @override
  void initState() {
    super.initState();

    widget.inputFocusNode?.addListener(onInputFocusChanged);
  }

  @override
  void dispose() {
    super.dispose();

    widget.inputFocusNode?.removeListener(onInputFocusChanged);
    widget.inputFocusNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: Container(
        padding: widget.containerPadding ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
        decoration: widget.containerDecoration ??
            BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 32,
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                ),
              ],
            ),
        child: SafeArea(
          child: Row(
            children: [
              ValueListenableBuilder<ZIMKitRecordState>(
                valueListenable: widget.recordStatus.stateNotifier,
                builder: (context, recordState, _) {
                  return recordState == ZIMKitRecordState.idle
                      ? messageWidgets()
                      : ZIMKitRecordCancelSlider(
                          status: widget.recordStatus,
                          sendButtonWidget: widget.sendButtonWidget,
                          onMessageSent: onMessageSent,
                          preMessageSending: onMessagePreSend,
                        );
                },
              ),
              const SizedBox(width: 5),
              recordButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageWidgets() {
    return Expanded(
      child: Row(
        children: [
          ...buildActions(ZIMKitMessageInputActionLocation.left),
          moreButton(),
          const SizedBox(width: 5),
          contentWidgets(),
          ...buildActions(ZIMKitMessageInputActionLocation.right)
        ],
      ),
    );
  }

  Widget contentWidgets() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: widget.inputBackgroundDecoration ??
            BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
            ),
        child: Row(
          children: [
            ...buildActions(
              ZIMKitMessageInputActionLocation.leftInside,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                keyboardType: widget.keyboardType ?? TextInputType.multiline,
                maxLines: widget.maxLines ?? 3,
                minLines: widget.minLines ?? 1,
                textInputAction:
                    widget.textInputAction ?? TextInputAction.newline,
                textCapitalization:
                    widget.textCapitalization ?? TextCapitalization.sentences,
                focusNode: widget.inputFocusNode,
                onTap: () {
                  // jumpListToBottom();

                  widget.events?.onTextFieldTap?.call();
                },
                onSubmitted: (value) => sendTextMessage(),
                controller: _editingController,
                decoration: widget.inputDecoration ??
                    const InputDecoration(hintText: 'type message...'),
              ),
            ),
            messageButtons(),
          ],
        ),
      ),
    );
  }

  Widget messageButtons() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _editingController,
      builder: (context, textEditingValue, child) {
        return Builder(
          builder: (context) {
            if (textEditingValue.text.isNotEmpty || rightInsideActionsIsEmpty) {
              return sendButton(textEditingValue.text);
            } else {
              return Row(
                children: [
                  pickMediaButton(),
                  pickFileButton(),
                  ...buildActions(
                    ZIMKitMessageInputActionLocation.rightInside,
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget pickFileButton() {
    if (!widget.showPickFileButton) {
      return Container();
    }

    return SizedBox(
      height: ZIMKitMessageStyle.iconSize,
      width: ZIMKitMessageStyle.iconSize,
      child: ZIMKitPickFileButton(
        icon: widget.pickFileButtonWidget,
        onFilePicked: (
          List<PlatformFile> files,
        ) {
          void defaultAction() {
            ZIMKit().sendFileMessage(
              widget.conversationID,
              widget.conversationType,
              files,
              onMessageSent: onMessageSent,
              preMessageSending: onMessagePreSend,
            );
          }

          if (widget.onMediaFilesPicked != null) {
            widget.onMediaFilesPicked!(context, files, defaultAction);
          } else {
            defaultAction();
          }
        },
      ),
    );
  }

  Widget pickMediaButton() {
    if (!widget.showPickMediaButton) {
      return Container();
    }

    return SizedBox(
      height: ZIMKitMessageStyle.iconSize,
      width: ZIMKitMessageStyle.iconSize,
      child: ZIMKitPickMediaButton(
        icon: widget.pickMediaButtonWidget,
        onFilePicked: (
          List<PlatformFile> files,
        ) {
          void defaultAction() {
            ZIMKit().sendMediaMessage(
              widget.conversationID,
              widget.conversationType,
              files,
              onMessageSent: onMessageSent,
              preMessageSending: onMessagePreSend,
            );
          }

          if (widget.onMediaFilesPicked != null) {
            widget.onMediaFilesPicked!(
              context,
              files,
              defaultAction,
            );
          } else {
            defaultAction();
          }
        },
      ),
    );
  }

  Widget moreButton() {
    if (!widget.showMoreButton) {
      return Container();
    }

    return SizedBox(
      height: ZIMKitMessageStyle.iconSize,
      width: ZIMKitMessageStyle.iconSize,
      child: ZIMKitMoreButton(
        buttons: widget.actions
                ?.where((element) =>
                    element.location == ZIMKitMessageInputActionLocation.more)
                .map((e) => e.child)
                .toList() ??
            [],
      ),
    );
  }

  Widget recordButton() {
    if (!widget.showRecordButton) {
      return Container();
    }

    return SizedBox(
      height: ZIMKitMessageStyle.iconSize,
      width: ZIMKitMessageStyle.iconSize,
      child: ZIMKitRecordButton(
        status: widget.recordStatus,
        conversationID: widget.conversationID,
        conversationType: widget.conversationType,
        onMessageSent: onMessageSent,
        preMessageSending: onMessagePreSend,
        events: widget.events,
      ),
    );
  }

  Widget sendButton(String text) {
    return Container(
      height: ZIMKitMessageStyle.iconSize,
      width: ZIMKitMessageStyle.iconSize,
      decoration: widget.sendButtonWidget == null
          ? BoxDecoration(
              color: text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.6),
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: widget.sendButtonWidget ??
            const Icon(Icons.send, size: 16, color: Colors.white),
        onPressed: text.isNotEmpty ? sendTextMessage : null,
      ),
    );
  }

  Future<void> sendTextMessage() async {
    ZIMKit().sendTextMessage(
      widget.conversationID,
      widget.conversationType,
      _editingController.text,
      onMessageSent: onMessageSent,
      preMessageSending: onMessagePreSend,
    );
    _editingController.clear();
    // TODO mac auto focus or not
    // TODO mobile auto focus or not
  }

  List<Widget> buildActions(ZIMKitMessageInputActionLocation location) {
    return widget.actions
            ?.where((element) => element.location == location)
            .map(
              (e) => SizedBox(
                height: ZIMKitMessageStyle.iconSize,
                width: ZIMKitMessageStyle.iconSize,
                child: e.child,
              ),
            )
            .toList() ??
        [];
  }

  void onInputFocusChanged() {
    if (widget.inputFocusNode?.hasFocus ?? false) {
      // jumpListToBottom();
    }
  }

  void jumpListToBottom() {
    if (widget.listScrollController?.hasClients ?? false) {
      Future.delayed(Duration(milliseconds: 500), () {
        widget.listScrollController?.jumpTo(
          (widget.listScrollController?.position.maxScrollExtent ?? 0),
        );
      });
    }
  }

  void onMessageSent(ZIMKitMessage message) {
    widget.onMessageSent?.call(message);

    // jumpListToBottom();
  }

  Future<ZIMKitMessage> onMessagePreSend(ZIMKitMessage message) async {
    await widget.preMessageSending?.call(message);

    jumpListToBottom();

    return message;
  }

  bool get rightInsideActionsIsEmpty =>
      (widget.actions
              ?.where((element) =>
                  element.location ==
                  ZIMKitMessageInputActionLocation.rightInside)
              .isEmpty ??
          true) &&
      !widget.showPickFileButton &&
      !widget.showPickMediaButton;
}

enum ZIMKitMessageInputActionLocation {
  left,
  right,
  leftInside,
  rightInside,
  more,
}

class ZIMKitMessageInputAction {
  const ZIMKitMessageInputAction(
    this.child, [
    this.location = ZIMKitMessageInputActionLocation.rightInside,
  ]);

  const ZIMKitMessageInputAction.left(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.left,
        );

  const ZIMKitMessageInputAction.right(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.right,
        );

  const ZIMKitMessageInputAction.leftInside(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.leftInside,
        );

  const ZIMKitMessageInputAction.rightInside(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.rightInside,
        );

  const ZIMKitMessageInputAction.more(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.more,
        );

  final Widget child;
  final ZIMKitMessageInputActionLocation location;
}
