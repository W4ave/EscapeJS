extends Node

var final_time: float = 0.0

const SAVE_PATH = "user://ranking.cfg"
const MAX_RANK = 3

@onready var line_edit = $CanvasLayer/NameWrite  # 경로 맞게 수정
@onready var button = $CanvasLayer/NameButton
@onready var ranking_box = $RankingBox
@onready var label_1 = $RankingBox/Ranking/Rank1
@onready var label_2 = $RankingBox/Ranking/Rank2
@onready var label_3 = $RankingBox/Ranking/Rank3
@onready var restart_button = $CanvasLayer/VBoxContainer/Button


func _ready() -> void:
	restart_button.text = ">>"
	ranking_box.hide()  # 처음엔 랭킹 숨김
	button.pressed.connect(_on_name_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	line_edit.text_submitted.connect(_on_name_submitted)  # 엔터 시그널 연결

func _on_name_submitted(text: String) -> void:
	_on_name_button_pressed()  # 버튼이랑 똑같은 동작

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	queue_free()
	
	# 새로 시작하는 판이므로 목숨/아이템/보스 관련 상태를 전부 초기화
	global.life = 3
	global.checkpoint = Vector2(0, -1)
	global.elapsed_time = 0.0
	global.get_flashlight = false
	global.has_hammer = false
	global.stamina = 100.0
	global.light_charge = 100.0
	global.enemy_enable = false
	global.boss_enable = false
	global.boss_hp = 100.0
	global.hammer_cooldown_left = 0.0
	global.focus_state = false
	global.slowdown = 1

func _on_name_button_pressed() -> void:
	restart_button.text = "처음으로"
	var player_name = line_edit.text.strip_edges()  # 앞뒤 공백 제거

	if player_name == "":  # 이름 입력 안 했으면 무시
		return

	save_record(final_time, player_name)

	line_edit.hide()
	button.hide()
	ranking_box.show()
	show_ranking()


func save_record(time: float, player_name: String) -> void:
	var config = ConfigFile.new()
	var records: Array = []

	if config.load(SAVE_PATH) == OK:
		records = config.get_value("ranking", "records", [])

	records.append({
		"time": time,
		"name": player_name
	})

	records.sort_custom(func(a, b): return a.time < b.time)

	if records.size() > MAX_RANK:
		records.resize(MAX_RANK)

	config.set_value("ranking", "records", records)
	config.save(SAVE_PATH)


func show_ranking() -> void:
	var records = load_records()
	var labels = [label_1, label_2, label_3]

	for i in labels.size():
		if i < records.size():
			var r = records[i]
			labels[i].text = "%d위  %s  %s" % [i + 1, r["name"], format_time(r["time"])]
		else:
			labels[i].text = "%d위  -" % [i + 1]


func load_records() -> Array:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return []
	return config.get_value("ranking", "records", [])


func format_time(time: float) -> String:
	@warning_ignore("integer_division")
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int(time * 100) % 100
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
