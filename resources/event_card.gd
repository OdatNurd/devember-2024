class_name EventCard extends GenericCard

## The resouce type for event cards

## -----------------------------------------------------------------------------


## For an event card, the different kinds of allowable events
enum EventType { NONE, POLICE, PIRATE, INVADER }

## For an event card, the type of emergency jump that is allowed.
## When making an emergency jump, this indicates what kind of jump this is
enum JumpType { SAFE, MISJUMP }


## -----------------------------------------------------------------------------


## The type of event this is
@export var event_type := EventType.NONE

## The type of emergency jump that can be executed from here
@export var jump_type := JumpType.SAFE

## The base aggression factor for pirates during this event
@export var agression := 1

## The base defensive factor for pirates during this event
@export var defensive := 1

## The multiplier for fines during this event
@export var fine_multiplier := 1

## The buy/sell cost of agriculturals at this planet
@export var agriculturals : Vector2i

## The buy/sell cost of weapons at this planet
@export var weapons : Vector2i

## The buy/sell cost of industrials at this planet
@export var industrials : Vector2i

## The buy/sell cost of illegals at this planet
@export var illegals : Vector2i


## -----------------------------------------------------------------------------


## Return a textual version of the cards event type name, suitable for display
## in debug messages and the like.
func event_type_name() -> String:
    match event_type:
        EventType.NONE:
            return "None"
        EventType.POLICE:
            return "Police"
        EventType.PIRATE:
            return "Pirate"
        EventType.INVADER:
            return "Invader"
        _:
            return "???"


## Return a textual version of the cards event type name, suitable for display
## in debug messages and the like.
func jump_type_name() -> String:
    match jump_type:
        JumpType.SAFE:
            return "Safe"
        JumpType.MISJUMP:
            return "Misjump"
        _:
            return "???"

func dump():
    super.dump()
    print("Event Type: %s" % event_type_name())
    print("Jump Type: %s" % jump_type_name())
    print("Pirate Agression: %d" % agression)
    print("Pirate Defense: %d" % defensive)
    print("Fine Multiplier: %d" % fine_multiplier)
    print("Agriculturals: %s" % agriculturals)
    print("Weapons: %s" % weapons)
    print("Industrials: %s" % industrials)
    print("Illegals: %s" % illegals)
    print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")


## -----------------------------------------------------------------------------
