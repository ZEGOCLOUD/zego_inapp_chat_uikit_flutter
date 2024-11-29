import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitAvatar extends StatelessWidget {
  const ZIMKitAvatar({
    Key? key,
    required this.userID,
    this.name = '',
    this.height,
    this.width,
  }) : super(key: key);
  final String userID;
  final String name;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 40,
      height: height ?? 40,
      child: FutureBuilder(
        // TODO auto update user's avatar
        future: ZIMKit().queryUser(userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data! as ZIMUserFullInfo).icon;
          } else {
            return CircleAvatar(
                child: Text(name.isNotEmpty ? name[0] : userID[0]));
          }
        },
      ),
    );
  }
}
