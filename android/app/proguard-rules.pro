# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter embedding classes
-keep class io.flutter.embedding.** { *; }

# Keep Google Play Core classes (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep all classes that might be referenced by Flutter
-keep class * extends java.lang.Exception

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep model classes (adjust package name as needed)
-keep class com.moverslorryowner.models.** { *; }

# Keep API classes
-keep class com.moverslorryowner.Api_Provider.** { *; }

# Keep controller classes
-keep class com.moverslorryowner.Controllers.** { *; }

# Keep OneSignal classes
-keep class com.onesignal.** { *; }

# Keep HERE Maps classes
-keep class com.here.** { *; }

# Keep location services
-keep class com.google.android.gms.location.** { *; }

# Keep image picker classes
-keep class com.example.image_picker.** { *; }

# Keep webview classes
-keep class com.example.webview_flutter.** { *; }

# General Android optimizations
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Remove logging
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
