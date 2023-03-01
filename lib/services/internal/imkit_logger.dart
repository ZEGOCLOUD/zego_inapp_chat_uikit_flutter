part of 'imkit_core.dart';

/*
  usage:
  ZIMKitLogger.init()
  ZIMKitLogger.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });


  ZIMKitLogger.finest('finest');
  ZIMKitLogger.finer('finer');
  ZIMKitLogger.fine('fine');
  ZIMKitLogger.info('info');
  ZIMKitLogger.warning('warning');
  ZIMKitLogger.severe('severe');
  ZIMKitLogger.shout('shout');
*/

class ZIMKitLogger {
  static final logger = Logger.detached('ZIMKit');

  static void init({Level logLevel = Level.ALL, bool enablePrint = true}) {
    logger.level = logLevel;
    if (enablePrint) {
      logger.onRecord.listen((LogRecord e) {
        // use `dumpErrorToConsole` for severe messages to ensure that severe
        // exceptions are formatted consistently with other Flutter examples and
        // avoids printing duplicate exceptions
        if (e.level >= Level.SEVERE) {
          final error = e.error;
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(
              exception: error is Exception ? error : Exception(error),
              stack: e.stackTrace,
              library: e.loggerName,
              context: ErrorDescription(e.message),
            ),
          );
        } else {
          developer.log(
            e.message,
            time: e.time,
            sequenceNumber: e.sequenceNumber,
            level: e.level.value,
            name: e.loggerName,
            zone: e.zone,
            error: e.error,
            stackTrace: e.stackTrace,
          );
        }
      });
    }
  }

  static void uninit() {
    logger.level = Level.OFF;
  }

  Stream<LogRecord> get onRecord {
    return logger.onRecord;
  }

  // temp log
  static void finest(Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    logger.finest(message, error, stackTrace);
  }

  // trace
  static void finer(Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    logger.finer(message, error, stackTrace);
  }

  // debug
  static void fine(Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    logger.fine(message, error, stackTrace);
  }

  // info
  static void info(Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    logger.info(message, error, stackTrace);
  }

  // warning
  static void warning(Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    logger.warning(message, error, stackTrace);
  }

  // error
  static void severe(Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    logger.severe(message, error, stackTrace);
  }

  // fatal
  static void shout(BuildContext context, Object? message,
      [Object? error, StackTrace? stackTrace, Zone? zone]) {
    final ctrl = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('[ZIMKit]:${message.toString()}')));
    Future.delayed(const Duration(seconds: 3), ctrl.close);
    logger.shout(message, error, stackTrace);
  }
}
