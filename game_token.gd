@tool
extends Area2D

## -----------------------------------------------------------------------------


## The mouse has entered a GameToken
signal token_mouse_in(token: Node2D)

## The mouse has exited a GameToken
signal token_mouse_out(token: Node2D)

## Signal that a token has been grabbed or released
signal token_grabbed_or_dropped(token: Node2D, grabbed: bool)


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
        if value != token_front:
            token_front = value
            if token_facing == TokenOrientation.FACE_UP:
                set_texture_for_facing(token_facing)
            update_configuration_warnings()

## The texture for the back side of the token; if this is
## not set, the token assumes that the back side and the
## front side are the same, and uses the front texture
## for the back.
@export var token_back : Texture:
    set(value):
        if value != token_back:
            token_back = value
            if token_facing == TokenOrientation.FACE_DOWN:
                set_texture_for_facing(token_facing)
            update_configuration_warnings()

## Which orientation the token is in
@export var token_facing := TokenOrientation.FACE_UP:
    set(value):
        if value != token_facing:
            token_facing = value
            set_texture_for_facing(token_facing)
            update_configuration_warnings()

## The amount of padding that the texture has around its edges to allow for the
## selection hilight; this is the total number of empty pixels on each axis;
## e.g. 8 pixels around all edges is a padding of 16
@export var token_padding := 16

## Name for this token; this is used in debug logging and the like to be able
## to determine what token is being worked on.
@export var token_name := 'Token'


## -----------------------------------------------------------------------------


# Whether or not this token is "active"; a token is considered active when it
# has the mouse focus.
var is_active := false

# Whether or not this token is "grabbed"; if it is grabbed then it tracks where
# the mouse moves and moves itself to that position.
var is_grabbed := false

# The outline width applied by the shader that marks us as being the active
# token. A value of 0 means no outline.
var outline_width := 0

# The "normal" scale of this token; what the scale is set to when it is not
# being hovered over by the mouse.
@onready var normal_scale := scale


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


# Given a passed in token facing, set the texture for the child node that is
# used to visualy represent us to use the texture for that facing, as well as
# changing the bounding rectangle for the object such that it has the same size.
func set_texture_for_facing(facing: TokenOrientation):
    # We get called when properties change, and not all property changes happen
    # when we're actively a part of the scene tree.
    if not is_node_ready():
        return

    # Determine the texture to use based on the facing provided
    var texture: Texture = token_front if facing == TokenOrientation.FACE_UP else token_back
    if texture == null:
        print("There is no defined texture for this facing!")
        texture = _missing_placeholder

    $Texture.texture = texture
    $Collider.shape.set_size(texture.get_size() - Vector2(token_padding, token_padding))


## -----------------------------------------------------------------------------


# Change the orientation of the token such that if it's face up it goes face
# down and vice versa.
func flip_token() -> void:
    if token_facing == TokenOrientation.FACE_UP:
        token_facing = TokenOrientation.FACE_DOWN
    else:
        token_facing = TokenOrientation.FACE_UP


## -----------------------------------------------------------------------------


func _ready() -> void:
    # When we're ready, set the texture based on our current facing.
    set_texture_for_facing(token_facing)
    normal_scale = scale

## -----------------------------------------------------------------------------


# When the mouse enters or exits a token, emit a signal so that interested
# parties can tell which token has the "mouse focus"
func _mouse_enter_exit_state_change(entered: bool) -> void:
    if entered:
        token_mouse_in.emit(self)
    else:
        token_mouse_out.emit(self)



func activate() -> void:
    is_active = true
    outline_width = $Texture.material.get_shader_parameter("width")
    $Texture.material.set_shader_parameter("width", 5)
    #$Texture.modulate = Color(Color.LIGHT_GREEN, 0.75)


func deactivate() -> void:
    is_active = false
    is_grabbed = false
    $Texture.material.set_shader_parameter("width", outline_width)

    #$Texture.modulate = Color.WHITE
    scale = normal_scale

## -----------------------------------------------------------------------------


# This is the weird dildo fight of input; as far as input is concerned, it gets
# everything everywhere all at once.
func _input(event: InputEvent):
    # Don't consume any input events if this node is not the active node
    if not is_active:
        return

    # If we are currently grabbed and this is a mouse motion event, then we want
    # to change our location to the mouse location.
    if is_grabbed == true and event is InputEventMouseMotion:
        position = event.position

    # Grab or drop the token via the left mouse button; uses the press state to
    # know what to do. We don't use an input action for this because it might
    # end up accidentally mapped to a key. Also is_action_pressed() seems to
    # only return true for the first frame this happens in, and then it starts
    # reporting as unpressed, which would screw up dragging.
    if event is InputEventMouseButton and event.button_index == 1:
        is_grabbed = event.pressed
        if is_grabbed == true:
            $Texture.modulate = Color(Color.FOREST_GREEN, 0.75)
            move_to_front()
        else:
            $Texture.modulate = Color(Color.LIGHT_GREEN, 0.75)
        token_grabbed_or_dropped.emit(self, is_grabbed)

    # Flip the token front to back; via keyboard or right click.
    elif event.is_action_pressed("token_flip"): # W or right mouse button
        flip_token()

    # Zoom the token in somewhat for easier viewing
    elif event.is_action_pressed("token_zoom") or event.is_action_released("token_zoom"): # S or middle button click
        scale = Vector2(0.50, 0.50) if event.is_action_pressed("token_zoom") else normal_scale

    # Rotate to the left or right 90 degrees
    elif event.is_action_pressed("token_rotate_left") or event.is_action_pressed("token_rotate_right"): # A,D
        var change := PI / 2 if event.is_action_pressed("token_rotate_right") else -PI / 2
        rotation += change

    # Reset token rotation back to the default; leaves the flip state alone
    elif event.is_action_pressed("token_reset"): # R
        rotation = 0;


## -----------------------------------------------------------------------------
