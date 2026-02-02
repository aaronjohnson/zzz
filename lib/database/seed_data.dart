import '../models/habit.dart';

final List<Habit> defaultHabits = [
  // Timing
  Habit(
    name: 'Consistent bedtime',
    shortDesc: 'Same time to bed',
    longDesc: 'Going to bed at the same time trains your body\'s internal clock. Even on weekends, try to stay within 30 minutes of your usual time. Consistency is more important than the exact hour.',
    category: 'Timing',
    displayOrder: 1,
  ),
  Habit(
    name: 'Consistent wake time',
    shortDesc: 'Same time up',
    longDesc: 'Waking at a consistent time is even more important than bedtime. Morning light exposure anchors your circadian rhythm. Set one alarm and get up when it rings.',
    category: 'Timing',
    displayOrder: 2,
  ),

  // Environment
  Habit(
    name: 'Dark room',
    shortDesc: 'Room is dark',
    longDesc: 'Darkness signals melatonin production. Consider blackout curtains or a sleep mask. Even small lights from LEDs, phone chargers, or streetlights can disrupt sleep quality.',
    category: 'Environment',
    displayOrder: 3,
  ),
  Habit(
    name: 'Cool temperature',
    shortDesc: 'Room is cool',
    longDesc: 'The ideal sleep temperature is 65-68°F (18-20°C). Your body temperature naturally drops during sleep; a cool room supports this process. Experiment to find your sweet spot.',
    category: 'Environment',
    displayOrder: 4,
  ),
  Habit(
    name: 'Phone away',
    shortDesc: 'Phone out of reach',
    longDesc: 'Placing your phone across the room removes the temptation to scroll in bed. It also forces you to physically get up to silence the alarm, making it harder to hit snooze.',
    category: 'Environment',
    displayOrder: 5,
  ),

  // Substances
  Habit(
    name: 'No late caffeine',
    shortDesc: 'No caffeine after 2pm',
    longDesc: 'Caffeine has a half-life of 5-6 hours. That afternoon coffee is still 25% active at midnight. If you\'re sensitive, cut off even earlier. Remember: chocolate and some teas contain caffeine too.',
    category: 'Substances',
    displayOrder: 6,
  ),
  Habit(
    name: 'Limited alcohol',
    shortDesc: 'No alcohol 3hrs before bed',
    longDesc: 'Alcohol may help you fall asleep faster, but it disrupts REM sleep and causes middle-of-night waking as your body metabolizes it. The sleep you get is lower quality.',
    category: 'Substances',
    displayOrder: 7,
  ),

  // Wind-down
  Habit(
    name: 'Screen-free hour',
    shortDesc: 'No screens 1hr before',
    longDesc: 'Blue light from screens suppresses melatonin production. But even without blue light, engaging content (social media, news, games) keeps your mind active when it should be winding down.',
    category: 'Wind-down',
    displayOrder: 8,
  ),
  Habit(
    name: 'Relaxation routine',
    shortDesc: 'Wind-down routine',
    longDesc: 'A consistent pre-sleep routine signals your body that sleep is coming. This could be reading, gentle stretching, journaling, or a warm bath. The activity matters less than the consistency.',
    category: 'Wind-down',
    displayOrder: 9,
  ),

  // Daytime
  Habit(
    name: 'Morning light',
    shortDesc: 'Bright light in AM',
    longDesc: '10-30 minutes of bright light (ideally sunlight) within an hour of waking helps regulate your circadian rhythm. On cloudy days or in winter, a light therapy lamp can help.',
    category: 'Daytime',
    displayOrder: 10,
  ),
  Habit(
    name: 'Daily exercise',
    shortDesc: 'Physical activity',
    longDesc: 'Regular physical activity improves sleep quality and helps you fall asleep faster. However, avoid vigorous exercise within 3 hours of bedtime as it can be stimulating.',
    category: 'Daytime',
    displayOrder: 11,
  ),
  Habit(
    name: 'Smart napping',
    shortDesc: 'Naps <30min, before 3pm',
    longDesc: 'Long or late naps reduce "sleep pressure" - the drive to sleep at night. If you nap, keep it under 30 minutes and before 3pm. Some people do better avoiding naps entirely.',
    category: 'Daytime',
    displayOrder: 12,
  ),
];
