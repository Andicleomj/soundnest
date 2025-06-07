plugins {
    id("com.android.application")
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.soundnest"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.soundnest"
        minSdk = 24 // Diperbaiki
        targetSdk = 35 // Diperbaiki
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
        manifestPlaceholders.put("castAppId", "CC1AD845")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-cast-framework:21.3.0")
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation ("androidx.mediarouter:mediarouter:1.3.1")
}

apply(plugin = "com.google.gms.google-services") 

flutter {
    source = "../.."
}
