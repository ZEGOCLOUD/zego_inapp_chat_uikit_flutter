import 'package:flutter/services.dart';

/// @nodoc
class ZegoZIMKitPluginLocalNotificationConfig {
  const ZegoZIMKitPluginLocalNotificationConfig({
    required this.channelID,
    required this.title,
    required this.content,
    this.id,
    this.iconSource,
    this.soundSource,
    this.vibrate = false,
    this.clickCallback,
  });

  final int? id;
  final String? iconSource;
  final String? soundSource;
  final String channelID;
  final String title;
  final String content;
  final bool vibrate;
  final VoidCallback? clickCallback;

  @override
  String toString() {
    return 'id:$id, icon source:$iconSource, sound source:$soundSource, '
        'vibrate:$vibrate, channel id:$channelID, title:$title, content:$content';
  }
}

/// @nodoc
class ZegoZIMKitPluginLocalNotificationChannelConfig {
  const ZegoZIMKitPluginLocalNotificationChannelConfig({
    this.soundSource,
    this.vibrate = false,
    required this.channelID,
    required this.channelName,
  });

  final String? soundSource;
  final String channelID;
  final String channelName;
  final bool vibrate;

  @override
  String toString() {
    return 'sound source:$soundSource, vibrate:$vibrate, channel id:$channelID, channel name:$channelName';
  }
}
