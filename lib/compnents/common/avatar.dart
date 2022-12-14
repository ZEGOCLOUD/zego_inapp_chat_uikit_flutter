import 'package:flutter/material.dart';
import 'package:zego_imkit/services/services.dart';

class ZegoIMKitAvatar extends StatelessWidget {
  const ZegoIMKitAvatar(
      {Key? key, required this.userID, this.height, this.width})
      : super(key: key);
  final String userID;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder(
        // TODO auto update user's avatar
        future: ZegoIMKit().queryUser(userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data as ZIMUserFullInfo).icon;
          } else {
            return const Icon(Icons.person);
          }
        },
      ),
    );
  }
}
