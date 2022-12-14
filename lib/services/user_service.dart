part of 'services.dart';

mixin ZegoUserService {
  Future<int> login({required String id, String name = ''}) async {
    return await ZegoIMKitCore.instance.login(id: id, name: name);
  }

  Future<void> logout() async {
    return await ZegoIMKitCore.instance.logout();
  }

  ZIMUserFullInfo? currentUser() {
    return ZegoIMKitCore.instance.coreData.loginUser;
  }

  Future<ZIMUserFullInfo> queryUser(String id) async {
    return await ZegoIMKitCore.instance.coreData.queryUser(id);
  }
}
