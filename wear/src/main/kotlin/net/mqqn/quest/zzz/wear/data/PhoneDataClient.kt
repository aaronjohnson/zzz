package net.mqqn.quest.zzz.wear.data

import android.content.Context
import com.google.android.gms.wearable.*
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import org.json.JSONArray
import org.json.JSONObject

data class WatchHabit(
    val id: Int,
    val shortDesc: String,
    val completed: Boolean
)

/**
 * Handles communication with the phone app via Wear Data Layer API.
 * No internet required - uses Bluetooth/WiFi between paired devices.
 */
class PhoneDataClient(context: Context) {

    private val dataClient: DataClient = Wearable.getDataClient(context)
    private val messageClient: MessageClient = Wearable.getMessageClient(context)
    private val nodeClient: NodeClient = Wearable.getNodeClient(context)

    companion object {
        private const val HABITS_PATH = "/habits"
        private const val TOGGLE_PATH = "/toggle"
    }

    /**
     * Flow of habits from phone, updated whenever phone sends new data.
     */
    val habitsFlow: Flow<List<WatchHabit>> = callbackFlow {
        val listener = DataClient.OnDataChangedListener { dataEvents ->
            dataEvents.forEach { event ->
                if (event.type == DataEvent.TYPE_CHANGED &&
                    event.dataItem.uri.path == HABITS_PATH) {
                    val habits = parseHabits(event.dataItem)
                    trySend(habits)
                }
            }
        }
        dataClient.addListener(listener)
        awaitClose { dataClient.removeListener(listener) }
    }

    /**
     * Check if phone is reachable.
     */
    suspend fun isPhoneConnected(): Boolean {
        return try {
            val nodes = nodeClient.connectedNodes.await()
            nodes.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Request fresh habits from phone.
     */
    suspend fun requestHabits() {
        try {
            val nodes = nodeClient.connectedNodes.await()
            nodes.firstOrNull()?.let { node ->
                val request = JSONObject().put("action", "sync")
                messageClient.sendMessage(
                    node.id,
                    HABITS_PATH,
                    request.toString().toByteArray()
                ).await()
            }
        } catch (e: Exception) {
            // Phone not reachable
        }
    }

    /**
     * Send habit toggle to phone.
     */
    suspend fun toggleHabit(habitId: Int, completed: Boolean) {
        try {
            val nodes = nodeClient.connectedNodes.await()
            nodes.firstOrNull()?.let { node ->
                val message = JSONObject().apply {
                    put("action", "toggle")
                    put("habitId", habitId)
                    put("completed", completed)
                }
                messageClient.sendMessage(
                    node.id,
                    TOGGLE_PATH,
                    message.toString().toByteArray()
                ).await()
            }
        } catch (e: Exception) {
            // Will sync when reconnected
        }
    }

    private fun parseHabits(dataItem: DataItem): List<WatchHabit> {
        return try {
            val dataMap = DataMapItem.fromDataItem(dataItem).dataMap
            val habitsJson = dataMap.getString("habits") ?: return emptyList()
            val jsonArray = JSONArray(habitsJson)

            (0 until jsonArray.length()).map { i ->
                val obj = jsonArray.getJSONObject(i)
                WatchHabit(
                    id = obj.getInt("id"),
                    shortDesc = obj.getString("shortDesc"),
                    completed = obj.getBoolean("completed")
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }
}
