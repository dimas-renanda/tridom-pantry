## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Dart HTTP Server
-keep class dart.** { *; }
-keepclassmembers class * {
    native <methods>;
}

## Network
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
