@tool
extends Area2D

## -----------------------------------------------------------------------------

# If the token is asked to display either a front or back side but there is no
# such texture, this is the texture used; it is obnoxious to look at but allows
# people to know that there is something missing.
@onready var _missing_placeholder : Texture = load('res://assets/placeholder_missing.png')

## -----------------------------------------------------------------------------


# All tokens in the game have a facing that is either face up or face down,
# which visibly is used to indicate which of the two textures is used to draw
# the token.
enum TokenOrientation {
    ## The token is placed such that front texture is visible.
    FACE_UP,

    ## The token is placed such that the back texture is visible.
    FACE_DOWN
}


## -----------------------------------------------------------------------------


@export_group("Token Details", "token")

## The texture for the front side of the token.
@export var token_front : Texture:
    set(value):
        print("Setting token front texture")
        if value != token_front:
            token_front = value
            if token_facing == TokenOrientation.FACE_UP:
                set_texture(token_front)
            update_configuration_warnings()

## The texture for the back side of the token; if this is
## not set, the token assumes that the back side and the
## front side are the same, and uses the front texture
## for the back.
@export var token_back : Texture:
    set(value):
        print("Setting token back texture")
        if value != token_back:
            token_back = value
            if token_facing == TokenOrientation.FACE_DOWN:
                set_texture(token_back)
            update_configuration_warnings()

## Which orientation the token is in
@export var token_facing : TokenOrientation:
    set(value):
        print("Setting the token orientation")
        if value != token_facing:
            token_facing = value

            # The token facing might get set when we're not fully available
            # yet (presumably since its data type is intrinsic and not something
            # that needs to be deferred to runtime). For that reason, don't
            # fiddle the texture if we're not in the tree yet.
            if not is_inside_tree():
                return

            match token_facing:
                TokenOrientation.FACE_UP:
                    set_texture(token_front)
                TokenOrientation.FACE_DOWN:
                    set_texture(token_back)


## -----------------------------------------------------------------------------


# This is called by Godot in the editor in order in order to collect a list of
# warnings to be displayed next to nodes in the editor to provide hints that
# someone is using them wrong.
func _get_configuration_warnings():
    var warnings = []

    # The token always requires at a minimum a front texture.
    if token_front == null:
        warnings.append("Token does not have a front texture applied")

    # The back texture is optional, but if there is one it should have the same
    # dimensions as the front texture, since the bounds of the texture control
    # the area used to interact with the token.
    if token_back != null and token_front != null and token_back.get_size() != token_front.get_size():
        warnings.append("Token front and back textures are not the same size")

    return warnings


## -----------------------------------------------------------------------------


# Given a passed in texture value, set the texture for the child node that is
# used to visualy represent us to use that texture, as well as changing the
# bounding rectangle for the object such that it has the same size.
func set_texture(value: Texture) -> void:
    print("Setting the internal texture value")
    if $Texture == null:
        print("Cannot set texture; node is not ready yet")
        return
    if value == null:
        print("There is no defined texture for this facing")
        value = _missing_placeholder
    $Texture.texture = value
    $Collider.shape.set_size(value.get_size())


## -----------------------------------------------------------------------------


func _ready() -> void:
    print("The node is ready")


## -----------------------------------------------------------------------------
