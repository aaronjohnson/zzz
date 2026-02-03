package net.mqqn.quest.zzz.wear.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.items
import androidx.wear.compose.foundation.lazy.rememberScalingLazyListState
import androidx.wear.compose.material3.Card
import androidx.wear.compose.material3.CardDefaults
import androidx.wear.compose.material3.CircularProgressIndicator
import androidx.wear.compose.material3.MaterialTheme
import androidx.wear.compose.material3.Text
import net.mqqn.quest.zzz.wear.data.WatchHabit

@Composable
fun WearApp(
    habits: List<WatchHabit>,
    isConnected: Boolean,
    onToggle: (WatchHabit) -> Unit,
    onRefresh: () -> Unit
) {
    MaterialTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
        ) {
            when {
                !isConnected -> DisconnectedState()
                habits.isEmpty() -> LoadingState()
                else -> HabitList(habits, onToggle)
            }
        }
    }
}

@Composable
private fun DisconnectedState() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "📱",
                style = MaterialTheme.typography.displayMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Open app\non phone",
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun LoadingState() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator()
    }
}

@Composable
private fun HabitList(
    habits: List<WatchHabit>,
    onToggle: (WatchHabit) -> Unit
) {
    val listState = rememberScalingLazyListState()
    val completedCount = habits.count { it.completed }

    ScalingLazyColumn(
        modifier = Modifier.fillMaxSize(),
        state = listState,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header with progress
        item {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(bottom = 8.dp)
            ) {
                Text(
                    text = "$completedCount / ${habits.size}",
                    style = MaterialTheme.typography.titleLarge,
                    color = if (completedCount == habits.size)
                        Color(0xFF4CAF50) else MaterialTheme.colorScheme.primary
                )
                Text(
                    text = "tonight",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Habit items
        items(habits, key = { it.id }) { habit ->
            HabitChip(habit = habit, onToggle = { onToggle(habit) })
        }
    }
}

@Composable
private fun HabitChip(
    habit: WatchHabit,
    onToggle: () -> Unit
) {
    Card(
        onClick = onToggle,
        modifier = Modifier
            .fillMaxWidth(0.9f)
            .padding(vertical = 2.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (habit.completed)
                Color(0xFF4CAF50).copy(alpha = 0.3f)
            else
                Color.DarkGray.copy(alpha = 0.3f)
        )
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 10.dp)
        ) {
            Text(
                text = if (habit.completed) "✓" else "○",
                style = MaterialTheme.typography.bodyLarge,
                color = if (habit.completed) Color(0xFF4CAF50)
                        else MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = habit.shortDesc,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )
        }
    }
}
