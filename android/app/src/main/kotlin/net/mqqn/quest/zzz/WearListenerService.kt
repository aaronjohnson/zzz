package net.mqqn.quest.zzz

import com.google.android.gms.wearable.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Listens for messages from watch and forwards to Flutter.
 * Sends habit data to watch when requested.
 */
class WearListenerService : WearableListenerService() {

    companion object {
        private const val HABITS_PATH = "/habits"
        private const val TOGGLE_PATH = "/toggle"
        private const val CHANNEL = "net.mqqn.quest.zzz/wear"

        // Reference to Flutter engine for method channel
        var flutterEngine: FlutterEngine? = null
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        when (messageEvent.path) {
            HABITS_PATH -> handleSyncRequest(messageEvent)
            TOGGLE_PATH -> handleToggle(messageEvent)
        }
    }

    private fun handleSyncRequest(messageEvent: MessageEvent) {
        // Request habits from Flutter and send to watch
        val channel = flutterEngine?.dartExecutor?.let {
            MethodChannel(it.binaryMessenger, CHANNEL)
        } ?: return

        channel.invokeMethod("getHabits", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                val habitsJson = result as? String ?: return
                sendHabitsToWatch(habitsJson, messageEvent.sourceNodeId)
            }
            override fun error(code: String, msg: String?, details: Any?) {}
            override fun notImplemented() {}
        })
    }

    private fun handleToggle(messageEvent: MessageEvent) {
        try {
            val json = JSONObject(String(messageEvent.data))
            val habitId = json.getInt("habitId")
            val completed = json.getBoolean("completed")

            // Forward to Flutter
            val channel = flutterEngine?.dartExecutor?.let {
                MethodChannel(it.binaryMessenger, CHANNEL)
            } ?: return

            channel.invokeMethod("toggleHabit", mapOf(
                "habitId" to habitId,
                "completed" to completed
            ))
        } catch (e: Exception) {
            // Invalid message
        }
    }

    private fun sendHabitsToWatch(habitsJson: String, nodeId: String) {
        val dataClient = Wearable.getDataClient(this)
        val request = PutDataMapRequest.create(HABITS_PATH).apply {
            dataMap.putString("habits", habitsJson)
            dataMap.putLong("timestamp", System.currentTimeMillis())
        }
        dataClient.putDataItem(request.asPutDataRequest().setUrgent())
    }
}
