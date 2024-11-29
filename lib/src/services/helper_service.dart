part of 'zimkit_services.dart';

mixin ZIMKitHelperService {
  void registerAppLifecycleStateChangedListener(
      ZegoPluginAdapterMessageHandler listener) {
    ZegoPluginAdapter().service().registerMessageHandler(listener);
  }

  void unregisterAppLifecycleStateChangedListener(
      ZegoPluginAdapterMessageHandler listener) {
    ZegoPluginAdapter().service().unregisterMessageHandler(listener);
  }

  Future<bool> isAppLocked() async {
    return await ZegoZIMKitPluginPlatform.instance.isLockScreen();
  }
}
