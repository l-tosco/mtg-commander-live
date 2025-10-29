extends Node2D

const HAND_COUNT: int = 6
const CARD_SCENE_PATH: String = "res://Scenes/card.tscn"
const CARD_WIDTH: int = 100
const HAND_Y_POSITION = 590

var playerHand = []
var screenCenterX: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenCenterX = (get_viewport().size.x / 2)
	var cardScene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var newCard = cardScene.instantiate()
		$/root/main/cardManager.add_child(newCard)
		newCard.name = "card"
		add_card_to_hand(newCard)

func add_card_to_hand(card):
	if (card != null):
		if (card not in playerHand):
			playerHand.insert(0, card)
			update_hand_positions()
		else:
			animate_card_to_position(card, card.startingPosition)
	
func update_hand_positions():
	for i in range(playerHand.size()):
		var newHandPosition = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = playerHand[i]
		card.startingPosition = newHandPosition
		animate_card_to_position(card, newHandPosition)

func calculate_card_position(index):
	var handWidth = floor((((playerHand.size() - 1.0) * CARD_WIDTH) / 2.0))
	var handXOffset = ((screenCenterX + (index * CARD_WIDTH)) - handWidth) - (CARD_WIDTH / 2.0)
	return handXOffset

func animate_card_to_position(card, newHandPosition):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newHandPosition, 0.1)
	
func remove_card_from_hand(card):
	if (card in playerHand):
		playerHand.erase(card)
		update_hand_positions()
