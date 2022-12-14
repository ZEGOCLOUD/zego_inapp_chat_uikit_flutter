import 'dart:core';
import 'dart:typed_data';

class HexUtils {
  /// Creates a `Uint8List` by a hex string.
  static Uint8List createUint8ListFromHexString(String hex) {
    var result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      var num = hex.substring(i, i + 2);
      var byte = int.parse(num, radix: 16);
      result[i ~/ 2] = byte;
    }

    return result;
  }

  /// Returns a hex string by a `Uint8List`.
  static String formatBytesAsHexString(Uint8List bytes) {
    var result = StringBuffer();
    for (var i = 0; i < bytes.lengthInBytes; i++) {
      var part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }

    return result.toString();
  }

  static Uint8List createUint8ListFromInt(int hex) {
    return createUint8ListFromHexString(hex.toRadixString(16));
  }
}

class ZegoTokenInfo04 {
  int appid;
  String userID;
  int nonce;
  int ctime;
  int expire;
  String payload;

  String toJson() {
    return '{"app_id":$appid,"user_id":"$userID","nonce":$nonce,"ctime":$ctime,"expire":$expire,"payload":"$payload"}';
  }

  ZegoTokenInfo04(
      {required this.appid,
      required this.userID,
      required this.ctime,
      required this.expire,
      required this.nonce,
      required this.payload});
}
