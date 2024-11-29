#import "ZegoUIKitZIMKitPlugin.h"

#import <UIKit/UIKit.h>

@implementation ZegoUIKitZIMKitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"zimkit_plugin"
            binaryMessenger:[registrar messenger]];
  ZegoUIKitZIMKitPlugin* instance = [[ZegoUIKitZIMKitPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"activeAudioByCallKit" isEqualToString:call.method]) {
    [self activeAudioByCallKit];
    result(nil);
  } else if ([@"isLockScreen" isEqualToString:call.method]) {
      result(@([UIScreen mainScreen].brightness == 0.0));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)activeAudioByCallKit {
    NSLog(@"activeAudioByCallKit");
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"activeAudioByCallKit error: %@", error.localizedDescription);
    }

    error = nil;
    [audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    if (error) {
        NSLog(@"activeAudioByCallKit error: %@", error.localizedDescription);
    }

    error = nil;
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"activeAudioByCallKit error: %@", error.localizedDescription);
    }
}

@end
