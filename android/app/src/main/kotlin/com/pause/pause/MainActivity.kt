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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.getStringExtra(EXTRA_PACKAGE)?.let { setPendingPackage(it) }
    }

    companion object {
        private const val CHANNEL_PERMISSIONS = "com.pause.pause/permissions"
        private const val CHANNEL_APP_OPENED = "com.pause.pause/appOpened"
        const val EXTRA_PACKAGE = "package"

        @Volatile
        var eventSink: EventChannel.EventSink? = null
            private set

        @Volatile
        var pendingPackage: String? = null
            private set

        fun setPendingPackage(pkg: String?) {
            pendingPackage = pkg
        }

        fun deliverAppOpened(context: Context, packageName: String) {
            setPendingPackage(packageName)
            val intent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra(EXTRA_PACKAGE, packageName)
            }
            context.startActivity(intent)
            eventSink?.success(packageName)
        }
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
                "openAppDetailSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", packageName, null)
                    }
                    startActivity(intent)
                    result.success(null)
                }
                "hasUsageAccess" -> result.success(hasUsageAccess(this))
                "canDrawOverlays" -> result.success(canDrawOverlays(this))
                "startMonitorService" -> {
                    @Suppress("UNCHECKED_CAST")
                    val list = call.arguments as? List<*>?.let { it?.mapNotNull { e -> e as? String } } ?: emptyList()
                    AppMonitorService.start(this, list)
                    result.success(null)
                }
                "stopMonitorService" -> {
                    AppMonitorService.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_APP_OPENED).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                pendingPackage?.let { pkg ->
                    events?.success(pkg)
                    setPendingPackage(null)
                }
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.getStringExtra(EXTRA_PACKAGE)?.let { pkg ->
            if (eventSink == null) setPendingPackage(pkg)
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
