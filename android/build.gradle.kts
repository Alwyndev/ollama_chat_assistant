// --------------------------------------------------
// android/build.gradle.kts (PROJECT‑LEVEL)
// --------------------------------------------------

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:7.4.1")
        // Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect the root build/ directory into a sibling "build" folder
val newRootBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newRootBuildDir)

subprojects {
    // Redirect each subproject's build/ into that same tree
    val newSubBuildDir = newRootBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubBuildDir)
    evaluationDependsOn(":app")
}

// Provide a top‑level "clean" task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
