# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ML Kit
-keep class com.google.mlkit.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keepclassmembers class kotlin.Metadata { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Prevent R8 from stripping models
-keep class com.billsplitai.app.** { *; }
