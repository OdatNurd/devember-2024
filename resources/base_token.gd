class_name BaseTokenDetails extends Resource

## The generic set of resources that are requires for any particular token in
## the game, regardless of what type of token it is.


## -----------------------------------------------------------------------------


## The type of token that this is.
enum TokenType { NONE, CARD }


## -----------------------------------------------------------------------------


## The name of the card
@export var name := "token_name"

## The type of token that this is
@export var token_type := TokenType.NONE

## The image of this card to use on its sprite when it is face up
@export var front_image : Texture

## The image of this card to use on its sprite when it is face down
@export var back_image : Texture


## -----------------------------------------------------------------------------


## Return a textual version of the cards event type name, suitable for display
## in debug messages and the like.
func token_type_name() -> String:
    match token_type:
        TokenType.NONE:
            return "None"
        TokenType.CARD:
            return "Card"
        _:
            return "???"

## Dump information about this card to the console
func dump():
    print("Token: %s" % name)
    print("Type: %s" % token_type)


## -----------------------------------------------------------------------------
