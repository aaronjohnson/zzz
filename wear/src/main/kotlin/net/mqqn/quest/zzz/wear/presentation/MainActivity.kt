package net.mqqn.quest.zzz.wear.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch
import net.mqqn.quest.zzz.wear.data.PhoneDataClient
import net.mqqn.quest.zzz.wear.data.WatchHabit

class MainActivity : ComponentActivity() {

    private lateinit var phoneClient: PhoneDataClient
    private var habits by mutableStateOf<List<WatchHabit>>(emptyList())
    private var isConnected by mutableStateOf(false)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        phoneClient = PhoneDataClient(this)

        setContent {
            WearApp(
                habits = habits,
                isConnected = isConnected,
                onToggle = { habit ->
                    toggleHabit(habit)
                },
                onRefresh = {
                    requestSync()
                }
            )
        }
    }

    override fun onResume() {
        super.onResume()
        requestSync()
    }

    private fun requestSync() {
        lifecycleScope.launch {
            isConnected = phoneClient.isPhoneConnected()
            if (isConnected) {
                phoneClient.requestHabits()
            }
            // Listen for habit updates
            phoneClient.habitsFlow.collect { newHabits ->
                habits = newHabits
            }
        }
    }

    private fun toggleHabit(habit: WatchHabit) {
        // Optimistic update
        habits = habits.map {
            if (it.id == habit.id) it.copy(completed = !it.completed) else it
        }
        // Send to phone
        lifecycleScope.launch {
            phoneClient.toggleHabit(habit.id, !habit.completed)
        }
    }
}
