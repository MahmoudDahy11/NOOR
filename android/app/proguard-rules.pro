# Flutter Stripe rules
# Keep all Stripe classes
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# The error logs specifically mentioned com.reactnativestripesdk
# which flutter_stripe uses internally or as a dependency.
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Suppress warnings for missing pushProvisioning classes if they are not used
-dontwarn com.stripe.android.pushProvisioning.**

# Standard Flutter/ProGuard rules are usually included by the Flutter plugin,
# but we add these here to be safe and address the specific R8 failure.
