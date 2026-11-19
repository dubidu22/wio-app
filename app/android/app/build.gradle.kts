// App ID de.wiederinordnung.app (D-136, final 19 Nov 2026; D-249). Hand-test builds from
// .github/workflows/android-handtest.yml set WIO_HANDTEST=true: they get the
// suffix .handtest and the label "Wio Test", so they live next to a later
// store build (D-249). Release signing comes from four environment variables
// (D-248); without them, release builds keep the debug key, so
// `flutter run --release` works on a developer machine.
val handtest = System.getenv("WIO_HANDTEST") == "true"
val releaseKey = listOf(
    "WIO_ANDROID_KEYSTORE_FILE",
    "WIO_ANDROID_KEYSTORE_PASSWORD",
    "WIO_ANDROID_KEY_ALIAS",
    "WIO_ANDROID_KEY_PASSWORD",
).associateWith { System.getenv(it).orEmpty() }
val hasReleaseKey = releaseKey.values.all { it.isNotEmpty() }

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "de.wiederinordnung.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "de.wiederinordnung.app"
        if (handtest) {
            applicationIdSuffix = ".handtest"
        }
        manifestPlaceholders["appLabel"] = if (handtest) "Wio Test" else "Wio"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("handtest") {
                storeFile = file(releaseKey.getValue("WIO_ANDROID_KEYSTORE_FILE"))
                storeType = "PKCS12"
                storePassword = releaseKey.getValue("WIO_ANDROID_KEYSTORE_PASSWORD")
                keyAlias = releaseKey.getValue("WIO_ANDROID_KEY_ALIAS")
                keyPassword = releaseKey.getValue("WIO_ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "handtest" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Unit tests of the voice guard's rules (D-287), run by CI's app-android job.
dependencies {
    testImplementation("junit:junit:4.13.2")
}
