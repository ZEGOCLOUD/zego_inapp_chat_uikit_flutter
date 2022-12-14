import 'dart:async';

import 'package:flutter/material.dart';

import '../zego_imkit.dart';

// featureList
class ZegoMessageListView extends StatefulWidget {
  const ZegoMessageListView({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.onPressed,
    this.itemBuilder,
    this.loadingBuilder,
    this.onLongPress,
    this.errorBuilder,
    this.scrollController,
    this.theme,
  }) : super(key: key);

  final String conversationID;
  final ZIMConversationType conversationType;

  final ScrollController? scrollController;

  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitMessage message,
      Function defaultAction)? onLongPress;
  final Widget Function(
          BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)?
      itemBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      errorBuilder;
  final Widget Function(BuildContext context, Widget defaultWidget)?
      loadingBuilder;

  // theme
  final ThemeData? theme;

  @override
  State<ZegoMessageListView> createState() => _ZegoMessageListViewState();
}

class _ZegoMessageListViewState extends State<ZegoMessageListView> {
  final ScrollController _defaultScrollController = ScrollController();
  ScrollController get _scrollController =>
      widget.scrollController ?? _defaultScrollController;

  Completer? _loadMoreCompleter;
  @override
  void initState() {
    ZegoIMKit()
        .clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.addListener(scrollControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    ZegoIMKit()
        .clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  void scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >=
          0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 ==
            await ZegoIMKit().loadMoreMessage(
                widget.conversationID, widget.conversationType)) {
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
      child: Expanded(
        child: FutureBuilder(
          future: ZegoIMKit().getMessageListNotifier(
              widget.conversationID, widget.conversationType),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ValueListenableBuilder(
                valueListenable:
                    snapshot.data as ValueNotifier<List<ZegoIMKitMessage>>,
                builder: (BuildContext context,
                    List<ZegoIMKitMessage> messageList, Widget? child) {
                  ZegoIMKit().clearUnreadCount(
                      widget.conversationID, widget.conversationType);
                  return LayoutBuilder(
                      builder: (context, BoxConstraints constraints) {
                    ZegoIMKitLogger.fine(
                        'messageList constraints: $constraints');
                    return ListView.builder(
                      cacheExtent: constraints.maxHeight * 3,
                      reverse: true,
                      controller: _scrollController,
                      itemCount: messageList.length,
                      itemBuilder: (context, index) {
                        int reversedIndex = messageList.length - index - 1;
                        ZegoIMKitMessage message = messageList[reversedIndex];
                        // defaultWidget
                        Widget defaultWidget = ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                            maxHeight: constraints.maxHeight * 0.5,
                          ),
                          child: ZegoIMKitMessageWidget(
                            key: ValueKey(message.hashCode),
                            message: message,
                            onPressed: widget.onPressed,
                            onLongPress: widget.onLongPress,
                          ),
                        );
                        // TODO spacing
                        // TODO 时间间隔
                        // customWidget
                        return widget.itemBuilder
                                ?.call(context, message, defaultWidget) ??
                            defaultWidget;
                      },
                    );
                  });
                },
              );
            } else if (snapshot.hasError) {
              // TODO 未实现加载失败
              // defaultWidget
              Widget defaultWidget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    Text(snapshot.error.toString()),
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
      ),
    );
  }
}
