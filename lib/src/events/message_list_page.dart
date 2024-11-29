import 'audio_record.dart';
import 'package:flutter/material.dart';

class ZIMKitMessageListPageEvents {
  ZIMKitMessageListPageEvents({
    this.audioRecord,
    this.onTextFieldTap,
  });

  ZIMKitAudioRecordEvents? audioRecord;

  final VoidCallback? onTextFieldTap;
}
