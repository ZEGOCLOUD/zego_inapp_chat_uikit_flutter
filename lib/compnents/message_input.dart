import 'dart:async';

import 'package:flutter/material.dart';

import '../services/services.dart';
import 'messages/widgets/widgets.dart';

class ZegoMessageInput extends StatefulWidget {
  const ZegoMessageInput({
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

  /// By default, [ZegoMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

  /// To add your own action, use the [actions] parameter like this:
  ///
  /// use [actions] like this to add your custom actions:
  ///
  /// actions: [
  ///   ZegoMessageInputAction.left(IconButton(
  ///     icon: Icon(
  ///       Icons.mic,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZegoMessageInputAction.leftInside(IconButton(
  ///     icon: Icon(
  ///       Icons.sentiment_satisfied_alt_outlined,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZegoMessageInputAction.rightInside(IconButton(
  ///     icon: Icon(
  ///       Icons.cabin,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZegoMessageInputAction.right(IconButton(
  ///     icon: Icon(
  ///       Icons.sd,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  /// ],
  final List<ZegoMessageInputAction>? actions;

  /// Called when a message is sent.
  final void Function(ZegoIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZegoIMKitMessage> Function(ZegoIMKitMessage)? preMessageSending;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use. if not provided, a default one will be created.
  final TextEditingController? editingController;

  // theme
  final ThemeData? theme;

  @override
  State<ZegoMessageInput> createState() => _ZegoMessageInputState();
}

class _ZegoMessageInputState extends State<ZegoMessageInput> {
  // TODO RestorableTextEditingController
  final TextEditingController _defaultEditingController = TextEditingController();
  TextEditingController get _editingController => widget.editingController ?? _defaultEditingController;

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
              ...buildActions(ZegoMessageInputActionLocation.left),
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
                      ...buildActions(ZegoMessageInputActionLocation.leftInside),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) => sendTextMessage(),
                          controller: _editingController,
                          onChanged: (value) => isTyping.value = value.isNotEmpty,
                          decoration: widget.inputDecoration ?? const InputDecoration(hintText: 'Type message'),
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
                                    icon: const Icon(Icons.send, size: 16, color: Colors.white),
                                    onPressed: () async {
                                      sendTextMessage();
                                    },
                                  ),
                                );
                              } else {
                                return Row(
                                  children: [
                                    if (widget.showPickFileButton)
                                      ZegoIMKitPickFileButton(
                                        onFilePicked: (List<PlatformFile> files) {
                                          ZegoIMKit().sendMediaMessage(
                                            widget.conversationID,
                                            widget.conversationType,
                                            files,
                                            onMessageSent: widget.onMessageSent,
                                            preMessageSending: widget.preMessageSending,
                                          );
                                        },
                                      ),
                                    ...buildActions(ZegoMessageInputActionLocation.rightInside),
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
              ...buildActions(ZegoMessageInputActionLocation.right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendTextMessage() async {
    ZegoIMKit().sendTextMessage(
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

  List<Widget> buildActions(ZegoMessageInputActionLocation location) {
    return widget.actions?.where((element) => element.location == location).map((e) => e.child).toList() ?? [];
  }
}

enum ZegoMessageInputActionLocation { left, right, leftInside, rightInside }

class ZegoMessageInputAction {
  const ZegoMessageInputAction.left(Widget child) : this(child, ZegoMessageInputActionLocation.left);
  const ZegoMessageInputAction.right(Widget child) : this(child, ZegoMessageInputActionLocation.right);
  const ZegoMessageInputAction.leftInside(Widget child) : this(child, ZegoMessageInputActionLocation.leftInside);
  const ZegoMessageInputAction.rightInside(Widget child) : this(child, ZegoMessageInputActionLocation.rightInside);
  const ZegoMessageInputAction(this.child, [this.location = ZegoMessageInputActionLocation.rightInside]);

  final Widget child;
  final ZegoMessageInputActionLocation location;
}
