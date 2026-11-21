# Keep Flutter wrapper & Android embedding rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Keep SQLite3 / sqlite3_flutter_libs native JNI/FFI bindings
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }
-keep class com.sun.jna.** { *; }
-keepclassmembers class * extends com.sun.jna.** { *; }

# Keep flutter_secure_storage & Tink crypto classes
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.google.crypto.tink.** { *; }
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# Optional Flutter deferred components Play Core classes
-dontwarn com.google.android.play.core.**

