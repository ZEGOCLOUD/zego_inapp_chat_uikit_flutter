import 'dart:core';
import 'dart:math' as math;

class ZegoStringUtils {
  static final _random = math.Random();
  static const _defaultPool = 'ModuleSymbhasOwnPr-0123456789ABCDEFGHNRVfgctiUvz_KqYTJkLxpZXIjQW';

  static String createRandomString(int size, {String pool = _defaultPool}) {
    final len = pool.length;
    String id = '';
    while (0 < size--) {
      id += pool[_random.nextInt(len)];
    }
    return id;
  }

  static Future<String> createRandomStringAsync(int size, {String pool = _defaultPool}) async {
    return createRandomString(size, pool: pool);
  }
}

extension ZegoStringUtilsExtension on String {
  String get urlEncode {
    String copy = this;

    var detectHash = contains('#');
    var detectAnd = contains('&');
    var detectSlash = contains('/');

    if (detectHash == true) {
      copy = copy.replaceAll('#', '%23');
    }

    if (detectAnd == true) {
      copy = copy.replaceAll('#', '%26');
    }

    if (detectSlash == true) {
      copy = copy.replaceAll('#', '%2F');
    }
    return copy;
  }
}
