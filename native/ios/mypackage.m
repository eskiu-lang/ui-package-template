// <mypackage> on iOS: UIDevice's battery monitoring. Its notifications report each change;
// the reports go to the "mypackage" channel (src/mypackage.esk).
#import "ui_native.h"

static id levelObserver, stateObserver;

static void report(void) {
    UIDevice *device = UIDevice.currentDevice;
    // -1 when the device does not say (the simulator).
    int level = device.batteryLevel < 0 ? -1 : (int)lroundf(device.batteryLevel * 100);
    UIDeviceBatteryState state = device.batteryState;
    int charging = state == UIDeviceBatteryStateCharging || state == UIDeviceBatteryStateFull;
    char payload[64];
    snprintf(payload, sizeof payload, "battery %d %d", level, charging);
    ui_native_emit("mypackage", payload);
}

void mypackage_start(void) {
    UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    levelObserver = [center addObserverForName:UIDeviceBatteryLevelDidChangeNotification object:nil queue:NSOperationQueue.mainQueue
                                    usingBlock:^(NSNotification *note) { report(); }];
    stateObserver = [center addObserverForName:UIDeviceBatteryStateDidChangeNotification object:nil queue:NSOperationQueue.mainQueue
                                    usingBlock:^(NSNotification *note) { report(); }];
    report();
}

void mypackage_stop(void) {
    if (levelObserver) [NSNotificationCenter.defaultCenter removeObserver:levelObserver];
    if (stateObserver) [NSNotificationCenter.defaultCenter removeObserver:stateObserver];
    levelObserver = stateObserver = nil;
    UIDevice.currentDevice.batteryMonitoringEnabled = NO;
}
