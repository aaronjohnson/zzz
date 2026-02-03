package net.mqqn.quest.zzz

import android.content.Context
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable

/**
 * Sends data to watch via Wear Data Layer API.
 */
object WearDataSender {

    private const val HABITS_PATH = "/habits"

    fun sendHabits(context: Context, habitsJson: String) {
        val dataClient = Wearable.getDataClient(context)
        val request = PutDataMapRequest.create(HABITS_PATH).apply {
            dataMap.putString("habits", habitsJson)
            dataMap.putLong("timestamp", System.currentTimeMillis())
        }
        dataClient.putDataItem(request.asPutDataRequest().setUrgent())
    }
}
