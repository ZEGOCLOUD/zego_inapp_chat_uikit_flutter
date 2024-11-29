import 'package:zego_zim/zego_zim.dart';

class ZIMKitMessageUtils {
  static ZIMMediaMessage mediaMessageFactory(
    String path,
    ZIMMessageType messageType, {
    int audioDuration = 0,
  }) {
    ZIMMediaMessage mediaMessage;

    switch (messageType) {
      case ZIMMessageType.image:
        mediaMessage = ZIMImageMessage(path);
        break;
      case ZIMMessageType.video:
        mediaMessage = ZIMVideoMessage(path);
        break;
      case ZIMMessageType.audio:
        var audioMessage = ZIMAudioMessage(path);
        audioMessage.audioDuration = audioDuration;
        mediaMessage = audioMessage;
        break;
      case ZIMMessageType.file:
        mediaMessage = ZIMFileMessage(path);
        break;
      default:
        throw UnimplementedError();
    }
    return mediaMessage;
  }
}
