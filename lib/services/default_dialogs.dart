part of 'services.dart';

mixin ZegoDefaultDialogService {
  void showDefaultNewChatDialog(
      {required BuildContext context,
      required TextEditingController userIDController}) {
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Chat'),
              content: TextField(
                maxLines: 1,
                controller: userIDController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User ID',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      ).then((ok) {
        if (ok != true) return;
        if (userIDController.text.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ZegoMessageListPage(
              conversationID: userIDController.text,
              conversationType: ZIMConversationType.peer,
            );
          }));
        }
      });
    });
  }

  void showDefaultNewGroupDialog({
    required BuildContext context,
    required TextEditingController groupNameController,
    required TextEditingController groupUsersController,
  }) {
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Group'),
              content: Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      maxLines: 1,
                      controller: groupNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Group Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: 3,
                      controller: groupUsersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Invite User ID',
                        hintText: 'separate by comma, e.g. 123,456,789',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      ).then((bool? ok) {
        if (ok != true) return;
        if (groupNameController.text.isNotEmpty &&
            groupUsersController.text.isNotEmpty) {
          ZegoIMKit()
              .createGroup(groupNameController.text,
                  groupUsersController.text.split(','))
              .then((String? conversationID) {
            if (conversationID != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ZegoMessageListPage(
                  conversationID: conversationID,
                  conversationType: ZIMConversationType.group,
                );
              }));
            }
          });
        }
      });
    });
  }

  void showDefaultJoinGroupDialog({
    required BuildContext context,
    required TextEditingController groupIDController,
  }) {
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Join Group'),
              content: Flexible(
                child: TextField(
                  maxLines: 1,
                  controller: groupIDController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Group ID',
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        },
      ).then((bool? ok) {
        if (ok != true) return;
        if (groupIDController.text.isNotEmpty) {
          ZegoIMKit().joinGroup(groupIDController.text).then((int errorCode) {
            if (errorCode == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ZegoMessageListPage(
                  conversationID: groupIDController.text,
                  conversationType: ZIMConversationType.group,
                );
              }));
            }
          });
        }
      });
    });
  }
}
