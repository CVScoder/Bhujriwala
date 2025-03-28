plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") // Applies Firebase plugin
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must be last
}

android {
    namespace = "com.example.bujriwala"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.bujriwala"
        minSdk = 23 // Raised to 21 for better Google Sign-In support (API 5.0+)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Using debug keys for simplicity; update for production later
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}