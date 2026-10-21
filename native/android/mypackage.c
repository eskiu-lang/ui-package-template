// <mypackage> on Android: the externs Eskiu calls, into MyPackage (Java) through JNI.
#include <jni.h>
#include "ui_native.h"

static void call(const char *method) {
    JNIEnv *env = ui_jni_env();
    jclass type = ui_find_class("org.eskiu.mypackage.MyPackage");
    if (!type) return;
    (*env)->CallStaticVoidMethod(env, type, (*env)->GetStaticMethodID(env, type, method, "()V"));
    (*env)->DeleteLocalRef(env, type);
}

void mypackage_start(void) { call("start"); }

void mypackage_stop(void) { call("stop"); }
