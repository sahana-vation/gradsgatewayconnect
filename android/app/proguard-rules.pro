# Keep Flutter-related classes
-keep class io.flutter.** { *; }

# Keep Google Play Services Credentials API
-keep class com.google.android.gms.auth.api.credentials.** { *; }

# Keep Google Play Core Split Install API
-keep class com.google.android.play.core.** { *; }

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep annotation attributes (needed for some frameworks)
-keepattributes *Annotation*

# Prevent stripping R.class files (resources)
-keep class **.R$* { *; }

# Keep Play Core SplitCompat and SplitInstall classes
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }

# Keep SMS Autofill and OTP Autofill-related classes
-keep class com.google.android.gms.auth.api.phone.** { *; }
-keep class com.jaumard.sms_autofill.** { *; }
-keep class dev.hussein.otp_autofill.** { *; }
