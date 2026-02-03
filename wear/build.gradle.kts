plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "net.mqqn.quest.zzz.wear"
    compileSdk = 35

    defaultConfig {
        applicationId = "net.mqqn.quest.zzz"  // Same as phone for Data Layer pairing
        minSdk = 30  // Wear OS 3.0+
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Compose for Wear OS
    implementation(platform("androidx.compose:compose-bom:2024.09.00"))
    implementation("androidx.wear.compose:compose-material3:1.0.0-alpha27")
    implementation("androidx.wear.compose:compose-foundation:1.4.0")
    implementation("androidx.wear.compose:compose-navigation:1.4.0")

    // Activity & Lifecycle
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.6")

    // Data Layer API (phone<->watch sync)
    implementation("com.google.android.gms:play-services-wearable:18.2.0")

    // Coroutines for async
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.8.1")
}
