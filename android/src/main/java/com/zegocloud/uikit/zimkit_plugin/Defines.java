package com.zegocloud.uikit.zimkit_plugin;

public interface Defines {
    String FLUTTER_API_FUNC_ADD_LOCAL_NOTIFICATION = "addLocalNotification";
    String FLUTTER_API_FUNC_CREATE_NOTIFICATION_CHANNEL = "createNotificationChannel";
    String FLUTTER_API_FUNC_DISMISS_ALL_NOTIFICATIONS = "dismissAllNotifications";
    String FLUTTER_API_FUNC_ACTIVE_APP_TO_FOREGROUND = "activeAppToForeground";
    String FLUTTER_API_FUNC_REQUEST_DISMISS_KEYGUARD = "requestDismissKeyguard";

    String FLUTTER_PARAM_TITLE = "title";
    String FLUTTER_PARAM_CONTENT = "content";
    String FLUTTER_PARAM_CHANNEL_ID = "channel_id";
    String FLUTTER_PARAM_CHANNEL_NAME = "channel_name";
    String FLUTTER_PARAM_SOUND_SOURCE = "sound_source";
    String FLUTTER_PARAM_ICON_SOURCE = "icon_source";
    String FLUTTER_PARAM_ID = "id";
    String FLUTTER_PARAM_VIBRATE = "vibrate";

    String ACTION_CLICK = "ACTION_CLICK";
    String ACTION_CLICK_CB_FUNC = "onNotificationClicked";
    String FLUTTER_API_FUNC_IS_LOCK_SCREEN = "isLockScreen";
}
