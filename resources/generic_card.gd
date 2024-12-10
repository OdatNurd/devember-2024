class_name GenericCard extends BaseToken

## The generic base resource for all cards in the game.


## -----------------------------------------------------------------------------

## The different types of card resources that there can be
enum CardType { NONE, PLANET, EVENT }


## -----------------------------------------------------------------------------


## The type of card that this is; this is not exported because it's intrinsic to
## the card type.
var card_type := CardType.NONE


## -----------------------------------------------------------------------------


## Returns True if this resource represents a planet card, false otherwise
func is_planet() -> bool:
    return card_type == CardType.PLANET


## Returns True if this resource represents an event card, false otherwise
func is_event() -> bool:
    return card_type == CardType.EVENT


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

## Dump information about this card to the console
func dump():
    super.dump()
    print("Type: Card (%s)" % card_type_name())


## -----------------------------------------------------------------------------
