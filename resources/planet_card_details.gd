class_name PlanetCardDetails extends CardDetails


## This class represents the details that are specific to planet  cards in the
## game. Since this subclasses CardDetails, it also contains the details shared
## by all cards in the game, regardless of their type and purpose. This is meant
## to be composed with an instance of the TokenDetails resource, to provide the
## whole property set for a card.


## -----------------------------------------------------------------------------


## The travel distance to the planet (paid in Vectorium).
@export var distance := 0

## The relative cost of agriculturals at this planet.
@export var agriculturals := 0

## The relative cost of weapons at this planet.
@export var weapons := 0

## The relative cost of industrials at this planet.
@export var industrials := 0

## The relative cost of illegals at this planet.
@export var illegals := 0

## The police presence on this planet.
@export var police := 0


## -----------------------------------------------------------------------------


## Initialize an instance of the resouce by setting in an explicit value for the
## card type based on the type of resource this is.
func _init():
    card_type = CardType.PLANET


## -----------------------------------------------------------------------------


## Dump information about this token to the console for debug purposes.
func dump():
    super.dump()
    print("Distance: %d" % distance)
    print("Police: %d" % police)
    print("Agriculturals: %d" % agriculturals)
    print("Weapons: %d" % weapons)
    print("Industrials: %d" % industrials)
    print("Illegals: %d" % illegals)
    print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")


## -----------------------------------------------------------------------------
