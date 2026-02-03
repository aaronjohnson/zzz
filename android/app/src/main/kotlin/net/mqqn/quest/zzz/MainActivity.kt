package net.mqqn.quest.zzz

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "net.mqqn.quest.zzz/wear"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Share engine with WearListenerService for watch communication
        WearListenerService.flutterEngine = flutterEngine

        // Set up method channel for Dart <-> native communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendHabitsToWatch" -> {
                    val habitsJson = call.argument<String>("habits")
                    if (habitsJson != null) {
                        WearDataSender.sendHabits(this, habitsJson)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "habits is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        WearListenerService.flutterEngine = null
    }
}
