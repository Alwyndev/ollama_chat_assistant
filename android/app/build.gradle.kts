// --------------------------------------------------
// android/app/build.gradle.kts (APP‑MODULE)
// --------------------------------------------------

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace    = "com.example.ollama_assistant"
    compileSdk   = 35

    defaultConfig {
        applicationId = "com.example.ollama_assistant"
        minSdk        = 21
        targetSdk     = 35
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig    = signingConfigs.getByName("debug")
            isMinifyEnabled  = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}
