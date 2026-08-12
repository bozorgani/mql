# Logger Specification (Before Strategy Engine)
What: Trade events, errors, config load, AI recommendations, execution reports, emergency shutdown.
Format: JSON lines per event; structured fields: timestamp, level, module, event_type, message, data, trade_id.
Levels: DEBUG (development), INFO (normal), WARN (issues), ERROR (failures), FATAL (shutdown).
Files: log_YYYY-MM-DD.json per day; archive monthly; error subset error_YYYY-MM-DD.json.
No code yet; spec only.
