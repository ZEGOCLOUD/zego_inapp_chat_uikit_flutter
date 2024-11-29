package com.zegocloud.uikit.zimkit_plugin.notification;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.zegocloud.uikit.zimkit_plugin.Defines;

public class ClickReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i("zimkit plugin", "click receiver, Received broadcast " + intent.getAction());
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }
}
