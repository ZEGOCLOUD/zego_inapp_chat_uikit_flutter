import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/services/services.dart';

// featureList
class ZIMKitMessageListView extends StatefulWidget {
  const ZIMKitMessageListView({
    Key? key,
    required this.conversationID,
    required this.scrollController,
    this.conversationType = ZIMConversationType.peer,
    this.onPressed,
    this.itemBuilder,
    this.messageContentBuilder,
    this.backgroundBuilder,
    this.loadingBuilder,
    this.onLongPress,
    this.errorBuilder,
    this.theme,
  }) : super(key: key);

  final String conversationID;
  final ZIMConversationType conversationType;

  final ScrollController scrollController;

  final void Function(
    BuildContext context,
    ZIMKitMessage message,
    Function defaultAction,
  )? onPressed;
  final void Function(
    BuildContext context,
    LongPressStartDetails details,
    ZIMKitMessage message,
    Function defaultAction,
  )? onLongPress;
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? itemBuilder;
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? messageContentBuilder;
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? errorBuilder;
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? loadingBuilder;
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? backgroundBuilder;

  // theme
  final ThemeData? theme;

  @override
  State<ZIMKitMessageListView> createState() => _ZIMKitMessageListViewState();
}

class _ZIMKitMessageListViewState extends State<ZIMKitMessageListView> {
  Completer? _loadMoreCompleter;
  final bottomOnLoadedNotifier = ValueNotifier<bool>(false);

  Widget get defaultLoadingWidget {
    const defaultWidget = Center(child: CircularProgressIndicator());

    // customWidget
    return widget.loadingBuilder?.call(context, defaultWidget) ?? defaultWidget;
  }

  @override
  void initState() {
    ZIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    widget.scrollController.addListener(scrollControllerListener);

    super.initState();
  }

  @override
  void dispose() {
    ZIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    widget.scrollController.removeListener(scrollControllerListener);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    bottomOnLoadedNotifier.value = false;

    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: FutureBuilder(
        future: ZIMKit().getMessageListNotifier(
          widget.conversationID,
          widget.conversationType,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder(
              valueListenable: snapshot.data! as ZIMKitMessageListNotifier,
              builder: (
                BuildContext context,
                List<ValueNotifier<ZIMKitMessage>> messageList,
                Widget? child,
              ) {
                ZIMKit().clearUnreadCount(
                  widget.conversationID,
                  widget.conversationType,
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  jumpToBottom();
                  bottomOnLoadedNotifier.value = true;
                });

                return listview(messageList);
              },
            );
          } else if (snapshot.hasError) {
            // TODO 未实现加载失败
            // defaultWidget
            final Widget defaultWidget = Center(
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
            return defaultLoadingWidget;
          }
        },
      ),
    );
  }

  void scrollToBottom() {
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void jumpToBottom() {
    widget.scrollController.jumpTo(
      widget.scrollController.position.maxScrollExtent,
    );
  }

  Future<void> scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (widget.scrollController.position.pixels >=
          0.8 * widget.scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 ==
            await ZIMKit().loadMoreMessage(
                widget.conversationID, widget.conversationType)) {
          widget.scrollController.removeListener(scrollControllerListener);
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  Widget listview(
    List<ValueNotifier<ZIMKitMessage>> messageList,
  ) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      DateTime previousDateTime = messageList.isEmpty
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(
              messageList[0].value.info.timestamp);
      DateTime nowDateTime = DateTime.now();

      return Stack(
        children: [
          SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: widget.backgroundBuilder?.call(
                  context,
                  const SizedBox.shrink(),
                ) ??
                const SizedBox.shrink(),
          ),
          ListView.builder(
            cacheExtent: constraints.maxHeight * 3,
            controller: widget.scrollController,
            itemCount: messageList.length,
            dragStartBehavior: DragStartBehavior.down,
            itemBuilder: (context, index) {
              final messageNotifier = messageList[index];

              return ValueListenableBuilder(
                valueListenable: messageNotifier,
                builder: (
                  BuildContext context,
                  ZIMKitMessage message,
                  Widget? child,
                ) {
                  final currentDatetime = DateTime.fromMillisecondsSinceEpoch(
                      message.info.timestamp);

                  final nowDuration = nowDateTime.difference(currentDatetime);
                  final previousDuration =
                      currentDatetime.difference(previousDateTime);
                  final isLastWeek = nowDuration.inDays > 7;
                  final isToday = nowDuration.inDays <= 1;
                  final isFiveMinutesBefore = previousDuration.inMinutes > 5;
                  final isSameDayAsPrevious = previousDuration.inDays.abs() < 1;
                  String formattedDateTime = '';
                  if (isToday) {
                    if (!isSameDayAsPrevious || isFiveMinutesBefore) {
                      formattedDateTime =
                          DateFormat('HH:mm').format(currentDatetime);
                    }
                  } else if (!isSameDayAsPrevious ||
                      0 == index ||
                      isFiveMinutesBefore) {
                    if (isLastWeek) {
                      formattedDateTime = DateFormat('yyyy/MM/dd HH:mm')
                          .format(currentDatetime);
                    } else {
                      /// in week
                      formattedDateTime =
                          DateFormat('EEEE HH:mm').format(currentDatetime);
                    }
                  }
                  previousDateTime = currentDatetime;

                  // defaultWidget
                  final defaultWidget = defaultMessageWidget(
                    message: message,
                    constraints: constraints,
                  );

                  return widget.itemBuilder?.call(
                        context,
                        message,
                        defaultWidget,
                      ) ??
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: formattedDateTime.isNotEmpty,
                            child: Container(
                              width: constraints.maxWidth,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  formattedDateTime,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          defaultWidget,
                        ],
                      );
                },
              );
            },
          ),
          scrollMask(constraints),
        ],
      );
    });
  }

  Widget scrollMask(BoxConstraints constraints) {
    return ValueListenableBuilder<bool>(
      valueListenable: bottomOnLoadedNotifier,
      builder: (context, bottomOnLoaded, _) {
        return Visibility(
          visible: !bottomOnLoaded,
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: widget.backgroundBuilder?.call(
                  context,
                  const SizedBox.shrink(),
                ) ??
                const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget defaultMessageWidget({
    required ZIMKitMessage message,
    required BoxConstraints constraints,
  }) {
    return SizedBox(
      width: constraints.maxWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: constraints.maxWidth,
          maxHeight: message.type == ZIMMessageType.text
              ? double.maxFinite
              : constraints.maxHeight * 0.5,
        ),
        child: ZIMKitMessageWidget(
          key: ValueKey(message.hashCode),
          message: message,
          onPressed: widget.onPressed,
          onLongPress: widget.onLongPress,
          messageContentBuilder: widget.messageContentBuilder,
        ),
      ),
    );
  }
}
