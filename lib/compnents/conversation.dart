import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:badges/badges.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitConversationWidget extends StatefulWidget {
  const ZIMKitConversationWidget({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    required this.onPressed,
    this.lastMessageTimeBuilder,
    this.lastMessageBuilder,
    required this.onLongPress,
  }) : super(key: key);

  final String conversationID;
  final ZIMConversationType conversationType;

  // ui builder
  final Widget Function(
          BuildContext context, DateTime? messageTime, Widget defaultWidget)?
      lastMessageTimeBuilder;
  final Widget Function(
          BuildContext context, ZIMMessage? message, Widget defaultWidget)?
      lastMessageBuilder;

  // event
  final Function(BuildContext context) onPressed;
  final Function(
          BuildContext context, LongPressDownDetails longPressDownDetails)
      onLongPress;

  @override
  State<ZIMKitConversationWidget> createState() =>
      _ZIMKitConversationWidgetState();
}

class _ZIMKitConversationWidgetState extends State<ZIMKitConversationWidget> {
  late LongPressDownDetails _longPressDownDetails;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: ZIMKit()
            .getConversation(widget.conversationID, widget.conversationType)
            .data,
        builder: (context, ZIMConversation conversation, child) {
          return GestureDetector(
            onTap: () => widget.onPressed(context),
            onLongPressDown: (longPressDownDetails) =>
                _longPressDownDetails = longPressDownDetails,
            onLongPress: () =>
                widget.onLongPress(context, _longPressDownDetails),
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: min(screenWidth / 10, 20), vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Badge(
                      showBadge: conversation.unreadMessageCount != 0,
                      badgeContent: Text('${conversation.unreadMessageCount}'),
                      animationType: BadgeAnimationType.scale,
                      animationDuration: const Duration(milliseconds: 150),
                      child: SizedBox(
                          width: 50, height: 50, child: conversation.icon),
                    ),
                    if (screenWidth >= 100)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation.name.isNotEmpty
                                    ? conversation.name
                                    : conversation.id,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(height: 8),
                              Builder(builder: (context) {
                                final defaultWidget = defaultlastMessageBuilder(
                                    conversation.lastMessage);
                                return widget.lastMessageBuilder?.call(
                                        context,
                                        conversation.lastMessage,
                                        defaultWidget) ??
                                    defaultWidget;
                              }),
                            ],
                          ),
                        ),
                      ),
                    if (screenWidth >= 250)
                      Builder(builder: (context) {
                        final messageTime = conversation.lastMessage != null
                            ? DateTime.fromMillisecondsSinceEpoch(
                                conversation.lastMessage!.timestamp)
                            : null;
                        final defaultWidget =
                            defaultlastMessageTimeBuilder(messageTime);
                        return widget.lastMessageTimeBuilder
                                ?.call(context, messageTime, defaultWidget) ??
                            defaultWidget;
                      }),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget defaultlastMessageBuilder(ZIMMessage? message) {
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: 0.64,
      child:
          Text(message.tostr(), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget defaultlastMessageTimeBuilder(DateTime? messageTime) {
    if (messageTime == null) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final duration = DateTime.now().difference(messageTime);

    late String timeStr;

    if (duration.inMinutes < 1) {
      timeStr = 'just now';
    } else if (duration.inHours < 1) {
      timeStr = '${duration.inMinutes} minutes ago';
    } else if (duration.inDays < 1) {
      timeStr = '${duration.inHours} hours ago';
    } else if (now.year == messageTime.year) {
      timeStr =
          '${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    } else {
      timeStr =
          ' ${messageTime.year}/${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    }

    return Opacity(
        opacity: 0.64,
        child: Text(timeStr, maxLines: 1, overflow: TextOverflow.clip));
  }
}
