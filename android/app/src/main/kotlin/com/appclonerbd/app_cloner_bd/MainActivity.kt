package com.appclonerbd.app_cloner_bd

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "app_cloner_bd/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLaunchableApps" -> {
                    try {
                        result.success(getLaunchableApps())
                    } catch (exception: Exception) {
                        result.error(
                            "APP_SCAN_FAILED",
                            exception.localizedMessage ?: "Unable to scan apps.",
                            null
                        )
                    }
                }

                "getCloneCapability" -> {
                    result.success(
                        "Clone Engine is not enabled yet. A supported, provisioned " +
                        "Android managed profile and profile-owner authorization " +
                        "must be evaluated before isolated app cloning can be offered."
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun getLaunchableApps(): List<Map<String, String>> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(0L)
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(intent, 0)
        }

        val ownPackage = packageName
        return resolved
            .mapNotNull { info ->
                val activityInfo = info.activityInfo ?: return@mapNotNull null
                val packageId = activityInfo.packageName
                if (packageId == ownPackage) return@mapNotNull null

                val label = info.loadLabel(packageManager)?.toString()
                    ?.takeIf { it.isNotBlank() }
                    ?: packageId

                mapOf(
                    "packageName" to packageId,
                    "label" to label
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["label"]?.lowercase() }
    }
}
