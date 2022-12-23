import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/compnents/messages/widgets/widgets.dart';
import 'package:zego_zimkit/services/services.dart';

class ZIMKitMessageInput extends StatefulWidget {
  const ZIMKitMessageInput({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.onMessageSent,
    this.preMessageSending,
    this.editingController,
    this.showPickFileButton = true,
    this.actions = const [],
    this.inputDecoration,
    this.theme,
  }) : super(key: key);

  /// The conversationID of the conversation to send message.
  final String conversationID;

  /// The conversationType of the conversation to send message.
  final ZIMConversationType conversationType;

  /// By default, [ZIMKitMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

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

  /// Called when a message is sent.
  final void Function(ZIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use. if not provided, a default one will be created.
  final TextEditingController? editingController;

  // theme
  final ThemeData? theme;

  @override
  State<ZIMKitMessageInput> createState() => _ZIMKitMessageInputState();
}

class _ZIMKitMessageInputState extends State<ZIMKitMessageInput> {
  // TODO RestorableTextEditingController
  final TextEditingController _defaultEditingController =
      TextEditingController();
  TextEditingController get _editingController =>
      widget.editingController ?? _defaultEditingController;

  final ValueNotifier<bool> isTyping = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
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
              ...buildActions(ZIMKitMessageInputActionLocation.left),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    children: [
                      ...buildActions(
                          ZIMKitMessageInputActionLocation.leftInside),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) => sendTextMessage(),
                          controller: _editingController,
                          onChanged: (value) =>
                              isTyping.value = value.isNotEmpty,
                          decoration: widget.inputDecoration ??
                              const InputDecoration(hintText: 'Type message'),
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isTyping,
                        builder: (context, isTyping, child) {
                          return Builder(
                            builder: (context) {
                              if (isTyping) {
                                return Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.send,
                                        size: 16, color: Colors.white),
                                    onPressed: () async {
                                      sendTextMessage();
                                    },
                                  ),
                                );
                              } else {
                                return Row(
                                  children: [
                                    if (widget.showPickFileButton)
                                      ZIMKitPickFileButton(
                                        onFilePicked:
                                            (List<PlatformFile> files) {
                                          ZIMKit().sendMediaMessage(
                                            widget.conversationID,
                                            widget.conversationType,
                                            files,
                                            onMessageSent: widget.onMessageSent,
                                            preMessageSending:
                                                widget.preMessageSending,
                                          );
                                        },
                                      ),
                                    ...buildActions(
                                        ZIMKitMessageInputActionLocation
                                            .rightInside),
                                  ],
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ...buildActions(ZIMKitMessageInputActionLocation.right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendTextMessage() async {
    ZIMKit().sendTextMessage(
      widget.conversationID,
      widget.conversationType,
      _editingController.text,
      onMessageSent: widget.onMessageSent,
      preMessageSending: widget.preMessageSending,
    );
    _editingController.clear();
    isTyping.value = false;
    // TODO mac auto focus or not
    // TODO mobile auto focus or not
  }

  List<Widget> buildActions(ZIMKitMessageInputActionLocation location) {
    return widget.actions
            ?.where((element) => element.location == location)
            .map((e) => e.child)
            .toList() ??
        [];
  }
}

enum ZIMKitMessageInputActionLocation { left, right, leftInside, rightInside }

class ZIMKitMessageInputAction {
  const ZIMKitMessageInputAction(this.child,
      [this.location = ZIMKitMessageInputActionLocation.rightInside]);
  const ZIMKitMessageInputAction.left(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.left);
  const ZIMKitMessageInputAction.right(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.right);
  const ZIMKitMessageInputAction.leftInside(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.leftInside);
  const ZIMKitMessageInputAction.rightInside(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.rightInside);

  final Widget child;
  final ZIMKitMessageInputActionLocation location;
}
