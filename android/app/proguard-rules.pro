# Keep class names for React Native
-keepnames class com.facebook.react.** { *; }
-keepclassmembers class com.facebook.react.** { *; }
-dontwarn com.facebook.react.**

# Keep class names for React Native Vector Icons
-keep class com.oblador.vectoricons.** { *; }
-dontwarn com.oblador.vectoricons.**

# Keep class names for ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep class names for Media3
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Add any other necessary rules for your dependencies