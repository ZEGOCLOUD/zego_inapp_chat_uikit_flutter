import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

export 'package:file_picker/file_picker.dart';

class ZIMKitPickFileButton extends StatelessWidget {
  const ZIMKitPickFileButton({Key? key, required this.onFilePicked, this.icon})
      : super(key: key);

  final Function(List<PlatformFile> files) onFilePicked;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        ZIMKit().pickFiles().then(onFilePicked);
      },
      icon: icon ??
          Icon(
            Icons.attach_file,
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
          ),
    );
  }
}
