class_name TokenDetails extends Resource

## This class represents the details that are shared by all tokens in the game,
## regardless of their type and purpose.


## -----------------------------------------------------------------------------


## This lists the distinct types of tokens that the game provides. This is
## stored as part of the intrinsic resource information for the token.
enum TokenType { NONE, CARD, DECK, PILE, PLAYER_AID, MARKER }


## -----------------------------------------------------------------------------


## The name of the token.
@export var name := "token_name"

## The type of token that this is.
@export var token_type := TokenType.NONE

## The image of this token to use on its sprite when it is face up.
@export var front_image : Texture

## The image of this token to use on its sprite when it is face down.
@export var back_image : Texture


## Whether or not this token can be activated; activated means that when
## hovering over it, it gains a green outline highlight. Tokens must be
## activated to accept input.
@export var can_activate := true

## Whether or not this token responds to being flipped over. Requires the token
## to be activated.
@export var can_flip := true

## Whether or not this token responds to being rotated. Requires the token
## to be activated.
@export var can_rotate := true

## Whether or not this token responds to being grabbed. Requires the token
## to be activated.
@export var can_grab := true

## Whether or not this token responds to being zoomed. Requires the token
## to be activated.
@export var can_zoom := true


## -----------------------------------------------------------------------------


## Return a textual version of the token name, suitable for display
## in debug messages and the like.
func token_type_name() -> String:
    match token_type:
        TokenType.NONE:
            return "None"
        TokenType.CARD:
            return "Card"
        TokenType.DECK:
            return "Deck"
        TokenType.PILE:
            return "Pile"
        TokenType.PLAYER_AID:
            return "Player Aid"
        TokenType.MARKER:
            return "Marker"
        _:
            return "???"


## -----------------------------------------------------------------------------


func _to_string() -> String:
    return "[Token Details: name='%s' type='%s' (%s)]" % [name, token_type_name(), resource_path]


## -----------------------------------------------------------------------------


## Dump information about this token to the console for debug purposes.
func dump():
    print("Token: %s (%s)" % [name, token_type_name()])


## -----------------------------------------------------------------------------
