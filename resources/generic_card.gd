extends Resource
class_name GenericCardResource

## The generic base resource for all cards in the game

## -----------------------------------------------------------------------------


## The different types of card resources that there can be
enum CardType { PLANET, EVENT }

## For an event card, the different kinds of allowable events
enum EventType { NONE, POLICE, PIRATE, INVADER }

## For an event card, the type of emergency jump that is allowed.
## When making an emergency jump, this indicates what kind of jump this is
enum JumpType { SAFE, MISJUMP }


## -----------------------------------------------------------------------------


## The image of this card to use on its sprite when it is face up
@export var front_image : Texture

## The image of this card to use on its sprite when it is face down
@export var back_image : Texture

## The name of the card
@export var name := "card_name"

## The type of card that this is
@export var card_type := CardType.PLANET


## -----------------------------------------------------------------------------


## Returns True if this resource represents a planet card, false otherwise
func is_planet() -> bool:
    return card_type == CardType.PLANET

## Returns True if this resource represents an event card, false otherwise
func is_event() -> bool:
    return card_type == CardType.EVENT


## Dump information about this card to the console
func dump():
    print("Card: %s" % name)
    print("Is Planet: %s" % is_planet())
    print("Is Event: %s" % is_event())


## -----------------------------------------------------------------------------
