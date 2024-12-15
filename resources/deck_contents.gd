class_name DeckLayout extends Resource


## The resource that is used to configure the initial contents of a deck of
## cards.


## -----------------------------------------------------------------------------


## The scene that represents the type of card that this deck should contain.
@export var card_scene: PackedScene

## The cards that should appear in this scene.
@export var cards: Array[DeckCard]

## Should this deck shuffle its contents when it initializes. When this is
## false, the cards in the deck will be kept in this order.
@export var shuffled := true


## -----------------------------------------------------------------------------
