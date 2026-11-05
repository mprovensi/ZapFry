extends RefCounted
## Sorteio da aparência; não conhece tabuleiro, tempo, pontuação ou interface.

const Character = preload("res://scripts/execution_character.gd")
const Stories = preload("res://scripts/encounter_stories.gd")
const TEMPLATES := [preload("res://assets/characters/cavaleira.tres"),
	preload("res://assets/characters/pirata.tres"), preload("res://assets/characters/alquimista.tres"),
	preload("res://assets/characters/bardo.tres"), preload("res://assets/characters/vampiro.tres"),
	preload("res://assets/characters/zumbi.tres"), preload("res://assets/characters/elfa.tres")]
var _rng := RandomNumberGenerator.new()
var _bag: Array[int] = []
var _last_id := ""
var _last_story := -1
var _snapshot: Dictionary = {}
var _character: Character


func _init(seed_value: int = -1) -> void:
	if seed_value < 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value


func select(level_index: int, saved: Dictionary) -> Dictionary:
	if _snapshot.is_empty() and saved.get("story") is int:
		_last_story = saved["story"]
	var index := -1
	for slot in range(TEMPLATES.size()):
		if TEMPLATES[slot].character_id == saved.get("id", ""):
			if _snapshot.is_empty():
				_last_id = TEMPLATES[slot].character_id
			if saved.get("level", -1) == level_index:
				index = slot
			break
	var name: String
	if index >= 0:
		var template = TEMPLATES[index]
		name = str(saved.get("name", ""))
		if name != template.display_name and not name in template.aliases:
			name = template.display_name
	else:
		if _bag.is_empty():
			_refill()
		index = _bag.pop_back()
		var template = TEMPLATES[index]
		name = template.aliases[_rng.randi_range(0, template.aliases.size() - 1)] if not template.aliases.is_empty() else template.display_name
	var restore: bool = saved.get("level", -1) == level_index and saved.get("id", "") == TEMPLATES[index].character_id
	var palette := clampi(int(saved.get("palette", 0)), 0, 3) if restore and saved.get("palette", 0) is int else _rng.randi_range(0, 3)
	var eligible := Stories.eligible(TEMPLATES[index].character_id)
	var story := int(saved.get("story", -1)) if saved.get("story", -1) is int else -1
	var restored_story: bool = restore and story in eligible
	if not restored_story:
		eligible.erase(_last_story)
		story = eligible[_rng.randi_range(0, eligible.size() - 1)]
	var snapshot := {"level": level_index, "id": TEMPLATES[index].character_id, "name": name,
		"palette": palette, "story": story, "intro_seen": restored_story and saved.get("intro_seen", false) == true}
	_last_story = story
	if _character != null and _snapshot.get("level") == level_index and _snapshot.get("id") == snapshot["id"] and _snapshot.get("name") == name and _snapshot.get("palette") == palette:
		_snapshot = snapshot
		return {"character": _character, "snapshot": snapshot.duplicate()}
	if _bag.is_empty() and _snapshot.is_empty():
		_refill()
	_bag.erase(index)
	_last_id = TEMPLATES[index].character_id
	_snapshot = snapshot
	# Só o nome da instância muda. SpriteFrames e templates continuam compartilhados e imutáveis.
	_character = TEMPLATES[index].duplicate() as Character
	_character.display_name = name
	_character.palette_index = palette
	return {"character": _character, "snapshot": snapshot.duplicate()}


func _refill() -> void:
	_bag.assign(range(TEMPLATES.size()))
	for index in range(_bag.size() - 1, 0, -1):
		var other := _rng.randi_range(0, index)
		var value := _bag[index]
		_bag[index] = _bag[other]
		_bag[other] = value
	if _bag.size() > 1 and TEMPLATES[_bag.back()].character_id == _last_id:
		var value := _bag[0]
		_bag[0] = _bag.back()
		_bag[_bag.size() - 1] = value
