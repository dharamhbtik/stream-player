# Add project specific ProGuard rules here.

# Keep better_player classes
-keep class com.jhomlala.better_player.** { *; }

# Keep ExoPlayer classes
-keep class com.google.android.exoplayer2.** { *; }

# Keep Hive classes
-keep class io.hive.** { *; }
-keep class hive.** { *; }

# Keep Dio classes
-keep class io.flutter.plugins.** { *; }

# Keep Google Mobile Ads classes
-keep class com.google.android.gms.ads.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent R8 from leaving Data.toString()
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
