import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:zego_imkit/zego_imkit.dart';

export 'package:file_picker/file_picker.dart';

class ZegoIMKitPickFileButton extends StatelessWidget {
  const ZegoIMKitPickFileButton(
      {Key? key, required this.onFilePicked, this.icon})
      : super(key: key);

  final Function(List<PlatformFile> files) onFilePicked;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        ZegoIMKit()
            .pickFiles()
            .then((pickedFiles) => onFilePicked(pickedFiles));
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
