## The resouce type for event cards
extends GenericCardResource
class_name EventCardStats


## -----------------------------------------------------------------------------


## The type of event this is
@export var event_type := EventType.NONE

## The type of emergency jump that can be executed from here
@export var jump := JumpType.SAFE

## The base aggression factor for pirates during this event
@export var agression := 0

## The base defensive factor for pirates during this event
@export var defensive := 0

## The multiplier for fines during this event
@export var fine_multiplier := 0

## The buy/sell cost of agriculturals at this planet
@export var agriculturals : Vector2i

## The buy/sell cost of weapons at this planet
@export var weapons : Vector2i

## The buy/sell cost of industrials at this planet
@export var industrials : Vector2i

## The buy/sell cost of illegals at this planet
@export var illegals : Vector2i


## -----------------------------------------------------------------------------


func dump():
    super.dump()
    print("Event Type: %d" % event_type)
    print("Jump Type: %d" % jump)
    print("Pirate Agression: %d" % agression)
    print("Pirate Defense: %d" % defensive)
    print("Fine Multiplier: %d" % fine_multiplier)
    print("Agriculturals: %s" % agriculturals)
    print("Weapons: %s" % weapons)
    print("Industrials: %s" % industrials)
    print("Illegals: %s" % illegals)
    print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")


## -----------------------------------------------------------------------------
