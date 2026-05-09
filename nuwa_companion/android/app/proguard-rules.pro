# ProGuard rules for Nuwa Companion

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Provider
-keep class provider.** { *; }

# HTTP
-keep class http.** { *; }
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn android.net.http.**

# Keep model classes
-keep class com.nuwa.nuwa_companion.** { *; }
