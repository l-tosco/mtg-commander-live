extends Node2D

const COLLISION_MASK_CARD: int = 1
const CARD_SIZE_X: float = 141
const CARD_SIZE_Y: float = 100
const MOUSE_CENTER_OFFSET_X: float = -20
const MOUSE_CENTER_OFFSET_Y: float = 10

enum collisionMask {
	cardMask = 1,
	cardSlotMask = 2
}

var isHovering: bool = false
var currentTopZIndex: int = 0
var cardDraggedID
var screenSize
var playerHandRef

func _ready() -> void:
	screenSize = get_viewport_rect().size
	playerHandRef = $"../playerHand"

func _process(_delta: float) -> void:
	drag_card_logic() # por enquanto o card manager verifica só isso no void loop

# Essa função implementa o raycast próprio do GODOT do que está abaixo do mouse e retorna a referência do node do card selecioando	
func check_for_card(objectCollisionMask):
	var spaceState = get_world_2d().direct_space_state
	var raycastParameters = PhysicsPointQueryParameters2D.new()
	raycastParameters.position = get_global_mouse_position()
	raycastParameters.collide_with_areas = true
	raycastParameters.collision_mask = objectCollisionMask
	var cardRaycastList = spaceState.intersect_point(raycastParameters)
	# aqui abaixo, eu já consegui a array de cards abaixo do mouse, mas aplico um filtro para realmente só selecionar o card do topo da pilha
	if (cardRaycastList.size() > 0):
		if (objectCollisionMask == 1):
			var highestZCard = cardRaycastList[0].collider.get_parent()
			var highestZIndex = highestZCard.z_index # z_index é o índice de camada do GODOT, naipe photoshop
			for i in range(1, cardRaycastList.size()):
				var currentCard = cardRaycastList[i].collider.get_parent()
				if currentCard.z_index > highestZIndex:
					highestZCard = currentCard
					highestZIndex = currentCard.z_index
			return highestZCard
		if (objectCollisionMask == 2):
			return cardRaycastList[0].collider.get_parent()
	else:
		return null

func _input(event):
	# uma vez que eu cliquei, ativa o evento, não repetindo o processo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true: 
			var activeCard = check_for_card(collisionMask.cardMask)
			if (activeCard != null):
				cardDraggedID = activeCard
				currentTopZIndex += 1 # aqui é só pra garantir que o card que está sendo arrastado ficará acima de qualquer outro na tela
				activeCard.z_index = currentTopZIndex
				activeCard.scale = Vector2(0.5,0.5)
		else:
			var cardSlotFound = check_for_card(collisionMask.cardSlotMask)
			if ((cardSlotFound != null) and (cardSlotFound.cardInSlot == false)):
				playerHandRef.remove_card_from_hand(cardDraggedID)
				cardDraggedID.position = cardSlotFound.position
				cardDraggedID.get_node("cardArea/CollisionShape2D").disabled = true
				cardSlotFound.cardInSlot = true
			else:
				playerHandRef.add_card_to_hand(cardDraggedID)
			if (cardDraggedID != null): #preciso checar de novo pois se o click for rapido demais, a ref some antes de setar a escala e crasha o jogo...
				cardDraggedID.scale = Vector2(0.6, 0.6)
				cardDraggedID = null

func connect_card_signals(card):
	# os sinais pararam de funcionar agora que está instanciado, não esquecer
	card.connect("mouseIn", Callable(self, "mouse_in_card"))
	card.connect("mouseOff", Callable(self, "mouse_off_card"))
	
func mouse_in_card(card):
	if (isHovering == false):
		isHovering = true
		highlight_card(card, true)
		
func mouse_off_card(card):
	if (cardDraggedID == null):
		highlight_card(card, false)
		card = check_for_card(collisionMask.cardMask)
		if (card != null):
			highlight_card(card, true)
		else:
			isHovering = false

func highlight_card(card, mouseIn):
	if mouseIn == true:
		card.scale = Vector2(0.6, 0.6)
	else:
		card.scale = Vector2(0.5,0.5)

# Essa função pega a posição do mouse e aplica um offset para centralizar no card, e então restringe a posição do mouse (clamp) para não escapar da tela
func drag_card_logic() -> void:
	if (cardDraggedID != null): 
		var mousePos = get_global_mouse_position() + Vector2(-((CARD_SIZE_X/2)+MOUSE_CENTER_OFFSET_X),-((CARD_SIZE_Y/2)+MOUSE_CENTER_OFFSET_Y))
		cardDraggedID.position = Vector2(clamp(mousePos.x, -100, (screenSize.x-100)), clamp(mousePos.y, -100, (screenSize.y-100)))
