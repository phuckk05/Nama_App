// Root Project build.gradle.kts

buildscript {
    repositories {
        google()  // Đảm bảo rằng repository của Google được thêm vào
        mavenCentral()
    }
    dependencies {
        // Thêm classpath cho plugin Google Services (thêm phiên bản đúng của plugin)
        classpath("com.android.tools.build:gradle:7.0.4")
        classpath("com.google.gms:google-services:4.3.15")  // Phiên bản của plugin Google Services

    }
}

allprojects {
    repositories {
        google()  // Đảm bảo repository của Google được thêm vào
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Set individual subproject build directories to be under the custom build folder
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Ensure that the subprojects depend on the 'app' project
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
