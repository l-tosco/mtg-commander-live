extends Node2D

signal mouseIn
signal mouseOff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_card_area_mouse_entered() -> void:
	emit_signal("mouseIn", self)

func _on_card_area_mouse_exited() -> void:
	emit_signal("mouseOff", self)
