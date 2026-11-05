class_name PlayerProfile
extends RefCounted
## Progresso por fase, migração do protótipo antigo e gravação com cópia de segurança.

var sound_enabled := true
var music_volume := 1.0
var effects_volume := 1.0
var vibration_enabled := true
var reduced_flashes := false
var best_score := 0
var unlocked_level := 0
var current_level := 0
var level_count := 24
var records: Dictionary = {}
var appearance: Dictionary = {}
var loaded_from_backup := false
var _valid_primary := false


static func _number(value: Variant, fallback: float) -> float:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
		return fallback
	return float(value)


static func _record_values(entry: Dictionary) -> Dictionary:
	return {"completed": entry.get("completed", false) == true,
		"stars": clampi(int(_number(entry.get("stars", 0), 0)), 0, 3),
		"best_score": maxi(0, int(_number(entry.get("best_score", 0), 0))),
		"best_time": maxf(-1, _number(entry.get("best_time", -1), -1)),
		"completions": maxi(0, int(_number(entry.get("completions", 0), 0))),
		"legacy": entry.get("legacy", false) == true,
		"rules_revision": maxi(1, int(_number(entry.get("rules_revision", 1), 1)))}


func load_profile(path: String, count: int = 24) -> Error:
	level_count = maxi(1, count)
	sound_enabled = true
	music_volume = 1.0
	effects_volume = 1.0
	vibration_enabled = true
	reduced_flashes = false
	best_score = 0
	unlocked_level = 0
	current_level = 0
	records.clear()
	appearance.clear()
	var config := ConfigFile.new()
	var error := config.load(path)
	if error == OK and not config.has_section("progress"):
		error = ERR_FILE_CORRUPT
	_valid_primary = error == OK
	loaded_from_backup = false
	if error != OK:
		var backup_error := config.load(path + ".bak")
		if backup_error != OK or not config.has_section("progress"):
			return error
		loaded_from_backup = true
	sound_enabled = config.get_value("preferences", "sound", true) == true
	music_volume = clampf(_number(config.get_value("preferences", "music_volume", 1.0), 1.0), 0, 1)
	effects_volume = clampf(_number(config.get_value("preferences", "effects_volume", 1.0), 1.0), 0, 1)
	vibration_enabled = config.get_value("preferences", "vibration", true) == true
	reduced_flashes = config.get_value("preferences", "reduced_flashes", false) == true
	best_score = maxi(0, int(_number(config.get_value("progress", "best_score", 0), 0)))
	unlocked_level = clampi(int(_number(config.get_value("progress", "unlocked_level", 0), 0)), 0, level_count - 1)
	records.clear()
	var raw: Variant = config.get_value("progress", "levels", {})
	if raw is Dictionary:
		for key in raw:
			var text_key := str(key)
			if not text_key.is_valid_int() or int(text_key) < 1 or int(text_key) > level_count or not raw[key] is Dictionary:
				continue
			var entry: Dictionary = raw[key]
			var record := _record_values(entry)
			record["history"] = {}
			var history: Variant = entry.get("history", {})
			if history is Dictionary:
				for revision in history:
					var revision_key := str(revision)
					if revision_key.is_valid_int() and int(revision_key) > 0 and history[revision] is Dictionary:
						var historical := _record_values(history[revision])
						historical["rules_revision"] = int(revision_key)
						record["history"][str(int(revision_key))] = historical
			if record["stars"] > 0 or record["best_score"] > 0:
				record["completed"] = true
			records[str(int(text_key))] = record
			if record["completed"]:
				unlocked_level = maxi(unlocked_level, mini(int(text_key), level_count - 1))
			best_score = maxi(best_score, int(record["best_score"]))
	# Desbloqueios antigos comprovam as vitórias anteriores, mas não seus recordes.
	for index in range(unlocked_level):
		var id := str(index + 1)
		if not records.has(id):
			records[id] = {"completed": true, "stars": 0, "best_score": 0, "best_time": -1.0, "completions": 0, "legacy": true, "rules_revision": 1, "history": {}}
	var fallback := 0 if completed_count() >= level_count else unlocked_level
	current_level = clampi(int(_number(config.get_value("progress", "current_level", fallback), fallback)), 0, unlocked_level)
	var saved: Variant = config.get_value("appearance", "current", {})
	if saved is Dictionary and typeof(saved.get("level")) == TYPE_INT and saved.get("level") >= 0 and saved.get("level") < level_count and saved.get("id") is String and saved.get("name") is String and saved.get("id").length() <= 32 and saved.get("name").length() <= 64:
		appearance = {"level": saved["level"], "id": saved["id"], "name": saved["name"]}
		appearance["palette"] = clampi(int(_number(saved.get("palette", 0), 0)), 0, 3)
		appearance["story"] = int(_number(saved.get("story", -1), -1))
		appearance["intro_seen"] = saved.get("intro_seen", false) == true
	return OK


func level_record(id: int) -> Dictionary:
	return records.get(str(id), {}).duplicate(true)


func record_win(id: int, score: int, stars: int, elapsed: float, rules_revision: int = 1) -> bool:
	if id < 1 or id > level_count or score <= 0 or stars < 1 or stars > 3 or not is_finite(elapsed) or elapsed < 0 or rules_revision < 1:
		return false
	var previous := level_record(id)
	var history: Dictionary = previous.get("history", {}).duplicate(true)
	if not previous.is_empty() and int(previous.get("rules_revision", 1)) != rules_revision:
		var old_revision := str(int(previous.get("rules_revision", 1)))
		previous.erase("history")
		history[old_revision] = previous
		previous = history.get(str(rules_revision), {})
	var old_time := float(previous.get("best_time", -1))
	records[str(id)] = {"completed": true,
		"stars": maxi(int(previous.get("stars", 0)), stars),
		"best_score": maxi(int(previous.get("best_score", 0)), score),
		"best_time": elapsed if old_time < 0 else minf(old_time, elapsed),
		"completions": int(previous.get("completions", 0)) + 1, "legacy": false,
		"rules_revision": rules_revision, "history": history}
	best_score = maxi(best_score, score)
	unlocked_level = maxi(unlocked_level, mini(id, level_count - 1))
	current_level = id if id < level_count else 0
	return true


func completed_count() -> int:
	var total := 0
	for record in records.values():
		if record.get("completed", false):
			total += 1
	return total


func total_stars() -> int:
	var total := 0
	for record in records.values():
		total += int(record.get("stars", 0))
	return total


func has_legacy_records() -> bool:
	for record in records.values():
		if record.get("legacy", false):
			return true
	return false


static func format_time(seconds: float) -> String:
	if seconds < 0 or not is_finite(seconds):
		return "—"
	var tenths := int(round(seconds * 10.0))
	return ("%02d:%04.1f" % [tenths / 600, float(tenths % 600) / 10.0]).replace(".", ",")


func save_profile(path: String) -> Error:
	var absolute := ProjectSettings.globalize_path(path)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	if directory_error != OK:
		return directory_error
	var config := ConfigFile.new()
	config.set_value("metadata", "schema_version", 7)
	config.set_value("appearance", "current", appearance)
	config.set_value("preferences", "sound", sound_enabled)
	config.set_value("preferences", "music_volume", music_volume)
	config.set_value("preferences", "effects_volume", effects_volume)
	config.set_value("preferences", "vibration", vibration_enabled)
	config.set_value("preferences", "reduced_flashes", reduced_flashes)
	config.set_value("progress", "best_score", best_score)
	config.set_value("progress", "unlocked_level", unlocked_level)
	config.set_value("progress", "current_level", current_level)
	config.set_value("progress", "levels", records)
	var error := config.save(path + ".tmp")
	if error != OK:
		return error
	if _valid_primary and FileAccess.file_exists(path):
		error = DirAccess.copy_absolute(absolute, absolute + ".bak")
		if error != OK:
			return error
	error = DirAccess.rename_absolute(absolute + ".tmp", absolute)
	if error == OK:
		_valid_primary = true
		loaded_from_backup = false
	return error
