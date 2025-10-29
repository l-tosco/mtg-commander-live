extends Node2D

signal mouseIn
signal mouseOff

var startingPosition: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)
	
func _on_card_area_mouse_entered() -> void:
	emit_signal("mouseIn", self)

func _on_card_area_mouse_exited() -> void:
	emit_signal("mouseOff", self)
