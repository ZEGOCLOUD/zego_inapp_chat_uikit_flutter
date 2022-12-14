import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_imkit/zego_imkit.dart';

class HomePagePopupMenuButton extends StatefulWidget {
  const HomePagePopupMenuButton({Key? key}) : super(key: key);

  @override
  State<HomePagePopupMenuButton> createState() =>
      _HomePagePopupMenuButtonState();
}

class _HomePagePopupMenuButtonState extends State<HomePagePopupMenuButton> {
  final userIDController = TextEditingController();
  final groupNameController = TextEditingController();
  final groupUsersController = TextEditingController();
  final groupIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      position: PopupMenuPosition.under,
      icon: const Icon(CupertinoIcons.add_circled),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'New Chat',
            child: const ListTile(
                leading: Icon(CupertinoIcons.chat_bubble_2_fill),
                title: Text('New Chat', maxLines: 1)),
            onTap: () => ZegoIMKit().showDefaultNewChatDialog(
                context: context, userIDController: userIDController),
          ),
          PopupMenuItem(
            value: 'New Group',
            child: const ListTile(
                leading: Icon(CupertinoIcons.person_2_fill),
                title: Text('New Group', maxLines: 1)),
            onTap: () => ZegoIMKit().showDefaultNewGroupDialog(
              context: context,
              groupNameController: groupNameController,
              groupUsersController: groupUsersController,
            ),
          ),
          PopupMenuItem(
            value: 'Join Group',
            child: const ListTile(
                leading: Icon(Icons.group_add),
                title: Text('Join Group', maxLines: 1)),
            onTap: () => ZegoIMKit().showDefaultJoinGroupDialog(
                context: context, groupIDController: groupIDController),
          ),
        ];
      },
    );
  }
}
