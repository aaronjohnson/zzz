# Sleep Hygiene App - Design Document

*Start small, ship to internal testing*

---

## Concept

A digital version of a paper clipboard with two views:
1. **Weekly Chart** - Check off daily sleep hygiene habits
2. **Day Detail** - Longer descriptions of each habit with motivation

---

## Privacy Approach

**Phase 1 (This build):** Encryption at rest
- All data stored locally in encrypted SQLite (SQLCipher)
- No network calls
- User's sleep data never leaves their device

**Phase 2 (Future):** Privacy-preserving analytics
- Opt-in aggregate insights
- Differential privacy for population-level learning
- "What habits do people struggle with?" without knowing individuals

---

## Data Model

### Core Entities

```
┌─────────────────┐     ┌─────────────────┐
│   Habit         │     │   DailyLog      │
├─────────────────┤     ├─────────────────┤
│ id (PK)         │     │ id (PK)         │
│ name            │────<│ habit_id (FK)   │
│ short_desc      │     │ date            │
│ long_desc       │     │ completed       │
│ category        │     │ notes           │
│ display_order   │     └─────────────────┘
└─────────────────┘
```

### Habit Categories

Based on standard sleep hygiene recommendations:
- **Environment** - bedroom setup
- **Timing** - consistent schedule
- **Substances** - caffeine, alcohol, etc.
- **Wind-down** - pre-sleep routine
- **Daytime** - exercise, light exposure

---

## SQLite Schema

```sql
-- Habits: the things to track
CREATE TABLE habits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    short_desc TEXT NOT NULL,      -- For weekly chart (brief)
    long_desc TEXT NOT NULL,       -- For day detail (motivational)
    category TEXT NOT NULL,
    display_order INTEGER NOT NULL,
    is_active INTEGER DEFAULT 1,   -- Allow hiding habits
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Daily logs: check-offs
CREATE TABLE daily_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id INTEGER NOT NULL,
    log_date TEXT NOT NULL,        -- ISO date: 2026-02-02
    completed INTEGER DEFAULT 0,   -- 0 = not done, 1 = done
    notes TEXT,                    -- Optional reflection
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (habit_id) REFERENCES habits(id),
    UNIQUE(habit_id, log_date)     -- One entry per habit per day
);

-- Indexes for common queries
CREATE INDEX idx_daily_logs_date ON daily_logs(log_date);
CREATE INDEX idx_daily_logs_habit ON daily_logs(habit_id);
```

---

## Seed Data: Default Habits

| Category | Name | Short | Long (motivational) |
|----------|------|-------|---------------------|
| Timing | Consistent bedtime | Same time to bed | Going to bed at the same time trains your body's internal clock. Even on weekends, try to stay within 30 minutes of your usual time. |
| Timing | Consistent wake time | Same time up | Waking at a consistent time is even more important than bedtime. Light exposure anchors your circadian rhythm. |
| Environment | Dark room | Room is dark | Darkness signals melatonin production. Consider blackout curtains or a sleep mask. Even small lights (LEDs, phone chargers) can disrupt sleep. |
| Environment | Cool temperature | Room is cool | The ideal sleep temperature is 65-68°F (18-20°C). Your body temperature naturally drops during sleep; a cool room supports this. |
| Environment | Phone out of reach | Phone away | Placing your phone across the room removes the temptation to scroll and forces you to physically get up to silence the alarm. |
| Substances | No late caffeine | No caffeine after 2pm | Caffeine has a half-life of 5-6 hours. That afternoon coffee is still 25% active at midnight. |
| Substances | Limited alcohol | No alcohol 3hrs before bed | Alcohol may help you fall asleep but disrupts REM sleep and causes middle-of-night waking. |
| Wind-down | Screen-free hour | No screens 1hr before | Blue light suppresses melatonin. But even without blue light, engaging content keeps your mind active. |
| Wind-down | Relaxation routine | Wind-down routine | A consistent pre-sleep routine (reading, stretching, journaling) signals your body that sleep is coming. |
| Daytime | Morning light | Bright light in morning | 10-30 minutes of bright light (ideally sunlight) within an hour of waking helps regulate your circadian rhythm. |
| Daytime | Exercise | Physical activity | Regular exercise improves sleep quality, but avoid vigorous exercise within 3 hours of bedtime. |
| Daytime | Limited naps | Naps < 30min before 3pm | Long or late naps reduce sleep pressure and make it harder to fall asleep at night. |

---

## UI Screens

### 1. Weekly Chart (Home)

```
┌────────────────────────────────────────┐
│  Sleep Hygiene          [< Week >]     │
│  Jan 27 - Feb 2, 2026                  │
├────────────────────────────────────────┤
│              M  T  W  T  F  S  S       │
│  Same time   ✓  ✓  ✓  ·  ·  ·  ·      │
│  to bed                                │
│  Same time   ✓  ✓  ·  ·  ·  ·  ·      │
│  up                                    │
│  Room dark   ✓  ✓  ✓  ✓  ·  ·  ·      │
│  ...                                   │
├────────────────────────────────────────┤
│  Tap a habit for details               │
│  Tap a checkbox to toggle              │
└────────────────────────────────────────┘
```

### 2. Day Detail

```
┌────────────────────────────────────────┐
│  ← Back       Monday, Feb 2            │
├────────────────────────────────────────┤
│  ┌──────────────────────────────────┐  │
│  │ ☐ Consistent bedtime             │  │
│  │                                  │  │
│  │ Going to bed at the same time   │  │
│  │ trains your body's internal     │  │
│  │ clock. Even on weekends, try    │  │
│  │ to stay within 30 minutes...    │  │
│  │                                  │  │
│  │ Notes: ___________________      │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │ ☑ Room is dark                   │  │
│  │ ...                              │  │
└────────────────────────────────────────┘
```

---

## Flutter Project Structure

```
sleep_hygiene/
├── lib/
│   ├── main.dart
│   ├── database/
│   │   ├── database_helper.dart    # SQLite setup + encryption
│   │   └── seed_data.dart          # Default habits
│   ├── models/
│   │   ├── habit.dart
│   │   └── daily_log.dart
│   ├── screens/
│   │   ├── weekly_chart_screen.dart
│   │   └── day_detail_screen.dart
│   └── widgets/
│       ├── habit_row.dart
│       └── habit_card.dart
├── pubspec.yaml
└── README.md
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0           # SQLite for Flutter
  path: ^1.8.3              # Path manipulation
  # sqflite_sqlcipher: ^2.2.0  # Encrypted SQLite (Phase 1b)
  intl: ^0.18.0             # Date formatting
```

Note: Starting with plain sqflite for simplicity. SQLCipher adds encryption but also complexity. Can add later.

---

## MVP Scope

**In scope:**
- Weekly chart view with checkboxes
- Day detail view with long descriptions
- Toggle completion state
- 12 default habits (seed data)
- Local SQLite storage

**Out of scope (for now):**
- Encryption (add in Phase 1b)
- Custom habits
- Notes field
- Statistics/trends
- Network sync
- Notifications/reminders

---

## Build Steps

1. `flutter create sleep_hygiene`
2. Add sqflite dependency
3. Create database helper with schema
4. Create models (Habit, DailyLog)
5. Seed default habits
6. Build weekly chart screen
7. Build day detail screen
8. Test locally (adb)
9. Ship to internal testing

---

*Let's build.*
