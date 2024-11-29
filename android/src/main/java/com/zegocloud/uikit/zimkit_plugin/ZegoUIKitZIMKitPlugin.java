package com.zegocloud.uikit.zimkit_plugin;

import android.app.ActivityManager;
import android.content.Context;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.app.KeyguardManager;
import android.os.PowerManager;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.zegocloud.uikit.zimkit_plugin.notification.PluginNotification;

import java.util.List;

/**
 * ZegoUIKitZIMKitPlugin
 */
public class ZegoUIKitZIMKitPlugin extends BroadcastReceiver implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private Context context;
    private ActivityPluginBinding activityBinding;
    private PluginNotification notification;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("zimkit plugin", "onAttachedToEngine");

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zimkit_plugin");
        methodChannel.setMethodCallHandler(this);

        notification = new PluginNotification();

        context = flutterPluginBinding.getApplicationContext();

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Defines.ACTION_CLICK);
        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(context);
        manager.registerReceiver(this, intentFilter);

        Log.d("zimkit plugin", "android VERSION.RELEASE: " + Build.VERSION.RELEASE);
        Log.d("zimkit plugin", "android VERSION.SDK_INT: " + Build.VERSION.SDK_INT);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.d("zimkit plugin", "onMethodCall: " + call.method);

        if (call.method.equals(Defines.FLUTTER_API_FUNC_ADD_LOCAL_NOTIFICATION)) {
            String title = call.argument(Defines.FLUTTER_PARAM_TITLE);
            String content = call.argument(Defines.FLUTTER_PARAM_CONTENT);
            String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
            String iconSource = call.argument(Defines.FLUTTER_PARAM_ICON_SOURCE);
            String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
            String notificationId = call.argument(Defines.FLUTTER_PARAM_ID);
            Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

            notification.addLocalNotification(context, title, content, channelID, soundSource, iconSource, notificationId, isVibrate);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_CREATE_NOTIFICATION_CHANNEL)) {
            String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
            String channelName = call.argument(Defines.FLUTTER_PARAM_CHANNEL_NAME);
            String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
            Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

            notification.createNotificationChannel(context, channelID, channelName, soundSource, isVibrate);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_DISMISS_ALL_NOTIFICATIONS)) {
            notification.dismissAllNotifications(context);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_ACTIVE_APP_TO_FOREGROUND)) {
            notification.activeAppToForeground(context);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_REQUEST_DISMISS_KEYGUARD)) {
            notification.requestDismissKeyguard(context, activityBinding.getActivity());

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_IS_LOCK_SCREEN)) {
            result.success(isLockScreen());
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d("zimkit plugin", "onDetachedFromEngine");
        methodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        Log.d("zimkit plugin", "onAttachedToActivity");
        activityBinding = activityPluginBinding;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        Log.d("zimkit plugin", "onReattachedToActivityForConfigChanges");
        activityBinding = activityPluginBinding;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d("zimkit plugin", "onDetachedFromActivityForConfigChanges");
        activityBinding = null;
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d("zimkit plugin", "onDetachedFromActivity");
        activityBinding = null;
    }

    // BroadcastReceiver by other classes.
    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            String action = intent.getAction();
            Log.d("zimkit plugin", "onReceive action, " + String.format("%s", action));

            switch (action) {
                case Defines.ACTION_CLICK:
                    onBroadcastNotificationClicked(intent);
                    break;
                default:
                    Log.d("zimkit plugin", "onReceive, Received unknown action: " + (StringUtils.isNullOrEmpty(action) ? "empty" : action));
            }
        } catch (Exception e) {
            Log.d("zimkit plugin", "onReceive exception, " + String.format("%s", e.getMessage()));
            e.printStackTrace();
        }
    }

    private void onBroadcastNotificationClicked(Intent intent) {
        Log.d("zimkit plugin", "onBroadcastNotificationIMClicked");
        methodChannel.invokeMethod(Defines.ACTION_CLICK_CB_FUNC, null);
    }
    public Boolean isLockScreen() {
        Log.i("uikit plugin", "isLockScreen");

        KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
        boolean inKeyguardRestrictedInputMode = keyguardManager.inKeyguardRestrictedInputMode();

        boolean isLocked;
        if (inKeyguardRestrictedInputMode) {
            isLocked = true;
        } else {
            PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                isLocked = !powerManager.isInteractive();
            } else {
                isLocked = !powerManager.isScreenOn();
            }
        }

        return isLocked;
    }
}