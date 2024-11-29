import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/defines.dart';

class ZIMKitMoreButton extends StatelessWidget {
  const ZIMKitMoreButton({
    Key? key,
    required this.buttons,
    this.icon,
    this.padding = const EdgeInsets.all(32.0),
  }) : super(key: key);

  final Widget? icon;
  final List<Widget> buttons;
  final EdgeInsetsGeometry padding;

  double get rowHeight => 40;

  double get rowPadding => 10;

  double get columnPadding => 10;

  int get rowCount => 4;

  int get maxRowCount => 2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int rows = (buttons.length + 3) ~/ 4;
        rows = rows > 2 ? 2 : rows;

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: rowPadding * (maxRowCount - 1) +
                    rowHeight * maxRowCount +
                    padding.vertical * maxRowCount,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: padding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowCount,
                        childAspectRatio: 1.0,
                        // column spacing
                        mainAxisSpacing: rowPadding,
                        // row spacing
                        crossAxisSpacing: columnPadding,
                      ),
                      itemCount: buttons.length,
                      itemBuilder: (context, index) {
                        return buttons[index];
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: icon ??
          Icon(
            Icons.add,
            size: ZIMKitMessageStyle.iconSize,
            color:
                Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
          ),
    );
  }
}
