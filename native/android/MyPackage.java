// <mypackage> on Android: the sticky ACTION_BATTERY_CHANGED broadcast, received while a
// component uses it. mypackage.c calls start and stop from Eskiu; the reports go to the
// "mypackage" channel (src/mypackage.esk).
package org.eskiu.mypackage;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import org.eskiu.ui.UiActivity;

public final class MyPackage {
    private static BroadcastReceiver receiver;

    // Runs before the app starts; register views or listeners here.
    public static void setup() {}

    public static void start() {
        Activity activity = UiActivity.current();
        if (activity == null) return;
        activity.runOnUiThread(() -> {
            if (receiver != null) return;
            receiver = new BroadcastReceiver() {
                @Override public void onReceive(Context context, Intent intent) {
                    int level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
                    int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
                    int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
                    int percent = level >= 0 && scale > 0 ? Math.round(level * 100f / scale) : -1;
                    boolean charging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL;
                    UiActivity.emit("mypackage", "battery " + percent + " " + (charging ? 1 : 0));
                }
            };
            // Sticky: the current state arrives at once, then each change.
            activity.registerReceiver(receiver, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        });
    }

    public static void stop() {
        Activity activity = UiActivity.current();
        if (activity == null) return;
        activity.runOnUiThread(() -> {
            if (receiver == null) return;
            activity.unregisterReceiver(receiver);
            receiver = null;
        });
    }
}
