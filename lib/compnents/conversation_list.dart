import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zego_imkit/zego_imkit.dart';

export 'conversation_list.dart';

class ZegoConversationListView extends StatefulWidget {
  const ZegoConversationListView({
    Key? key,
    this.filter,
    this.sorter,
    this.onPressed,
    this.onLongPress,
    this.itemBuilder,
    this.lastMessageTimeBuilder,
    this.lastMessageBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.scrollController,
    this.theme,
  }) : super(key: key);

  // logic function
  final List<ZegoIMKitConversation> Function(
      BuildContext context, List<ZegoIMKitConversation>)? filter;
  final List<ZegoIMKitConversation> Function(
      BuildContext context, List<ZegoIMKitConversation>)? sorter;

  // item event
  final void Function(BuildContext context, ZegoIMKitConversation conversation,
      Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitConversation conversation,
      Function defaultAction)? onLongPress;

  // ui builder
  final Widget Function(BuildContext context, Widget defaultWidget)?
      errorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      emptyBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      loadingBuilder;

  // item ui builder
  final Widget Function(
          BuildContext context, DateTime? messageTime, Widget defaultWidget)?
      lastMessageTimeBuilder;
  final Widget Function(
          BuildContext context, ZIMMessage? message, Widget defaultWidget)?
      lastMessageBuilder;

  // item builder
  final Widget Function(BuildContext context,
      ZegoIMKitConversation conversation, Widget defaultWidget)? itemBuilder;

  // scroll controller
  final ScrollController? scrollController;

  // theme
  final ThemeData? theme;

  @override
  State<ZegoConversationListView> createState() =>
      _ZegoConversationListViewState();
}

class _ZegoConversationListViewState extends State<ZegoConversationListView> {
  final ScrollController _defaultScrollController = ScrollController();
  ScrollController get _scrollController =>
      widget.scrollController ?? _defaultScrollController;
  Completer? _loadMoreCompleter;
  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  void scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >=
          0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 == await ZegoIMKit().loadMoreConversation()) {
          _scrollController.removeListener(scrollControllerListener);
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: FutureBuilder(
        future: ZegoIMKit().getConversationListNotifier(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder(
              valueListenable:
                  snapshot.data as ValueNotifier<List<ZegoIMKitConversation>>,
              builder: (BuildContext context,
                  List<ZegoIMKitConversation> conversationList, Widget? child) {
                conversationList =
                    widget.sorter?.call(context, conversationList) ??
                        conversationList;
                conversationList =
                    widget.filter?.call(context, conversationList) ??
                        conversationList;
                return LayoutBuilder(
                  builder: (context, BoxConstraints constraints) {
                    return ListView.builder(
                      cacheExtent: constraints.maxHeight * 3,
                      controller: _scrollController,
                      itemCount: conversationList.length,
                      itemBuilder: (context, index) {
                        var conversation = conversationList[index];
                        // defaultAction

                        // defaultWidget
                        Widget defaultWidget = ZegoConversationWidget(
                          conversationID: conversationList[index].id,
                          conversationType: conversationList[index].type,
                          lastMessageTimeBuilder: widget.lastMessageTimeBuilder,
                          lastMessageBuilder: widget.lastMessageBuilder,
                          onLongPress: (BuildContext context,
                              LongPressDownDetails longPressDownDetails) {
                            onLongPressDefaultAction() =>
                                _onLongPressDefaultAction(
                                    context,
                                    longPressDownDetails,
                                    conversation.id,
                                    conversation.type);
                            if (widget.onLongPress != null) {
                              widget.onLongPress!(
                                  context,
                                  conversationList[index],
                                  onLongPressDefaultAction);
                            } else {
                              onLongPressDefaultAction();
                            }
                          },
                          onPressed: (BuildContext context) {
                            onPressedDefaultAction() {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ZegoMessageListPage(
                                    conversationID: conversation.id,
                                    conversationType: conversation.type,
                                    theme: widget.theme,
                                  );
                                },
                              ));
                            }

                            if (widget.onPressed != null) {
                              widget.onPressed!(
                                  context,
                                  conversationList[index],
                                  onPressedDefaultAction);
                            } else {
                              onPressedDefaultAction();
                            }
                          },
                        );

                        // customWidget
                        return widget.itemBuilder?.call(context,
                                conversationList[index], defaultWidget) ??
                            defaultWidget;
                      },
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            // defaultWidget
            Widget defaultWidget = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const Text('Load failed, please click to retry'),
                ],
              ),
            );

            // customWidget
            return GestureDetector(
              onTap: () => setState(() {}),
              child: widget.errorBuilder?.call(context, defaultWidget) ??
                  defaultWidget,
            );
          } else {
            // defaultWidget
            Widget defaultWidget =
                const Center(child: CircularProgressIndicator());

            // customWidget
            return widget.loadingBuilder?.call(context, defaultWidget) ??
                defaultWidget;
          }
        },
      ),
    );
  }

  void _onLongPressDefaultAction(
      context, LongPressDownDetails longPressDownDetails, id, type) {
    final RenderBox conversationBox = context.findRenderObject()! as RenderBox;
    var offset = conversationBox
        .localToGlobal(Offset(0, conversationBox.size.height / 2));
    final RelativeRect position = RelativeRect.fromLTRB(
      longPressDownDetails.globalPosition.dx,
      offset.dy,
      longPressDownDetails.globalPosition.dx,
      offset.dy,
    );

    showMenu(context: context, position: position, items: [
      const PopupMenuItem(value: 0, child: Text('Delete')),
      if (type == ZIMConversationType.group)
        const PopupMenuItem(value: 1, child: Text('Quit'))
    ]).then((value) {
      switch (value) {
        case 0:
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Do you want to delete this conversation?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ZegoIMKit().deleteConversation(id, type);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
        case 1:
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Do you want to leave this group?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ZegoIMKit().leaveGroup(id);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
      }
    });
  }
}
