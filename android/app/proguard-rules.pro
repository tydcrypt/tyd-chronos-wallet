# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }

# Web3Dart and Crypto Libraries
-keep class com.google.crypto.tink.** { *; }
-keep class org.web3j.** { *; }
-keep class org.bouncycastle.** { *; }
-keep class wallet.** { *; }

# BIP39/BIP32
-keep class bip39.** { *; }
-keep class bip32.** { *; }

# Error Prone Annotations
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }

# PointyCastle
-keep class pointycastle.** { *; }

# General crypto and security
-keep class * implements java.security.spec.AlgorithmParameterSpec
-keep class * implements java.security.Key

# Keep all serialization classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enumerations
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
