package com.pause.pause

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.app.usage.UsageStatsManager
import android.app.usage.UsageStats
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_PERMISSIONS = "com.pause.pause/permissions"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_PERMISSIONS).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }
                "openOverlaySettings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                    result.success(null)
                }
                "hasUsageAccess" -> result.success(hasUsageAccess(this))
                "canDrawOverlays" -> result.success(canDrawOverlays(this))
                "startMonitorService" -> {
                    AppMonitorService.start(this)
                    result.success(null)
                }
                "stopMonitorService" -> {
                    AppMonitorService.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageAccess(context: Context): Boolean {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return false
        val time = System.currentTimeMillis()
        @Suppress("DEPRECATION")
        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 10_000, time)
        return stats != null && stats.isNotEmpty()
    }

    private fun canDrawOverlays(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }
}
