# 여러 줄 대사를 순서대로 보여주는 대사창 UI.
# game.gd의 show_dialogue(lines) 시그널을 받아 동작합니다.
# 이름/초상화 없이 텍스트만 표시하며, 클릭 또는 스페이스(엔터)로 한 줄씩 넘깁니다.
# 타이핑 중에 넘기기를 누르면 즉시 전체 텍스트를 보여주고, 다 보여진 상태에서 누르면 다음 줄로 넘어갑니다.
# 마지막 줄에서 넘기면 창이 닫히고 게임이 다시 진행됩니다.
extends CanvasLayer

@onready var control: Control = $Control
@onready var label: Label = $Control/Panel/Label
@onready var game = get_tree().current_scene

var lines: Array = []
var line_index: int = 0
var is_active := false

var typing_speed: float = 0.03   # 글자 한 개당 걸리는 시간(초)
var is_typing := false
var char_timer: float = 0.0
var full_text: String = ""


func _ready() -> void:
	control.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS   # 일시정지 중에도 입력을 받아야 함
	game.connect("show_dialogue", Callable(self, "start_dialogue"))


func start_dialogue(new_lines: Array) -> void:
	if new_lines.is_empty():
		return
	lines = new_lines
	line_index = 0
	is_active = true
	get_tree().paused = true
	control.visible = true
	_show_line(lines[line_index])


func _show_line(text: String) -> void:
	full_text = text
	label.text = full_text
	label.visible_characters = 0
	char_timer = 0.0
	is_typing = true


func _process(delta: float) -> void:
	if not is_active or not is_typing:
		return

	char_timer += delta
	while char_timer >= typing_speed and label.visible_characters < full_text.length():
		label.visible_characters += 1
		char_timer -= typing_speed

	if label.visible_characters >= full_text.length():
		is_typing = false


func _advance() -> void:
	line_index += 1
	if line_index >= lines.size():
		_end_dialogue()
	else:
		_show_line(lines[line_index])


func _end_dialogue() -> void:
	is_active = false
	control.visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	var advance_pressed := event.is_action_pressed("ui_accept")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance_pressed = true

	if advance_pressed:
		if is_typing:
			# 타이핑 중이면 즉시 전체 텍스트를 보여주고 끝냄
			label.visible_characters = -1
			is_typing = false
		else:
			_advance()
		get_viewport().set_input_as_handled()
