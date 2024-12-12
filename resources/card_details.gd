class_name CardDetails extends Resource


## This class represents the details that are shared by all cards in the game,
## regardless of their type and purpose. This is meant to be composed with an
## instance of the TokenDetails resource, to provide the whole property set for
## a card.


## -----------------------------------------------------------------------------


## The different types of card resources that there can be
enum CardType { NONE, PLANET, EVENT }


## -----------------------------------------------------------------------------


## The type of card that this is; this is not exported because it's intrinsic to
## the concrete card type, which will alter it as needed.
var card_type := CardType.NONE


## -----------------------------------------------------------------------------


## Returns True if this resource represents a planet card, false otherwise
func is_planet() -> bool:
    return card_type == CardType.PLANET


## -----------------------------------------------------------------------------


## Returns True if this resource represents an event card, false otherwise
func is_event() -> bool:
    return card_type == CardType.EVENT


## -----------------------------------------------------------------------------


## Return a textual version of the card type's name, suitable for display in
## debug messages and the like.
func card_type_name() -> String:
    match card_type:
        CardType.NONE:
            return "None"
        CardType.PLANET:
            return "Planet"
        CardType.EVENT:
            return "Event"
        _:
            return "???"


## -----------------------------------------------------------------------------


## Dump information about this token to the console for debug purposes.
func dump():
    print("Card: %s" % card_type_name())


## -----------------------------------------------------------------------------
