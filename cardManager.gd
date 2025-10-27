extends Node2D

const COLLISION_MASK_CARD: int = 1
const CARD_SIZE_X: float = 283
const CARD_SIZE_Y: float = 200
const MOUSE_CENTER_OFFSET_X: float = -40
const MOUSE_CENTER_OFFSET_Y: float = 20

var currentTopZIndex: int = 0
var cardDraggedID
var screenSize

func _ready() -> void:
	screenSize = get_viewport_rect().size

func _process(_delta: float) -> void:
	drag_card_logic() # por enquanto o card manager verifica só isso no void loop

# Essa função implementa o raycast próprio do GODOT do que está abaixo do mouse e retorna a referência do node do card selecioando	
func check_for_card():
	var spaceState = get_world_2d().direct_space_state
	var raycastParameters = PhysicsPointQueryParameters2D.new()
	raycastParameters.position = get_global_mouse_position()
	raycastParameters.collide_with_areas = true
	raycastParameters.collision_mask = COLLISION_MASK_CARD
	var cardRaycastList = spaceState.intersect_point(raycastParameters)
	# aqui abaixo, eu já consegui a array de cards abaixo do mouse, mas aplico um filtro para realmente só selecionar o card do topo da pilha
	if (cardRaycastList.size() > 0):
		var highestZCard = cardRaycastList[0].collider.get_parent()
		var highestZIndex = highestZCard.z_index # z_index é o índice de camada do GODOT, naipe photoshop
		for i in range(1, cardRaycastList.size()):
			var currentCard = cardRaycastList[i].collider.get_parent()
			if currentCard.z_index > highestZIndex:
				highestZCard = currentCard
				highestZIndex = currentCard.z_index
		return highestZCard
	else:
		return null

func _input(event):
	# uma vez que eu cliquei, ativa o evento, não repetindo o processo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true: 
			var card = check_for_card()
			if (card != null):
				cardDraggedID = card
				currentTopZIndex += 1 # aqui é só pra garantir que o card que está sendo arrastado ficará acima de qualquer outro na tela
				card.z_index = currentTopZIndex
		else:
			cardDraggedID = null

# Essa função pega a posição do mouse e aplica um offset para centralizar no card, e então restringe a posição do mouse (clamp) para não escapar da tela
func drag_card_logic() -> void:
	if (cardDraggedID != null): 
		var mousePos = get_global_mouse_position() + Vector2(-((CARD_SIZE_X/2)+MOUSE_CENTER_OFFSET_X),-((CARD_SIZE_Y/2)+MOUSE_CENTER_OFFSET_Y))
		cardDraggedID.position = Vector2(clamp(mousePos.x, -100, (screenSize.x-100)), clamp(mousePos.y, -100, (screenSize.y-100)))
