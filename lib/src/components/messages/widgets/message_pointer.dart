import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/defines.dart';
import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitTextMessagePointer extends StatelessWidget {
  final ZIMKitMessageType messageType;
  final bool isMine;

  const ZIMKitTextMessagePointer({
    Key? key,
    required this.messageType,
    required this.isMine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isMine ? 0 : messagePointerWidth / 2,
        top: 0,
        right: isMine ? messagePointerWidth / 2 : 0,
        bottom: 0,
      ),
      width: messagePointerWidth,
      height: messagePointerWidth,
      child: CustomPaint(
        painter: ZIMKitMessageTrianglePainter(
          color: Theme.of(context).primaryColor.withOpacity(isMine ? 1 : 0.1),
          isMine: isMine,
        ),
      ),
    );
  }
}

class ZIMKitMessageTrianglePainter extends CustomPainter {
  final Color color;
  final bool isMine;

  ZIMKitMessageTrianglePainter({required this.color, required this.isMine});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();
    if (isMine) {
      path
        ..moveTo(size.width, size.height / 2)
        ..lineTo(0, 0)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(0, size.height / 2)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ZIMKitMessageTrianglePainter oldDelegate) {
    return color != oldDelegate.color || isMine != oldDelegate.isMine;
  }
}
