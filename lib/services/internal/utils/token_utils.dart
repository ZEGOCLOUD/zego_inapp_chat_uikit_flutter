import 'dart:convert';
import 'dart:core';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:zego_zimkit/services/internal/utils/hex_utils.dart';
import 'package:zego_zimkit/services/internal/utils/string_utils.dart';

class ZIMKitTokenUtils {
  static Future<String> generateZIMKitToken(
      int appid, String appSecret, String userID,
      {int effectiveTimeInSeconds = 60 * 60 * 24, String payload = ''}) async {
    if (appid == 0) {
      throw Exception('appid Invalid');
    }
    if (userID == '') {
      throw Exception('userID Invalid');
    }
    if (appSecret.length != 32) {
      throw Exception('appSecret Invalid');
    }
    if (effectiveTimeInSeconds <= 0) {
      throw Exception('effectiveTimeInSeconds Invalid');
    }
    final tokenInfo = TokenInfo04(
      appid: appid,
      userID: userID,
      nonce: math.Random().nextInt(math.pow(2, 31).toInt()),
      ctime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      expire: 0,
      payload: payload,
    );
    tokenInfo.expire = tokenInfo.ctime + effectiveTimeInSeconds;
    // Convert token information to json
    final tokenJson = tokenInfo.toJson();

    // Randomly generated 16-byte string, used as AES encryption vector,
    // before the ciphertext for Base64 encoding to generate the final token
    final ivStr = ZIMKitStringUtils.createRandomString(16);
    final iv = encrypt.IV.fromUtf8(ivStr);

    final key = encrypt.Key.fromUtf8(appSecret);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(tokenJson, iv: iv);

    final bytes1 = HexUtils.createUint8ListFromInt(tokenInfo.expire);
    final bytes2 = Uint8List.fromList([0, 16]);
    final bytes3 = Uint8List.fromList(utf8.encode(ivStr));
    final bytes4 = Uint8List.fromList([0, encrypted.bytes.length]);
    final bytes5 = encrypted.bytes;

    final bytes = Uint8List(4) + bytes1 + bytes2 + bytes3 + bytes4 + bytes5;
    final ret = '04${base64.encode(bytes)}';
    return ret;
  }
}

class TokenInfo04 {
  TokenInfo04(
      {required this.appid,
      required this.userID,
      required this.ctime,
      required this.expire,
      required this.nonce,
      required this.payload});
  int appid;
  String userID;
  int nonce;
  int ctime;
  int expire;
  String payload;

  String toJson() {
    return '{"app_id":$appid,"user_id":"$userID","nonce":$nonce,"ctime":$ctime,"expire":$expire,"payload":"$payload"}';
  }
}
