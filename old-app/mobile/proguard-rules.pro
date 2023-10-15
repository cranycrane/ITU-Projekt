# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /home/lukas/Android_SDK/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# ButterKnife
-dontwarn butterknife.internal.**
-keep class **$$ViewInjector { *; }
-keepnames class * { @butterknife.InjectView *;}

# Otto
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.squareup.otto.Subscribe public *;
    @com.squareup.otto.Produce public *;
}

# OkHttp + Picasso
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

# Okio
-dontwarn okio.**

# Retrofit
-keep class retrofit.** { *; }
-keepclassmembers class * {
    @retrofit.** *;
}

-dontwarn retrofit.**
-keep class retrofit.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# RxAndroid
-dontwarn rx.**

# Google Play Services
-keep class * extends java.util.ListResourceBundle {
	protected Object[][] getContents();
}
-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
	public static final *** NULL;
}
-keepnames @com.google.android.gms.common.annotation.KeepName class *
-keepclassmembernames class * {
	@com.google.android.gms.common.annotation.KeepName *;
}
-keepnames class * implements android.os.Parcelable {
	public static final ** CREATOR;
}

# Crashlytics / Fabric
-keepattributes SourceFile,LineNumberTable

# Facebook
-keep class com.facebook.** { *; }

# ActiveAndroid
-keep class com.activeandroid.** { *; }
-keep class com.activeandroid.**.** { *; }
-keep class * extends com.activeandroid.Model
-keep class * extends com.activeandroid.serializer.TypeSerializer

# GSON
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
#-keep class com.google.gson.stream.** { *; }
-keep public class com.google.gson
-keep class com.thefuntasty.flowlist.model.** { *; }

-keep class com.pnikosis { *; }
-dontwarn com.pnikosis.**

-keep class fr.baloomba { *; }
-dontwarn fr.baloomba.**

-dontwarn com.viewpagerindicator.LinePageIndicator

# Duplicate class https://code.google.com/p/android/issues/detail?id=194513
-dontnote android.net.http.*
-dontnote org.apache.commons.codec.**
-dontnote org.apache.http.**