# Privacy Design Constraints

Sleep data is deeply personal. It correlates with mental health, medication use, work stress, and lifestyle. A database of sleep patterns is a liability - for users and for the app.

This document describes the privacy constraints that shape zzz's architecture.

---

## Sensitive Data

What users might reveal through a sleep hygiene tracker:

| Data | Why It's Sensitive |
|------|-------------------|
| Sleep disorders | Insurance, employment implications |
| Mood correlation | Mental health indicators |
| Substance use | Caffeine, alcohol, sleep aids |
| Schedule patterns | Shift work, stress indicators |
| Consistency gaps | Life disruptions, health changes |

**Principle:** Don't collect what you can't protect. Don't store what you don't need.

---

## Phase 1: Local-Only (Current)

All data stays on the user's device.

- SQLite database stored locally
- No network calls
- No accounts, no sync
- No analytics, no telemetry

**Trust pitch:** "Your sleep data never leaves your device."

If you uninstall the app, your data is gone. That's a feature.

---

## Phase 2: Encryption at Rest

SQLCipher encryption for mobile (Android/iOS). Desktop platforms use unencrypted local storage with user notice.

### Mobile (Implemented)

- SQLCipher with device-derived key via `flutter_secure_storage`
- Protects against device theft/loss
- Protects against other apps accessing the database
- First-run dialog explains protections to users

**Trust pitch:** "Your sleep data is encrypted. Even if someone gets your phone, they can't read it."

### Desktop (Future)

Desktop encryption requires different tooling (`sqlcipher_flutter_libs` + custom FFI). Current approach:

- Clear first-run notice that data is not encrypted
- Feature request contact for users who want this
- Acceptable for development/testing use case

Desktop encryption is a stretch goal pending user demand.

---

## Phase 3: Privacy-Preserving Analytics (Optional, Opt-in)

If we want to learn aggregate patterns to improve the app, use differential privacy.

### What We Want to Learn

| Question | Why It Helps |
|----------|--------------|
| Which habits are hardest? | Focus improvement efforts |
| Do users improve over time? | Validate the approach works |
| Which content resonates? | Better motivational text |
| Where do users drop off? | Fix onboarding issues |

### How to Learn Without Surveillance

Differential privacy adds calibrated noise so individual responses can't be determined, but population-level patterns emerge.

| Question | Technique | Output |
|----------|-----------|--------|
| Common issues | Randomized response | "40% report difficulty falling asleep (±8%)" |
| Habit completion | Local DP counters | "Morning light is most-skipped habit" |
| Improvement trends | DP cohort analysis | "Users report 15% improvement after 2 weeks" |
| Content engagement | DP click-through | "Long descriptions read 2x more than short" |

**Key insight:** We can know "most users struggle with consistent bedtime" without knowing anything about any specific user.

**Trust pitch:** "We learn what habits people struggle with. We never see your sleep diary."

### Privacy Budget

- Track cumulative information shared per user (epsilon)
- Stop collecting when budget exhausted
- Transparent reporting: "This month, your contributions helped us learn..."
- User controls: opt-out anytime, see what was shared

### Minimum Sample Sizes

Differential privacy requires enough users that noise doesn't destroy signal. Don't build network infrastructure for imaginary scale.

| Insight Type | Minimum Users | Why |
|--------------|---------------|-----|
| Binary rates (% completed habit X) | ~100 | Noise overwhelms signal below this |
| Rankings (most skipped habits) | ~500 | Need enough variance |
| Cohort trends (improvement over time) | ~1,000 | Temporal noise compounds |
| Subgroup analysis (age, patterns) | ~5,000+ | Slicing reduces n quickly |

**Practical approach:** Ship local-only. Measure organic growth. Add opt-in analytics only when daily active users exceed threshold. Apple's differential privacy research suggests minimum 1,000 DAU before collecting even basic randomized response data.

---

## What We Will Never Do

- Sell or share individual user data
- Build profiles for advertising
- Require accounts or sign-in
- Phone home without explicit opt-in
- Collect data we don't need for the stated purpose

---

## References

- [Differential Privacy](https://en.wikipedia.org/wiki/Differential_privacy) - Mathematical framework
- [Apple's DP Implementation](https://www.apple.com/privacy/docs/Differential_Privacy_Overview.pdf) - Industry practice
- [Google RAPPOR](https://research.google/pubs/pub42852/) - Local DP in practice
- [OpenDP](https://opendp.org/) - Open source DP toolkit
