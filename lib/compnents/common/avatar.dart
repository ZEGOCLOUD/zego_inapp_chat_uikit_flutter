import 'package:flutter/material.dart';

import 'package:zego_zimkit/services/services.dart';

class ZIMKitAvatar extends StatelessWidget {
  const ZIMKitAvatar({
    Key? key,
    required this.userID,
    this.height,
    this.width,
  }) : super(key: key);
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
        future: ZIMKit().queryUser(userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data! as ZIMUserFullInfo).icon;
          } else {
            return const Icon(Icons.person);
          }
        },
      ),
    );
  }
}
