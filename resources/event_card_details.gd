class_name EventCard extends CardDetails


## This class represents the details that are specific to event cards in the
## game. Since this subclasses CardDetails, it also contains the details shared
## by all cards in the game, regardless of their type and purpose. This is meant
## to be composed with an instance of the TokenDetails resource, to provide the
## whole property set for a card.


## -----------------------------------------------------------------------------


## The different types of event cards that are allowed within the game. Each has
## specific rules for how they are resolved.
enum EventType { NONE, POLICE, PIRATE, INVADER }

## All event cards have an emergency jump section on them that describe what
## happens if the player has to jump away in the middle of an encounter. This
## specifies the various jump types.
enum JumpType { SAFE, MISJUMP }


## -----------------------------------------------------------------------------


## The event card type.
@export var event_type := EventType.NONE

## The type of emergency jump that can be executed from here.
@export var jump_type := JumpType.SAFE

## The base aggression factor for pirates during this event.
@export var agression := 1

## The base defensive factor for pirates during this event.
@export var defensive := 1

## The multiplier for fines during this event.
@export var fine_multiplier := 1

## The buy/sell cost of agriculturals at this planet.
@export var agriculturals : Vector2i

## The buy/sell cost of weapons at this planet.
@export var weapons : Vector2i

## The buy/sell cost of industrials at this planet.
@export var industrials : Vector2i

## The buy/sell cost of illegals at this planet.
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


## -----------------------------------------------------------------------------


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


## -----------------------------------------------------------------------------


## Dump information about this token to the console for debug purposes.
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
