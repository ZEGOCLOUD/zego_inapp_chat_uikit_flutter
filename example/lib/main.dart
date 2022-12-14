import 'package:flutter/material.dart';
import 'package:zego_imkit/zego_imkit.dart';
import 'login_page.dart';

void main() {
  ZegoIMKit().init(
    appID: , // your appid
    appSign: '', // your appSign
  );
  runApp(const ZegoIMKitDemo());
}

class ZegoIMKitDemo extends StatelessWidget {
  const ZegoIMKitDemo({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zego IMKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ZegoIMKitDemoLoginPage(),
    );
  }
}
