class_name BaseToken extends Resource

## The generic set of resources that are requires for any particular token in
## the game, regardless of what type of token it is.


## -----------------------------------------------------------------------------


## The image of this card to use on its sprite when it is face up
@export var front_image : Texture

## The image of this card to use on its sprite when it is face down
@export var back_image : Texture

## The name of the card
@export var name := "token_name"


## -----------------------------------------------------------------------------

## Dump information about this card to the console
func dump():
    print("Token: %s" % name)


## -----------------------------------------------------------------------------
