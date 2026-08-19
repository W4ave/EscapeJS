# item.gd
extends Area2D

@export var item_id : String = ""   #어떤 아이템인지 구분 ("hammer", "flashlight" 등)

@onready var game = get_tree().current_scene
@onready var texture = $AnimatedSprite2D
@onready var clickUI = $clickUI
var is_near := false


func _ready() -> void:
	self.body_entered.connect(_on_entered)
	self.body_exited.connect(_on_exited)
	self.input_event.connect(_on_input_event)
	input_pickable = true
	clickUI.visible = false
	texture.play("idle")

func _on_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	is_near = true
	texture.play("near")
	clickUI.visible = true

func _on_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	is_near = false
	texture.play("idle")
	clickUI.visible = false

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_near:
			game.item_picked_up.emit(self)
			queue_free()
