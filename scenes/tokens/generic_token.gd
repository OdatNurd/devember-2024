@tool
class_name GenericToken extends Area2D


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
#
# TODO: This should be global and not per-node, since we're padding it out. Not
#       sure how to pull that off though since padding is token specific; maybe
#       we demand load the placeholder, or only pad it the first time it's
#       actually referenced?
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


## The underlying statistics and information for this game token
@export var stats : GenericCard:
    set(value):
        stats = value
        set_texture_for_facing(token_facing)


## Which orientation the token is in
@export var token_facing := TokenOrientation.FACE_UP:
    set(value):
        if value != token_facing:
            token_facing = value
            set_texture_for_facing(token_facing)
            update_configuration_warnings()

## The amount of padding that the texture has around its edges to allow for the
## selection hilight; this is the total number of empty pixels on each axis;
## e.g. a value of 8 pixels here is a final value of 16 pixels total.
@export var token_padding := 16

## When this token is activated, create an outline of this width
@export var token_outline_width := 25

## -----------------------------------------------------------------------------


# Whether or not this token is "active"; a token is considered active when it
# has the mouse focus.
var is_active := false

# Whether or not this token is "grabbed"; if it is grabbed then it tracks where
# the mouse moves and moves itself to that position.
var is_grabbed := false

# The "normal" scale of this token; what the scale is set to when it is not
# being hovered over by the mouse.
@onready var normal_scale := scale


## -----------------------------------------------------------------------------


# This is called by Godot in the editor in order in order to collect a list of
# warnings to be displayed next to nodes in the editor to provide hints that
# someone is using them wrong.
func _get_configuration_warnings():
    var warnings = []

    # If we have no stats object, first of all that's a problem. And secondly,
    # we can't check anything else because we check stat objects, so we can just
    # return back in this case.
    if stats == null:
        warnings.append("Token does not have card statistics attached")
        return warnings

    # The token always requires at a minimum a front texture.
    if stats.front_image == null:
        warnings.append("Token does not have a front texture applied")

    # The back texture is optional, but if there is one it should have the same
    # dimensions as the front texture, since the bounds of the texture control
    # the area used to interact with the token.
    if stats.back_image != null and stats.front_image != null and stats.back_image.get_size() != stats.front_image.get_size():
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

    # Determine the texture to use based on the facing provided; this is either
    # the front or back texture, BUT we can only do this if we have the proper
    # stats object to query.
    var texture: Texture = null
    if stats != null:
        texture = stats.front_image if facing == TokenOrientation.FACE_UP else stats.back_image
    if texture == null:
        print("There is no defined texture for this facing!")
        texture = _missing_placeholder

    # Since our textures are padded out on the sides, in order to set the
    # collision rectangle at the right side, we need to adjust the size of the
    # collision bounds.
    var collision_adj = Vector2(token_padding * 2, token_padding * 2)

    # If we're in the editor, we want to grow the bounds to show how big the
    # actual token will be if someone hovers it, which helps with alignment.
    # In the actual game, we want to shrink.
    if Engine.is_editor_hint():
        collision_adj *= -1

    $Texture.texture = texture
    $Collider.shape.set_size(texture.get_size() - collision_adj)


## -----------------------------------------------------------------------------


# This takes an input texture and creates a new version of it that is grown in
# all four directions based on the padding set in the node. The new texture is
# first filled with transparency and then the original texture is drawn into it
# offset by the padding distance.
#
# This causes the token texture to be surrounded by alpha, which allows our
# shader to show an activation rectangle around it.
#
# Since this node is a tool script as well, while we're in the editor we just
# return the input texture directly without changing it. Otherwise the editor
# will notice the change and will pad the texture again. Also this tends to make
# it inline the texture in the scene file, which is ginormous.
func pad_texture(in_texture: Texture2D) -> Texture2D:
    # If we're running in the editor, just return the original texture back;
    # otherwise the node will get updated in memory and that will be persisted
    # by the editor, which is no beuno.
    #
    # We also do this if there is no padding configured, since in that case
    # this is just a huge waste of time.
    if Engine.is_editor_hint() or token_padding <= 0:
        return in_texture

    # Capture the padding as a vector for later.
    var padding = Vector2(token_padding, token_padding)

    # Get the image that backs the texture as well as its size. Note that this
    # does a fetch from the graphics card, so it is costly to do it frequently.
    var image = in_texture.get_image()
    var img_size = image.get_size()

    # We require our textures to have transparency, since that is the whole
    # point of what we're doing. If there is not any alpha, convert the souirce.
    if image.detect_alpha() == Image.AlphaMode.ALPHA_NONE:
        #print("token texture has no transparency (format=%s); converting" % image.get_format())
        image.convert(Image.Format.FORMAT_RGBA8)

    # Create the destination image, which should be bigger than the original
    # in both directions based on the padding.
    # 2. Create a new image that is bigger than the input texture, with padding
    var new_image = Image.create_empty(
        img_size.x + (2 * padding.x),
        img_size.y + (2 * padding.y),
        true, image.get_format())
    new_image.fill(Color(Color.WHITE, 0.0))

    # Draw into the new image the original image from the texture, with a
    # padding offset on the upper left so that we get the appropriate padding.
    var src_rect = Rect2(Vector2(0, 0), img_size)
    new_image.blit_rect(image, src_rect, padding)

    # Create and return the texture now.
    return ImageTexture.create_from_image(new_image)


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
    # Pad out our tokens to have the appropriate border so we can activate them.
    # TODO: This should all be done in some global loader object of some sort or
    #       something, so that all textures are padded at once, at start time.
    #       this would include the placeholder that all nodes reference when a
    #       texture is missing.
    if stats != null:
        stats.front_image = pad_texture(stats.front_image)
        stats.back_image = pad_texture(stats.back_image)
    _missing_placeholder = pad_texture(_missing_placeholder)

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
    $Texture.material.set_shader_parameter("width", token_outline_width)


func deactivate() -> void:
    is_active = false
    is_grabbed = false
    $Texture.material.set_shader_parameter("width", 0)
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
            move_to_front()
            print("Moving card: %s" % stats.name)
        else:
            print("Dropped card")
            stats.dump()
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
