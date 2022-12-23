part of 'services.dart';

mixin ZIMKitInputService {
  Future<List<PlatformFile>> pickFiles(
      {FileType type = FileType.any, bool allowMultiple = true}) async {
    try {
      requestPermission(Permission.storage);
      // see https://github.com/miguelpruivo/flutter_file_picker/wiki/API#-filepickerpickfiles
      return (await FilePicker.platform
                  .pickFiles(type: type, allowMultiple: allowMultiple))
              ?.files ??
          [];
    } on PlatformException catch (e) {
      ZIMKitLogger.severe('Unsupported operation $e');
    } catch (e) {
      ZIMKitLogger.severe(e.toString());
    }
    return [];
  }

  ZIMMessageType getMessageTypeByFileExtension(PlatformFile file) {
    const supportImageList = <String>[
      'jpg',
      'jpeg',
      'png',
      'bmp',
      'gif',
      'tiff'
    ]; // <10M
    const supportVideoList = <String>['mp4', 'mov']; // <100M
    const supportAudioList = <String>['mp3', 'm4a']; // <300s, <6M

    var messageType = ZIMMessageType.file;

    if (supportImageList.contains(file.extension)) {
      messageType = ZIMMessageType.image;
    } else if (supportVideoList.contains(file.extension)) {
      messageType = ZIMMessageType.video;
    } else if (supportAudioList.contains(file.extension)) {
      messageType = ZIMMessageType.audio;
    }

    // TODO check file limit
    return messageType;
  }

  Future<bool> requestPermission(Permission permission) async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }
    final status = await permission.request();
    if (status != PermissionStatus.granted) {
      ZIMKitLogger.severe(
          'Error: ${permission.toString()} permission not granted, $status');
      return false;
    }

    return true;
  }
}
