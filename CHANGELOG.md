# Changelog

*Style note: entries draw inspiration from nursery rhymes. Sleep tight.*

---

## [0.2.0] - 2026-02-02

*Now I lay me down to sleep, my watch will help my habits keep.*

### Added
- Kotlin Compose companion app for Wear OS (Samsung Galaxy Watch)
- Phone-to-watch sync via Data Layer API (Bluetooth/WiFi, no cloud)
- Daily bedtime notification reminder (default 10 PM)
- "Phone down" dialog when all habits checked - auto-closes after 5 seconds

---

## [0.1.0] - 2026-02-02

*Hush little data, don't say a word*
*Mama's gonna keep you safe and secured*

### Added
- Weekly chart view for tracking 12 sleep hygiene habits
- Day detail view with motivational descriptions
- Local SQLite storage - your data stays on your device
- Encryption at rest on mobile (SQLCipher) - locked up tight
- Privacy notice dialog on first launch
- Desktop platforms show honest "not encrypted" notice

### Privacy
- No accounts, no servers, no telemetry
- Uninstall and it's gone forever
- See [PRIVACY.md](PRIVACY.md) for the full architecture
