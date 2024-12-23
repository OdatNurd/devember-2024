@tool
class_name BaseToken extends Area2D


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


# The material that we apply to a token when it has the activation status.
@onready var _activation_material : Material = load("res://resources/materials/token_activation_material.tres")


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

## The unique ID of this token, if any; some types of tokens use this to mark
## their children so that they can be found easily. Can be empty in the general
## case.
@export var token_id : String

## The underlying statistics and information for this game token
@export var token_details : TokenDetails:
    set(value):
        token_details = value
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


## When zooming this token, what should the scale value be set to. If this is
## smaller than the scale of the token in the scene, it will shrink instead.
@export var token_zoom := 1.0


## -----------------------------------------------------------------------------

# A list of groups that this token should be added to when it enters the scene
# tree. By default this is always the _token group, since this is a token.
# This can be augmented at any point prior to us entering the tree to adjust
# the groups to have more or fewer members.
var _deferred_groups : Array[String] = ["_tokens"]

# Should we detect the mouse or not; when this is true, the collider that
# detects the mouse is enabled; otherwise it is disabled.
var detect_mouse := true :
    set(value):
        detect_mouse = value
        $Collider.disabled = not value

# Whether or not this token is "active"; a token is considered active when it
# has the mouse focus.
var is_active := false

# Whether or not this token is "grabbed"; if it is grabbed then it tracks where
# the mouse moves and moves itself to that position.
var is_grabbed := false

# Whenever a drag is started, this is calculated to be the offset between the
# mouse at the point where it started the drag and our internal position, so
# that when the mouse moves we can adjust accordingly.
var drag_offset : Vector2

# When a zoom happens, we get brought to the top of the view stack so that we
# are visible; when the zoom is removed, we need to go back. This stores our
# index amongst our siblings at the point at which the zoom started.
var pre_zoom_index : int

# When we do things like flip or rotate tokens, we use a Tween to generate the
# animation; We keep a single tween variable for this; when it is null, there
# is no tween currently in progress; otherwise it is the tween that is currently
# running. We use this to keep the tweens syncronous.
var state_tween : Tween = null

# When the token is added to the tree, these values are used to capture the
# spawn time settings for the token rotation, facing and scale. These are
# properties that can be adjusted when the player interacts, so these can be
# used to restore them back to their default values at any time.
var spawn_rotation : float
var spawn_position : Vector2
var spawn_scale : Vector2
var spawn_facing : TokenOrientation


## -----------------------------------------------------------------------------


# This is called by Godot in the editor in order in order to collect a list of
# warnings to be displayed next to nodes in the editor to provide hints that
# someone is using them wrong.
func _get_configuration_warnings():
    var warnings = []

    # If we have no token_details object, first of all that's a problem. And
    # secondly, we can't check anything else because we check stat objects, so
    # we can just return back in this case.
    if token_details == null:
        warnings.append("Token does not have card statistics attached")
        return warnings

    # The token always requires at a minimum a front texture.
    if token_details.front_image == null:
        warnings.append("Token does not have a front texture applied")

    # The back texture is optional, but if there is one it should have the same
    # dimensions as the front texture, since the bounds of the texture control
    # the area used to interact with the token.
    if token_details.back_image != null and token_details.front_image != null and token_details.back_image.get_size() != token_details.front_image.get_size():
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
    # token_details object to query.
    var texture: Texture = null
    if token_details != null:
        texture = token_details.front_image if facing == TokenOrientation.FACE_UP else token_details.back_image
    if texture == null:
        print("There is no defined texture for this facing!")
        push_warning("token flipped to a side that has no texture defined")
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
    # this is just a huge waste of time, and also when there is not actually a
    # texture to pad.
    if Engine.is_editor_hint() or token_padding <= 0 or in_texture == null:
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


## Takes a Callable which expects to be passed as its first argument an instance
## of Tween, and calls it to set up the tween.
##
## The return value of the Callable should be a boolean and should be True if
## there is actually an animation to play and False if there is not.
##
## This executor ensures that there is only ever one tween running at a time so
## that they don't step on each others toes.
func execute_tween(animation : Callable) -> void:
    # If there is currently a tween running, wait for it to finish first.
    if state_tween != null:
        await state_tween.finished

    # Create a new tween and then pass it off to the animation function we were
    # given to set it up. The return value indicates if we should try to execute
    # the animation or not; should be false if the tween has no steps, since
    # in that case the debugger gets all cranky.
    state_tween = get_tree().create_tween()
    var execute: bool =  animation.call(state_tween)

    # If we were asked to, let the tween execute and wait for it to finish;
    # otherwise just kill it before it starts.
    if execute:
        await state_tween.finished
    else:
        state_tween.kill()

    # Make sure that the tween is reset so we can be called again; when you
    # kill() a tween, you can't await it because it's not actualy running.
    state_tween = null


## -----------------------------------------------------------------------------


## Change the orientation of the token such that if it's face up it goes face
## down and vice versa.
func flip_token(tween : Tween) -> bool:
    var org_scale = scale.x
    var new_facing = (TokenOrientation.FACE_DOWN
                      if token_facing == TokenOrientation.FACE_UP
                      else TokenOrientation.FACE_UP)

    tween.tween_property(self, "scale:x", 0, 0.2).set_trans(Tween.TransitionType.TRANS_QUART)
    tween.tween_property(self, "token_facing", new_facing, 0.01)
    tween.tween_property(self, "scale:x", org_scale, 0.2).set_trans(Tween.TransitionType.TRANS_QUART)
    return true

## -----------------------------------------------------------------------------


## Rotate the token either clockwise or counter-clockwise by 90 degrees from its
## current rotation.
func rotate_token(tween: Tween, clockwise: bool) -> bool:
    var change := PI / 2 if clockwise else -PI / 2
    #tween.tween_property(self, "rotation", rotation + change, 0.2).set_trans(Tween.TransitionType.TRANS_QUART)
    tween.tween_property(self, "rotation", rotation + change, 0.5).set_trans(Tween.TransitionType.TRANS_ELASTIC).set_ease(Tween.EaseType.EASE_OUT)

    return true


## -----------------------------------------------------------------------------


## Change the current scale of the token from its current configuation to the
## scale passed in. The zoom is considered to be a zoom in or out depending on
## the state of the boolean. This is used to determine if we need to adjust the
## scene order of this token or not.
func scale_token(tween: Tween, zoom_in: bool, new_scale: Vector2) -> bool:
    # If the destination scale is the same as the current scale, there is
    # nothing to do.
    if new_scale == scale:
        return false

    # On a zoom in, save our position in the tree and jump to the top; on a zoom
    # out, put us back where we started.
    # If we're zooming in, start by saving the scene index and tweening a
    # change to bring us to the front.
    if zoom_in:
        pre_zoom_index = get_index()
        tween.tween_callback(move_to_front)
    else:
        tween.tween_callback(func (): if get_index() != pre_zoom_index: get_parent().move_child(self, pre_zoom_index))

    tween.tween_property(self, "scale", new_scale, 0.5).set_trans(Tween.TransitionType.TRANS_ELASTIC).set_ease(Tween.EaseType.EASE_OUT)

    return true


## -----------------------------------------------------------------------------


# Restore all of the token properties that can be manipulated by the player at
# runtime back to their spawn settings. This will selectively tween only those
# properties that have been changed.
func restore_token(tween: Tween) -> bool:
    # Count the number of restore operations we need to do
    var ops := 0

    # Do we need to return to our starting position?
    if position != spawn_position:
        ops += 1
        tween.tween_property(self, "position", spawn_position, 0.1).set_trans(Tween.TransitionType.TRANS_QUART)

    # Do we need to rotate back?
    if rotation != spawn_rotation:
        ops += 1
        tween.tween_property(self, "rotation", spawn_rotation, 0.15).set_trans(Tween.TransitionType.TRANS_QUART)

    # Do we need to flip the card back to its spawn side?
    if token_facing != spawn_facing:
        ops += 1
        var org_scale = scale.x
        var new_facing = (TokenOrientation.FACE_DOWN
                        if token_facing == TokenOrientation.FACE_UP
                        else TokenOrientation.FACE_UP)
        tween.tween_property(self, "scale:x", 0, 0.15).set_trans(Tween.TransitionType.TRANS_QUART)
        tween.tween_property(self, "token_facing", new_facing, 0.01)
        tween.tween_property(self, "scale:x", org_scale, 0.15).set_trans(Tween.TransitionType.TRANS_QUART)

    # Do we need to restore the scale of the card back to the original?
    if scale != spawn_scale:
        ops += 1
        tween.tween_property(self, "scale", spawn_scale, 0.2).set_trans(Tween.TransitionType.TRANS_QUART)

    # Only let the animation run if there is at least one operation to execute.
    return ops > 0


## -----------------------------------------------------------------------------


## Perform a simple wiggle of the card on the screen, to visually call it out.
func wiggle_card(tween: Tween, delay: float = 0.0) -> bool:
    var left = rotation + (-PI / 4)
    var right = rotation + (PI / 4)

    tween.tween_property(self, "rotation", left, 0.15).set_trans(Tween.TransitionType.TRANS_BOUNCE).set_ease(Tween.EaseType.EASE_IN_OUT).set_delay(delay)
    tween.tween_property(self, "rotation", right, 0.15).set_trans(Tween.TransitionType.TRANS_BOUNCE).set_ease(Tween.EaseType.EASE_IN_OUT)
    tween.tween_property(self, "rotation", left, 0.15).set_trans(Tween.TransitionType.TRANS_BOUNCE).set_ease(Tween.EaseType.EASE_IN_OUT)
    tween.tween_property(self, "rotation", rotation, 0.15).set_trans(Tween.TransitionType.TRANS_BOUNCE).set_ease(Tween.EaseType.EASE_IN_OUT)

    return true


## -----------------------------------------------------------------------------


## Move this node from the position and state that it is currently in to the
## designated position. This is done via an animation tween on the tween
## provided.
##
## Once the animation is complete, the token can optionally be told to save its
## new size and location as the default state that it will return to.
##
## This always makes sure that the token provided is first brought to the top
## of the scene and then made visible, so that the animation is always visible.
func move_card(tween: Tween,
               new_rotation: float, new_scale: Vector2, new_pos: Vector2,
               new_facing: TokenOrientation, new_visiblity: bool,
               save_state_on_finish: bool, start_delay: float = 0.0) -> bool:
    # Turn off mouse detection for the token, move it to the front of the stack,
    # and unhide it.
    tween.tween_property(self, "detect_mouse", false, 0.01).set_delay(start_delay)
    tween.tween_callback(move_to_front)
    tween.tween_property(self, "visible", true, 0.01)

    # Do we need to change the position of the token on the screen?
    if position != new_pos:
        tween.tween_property(self, "position", new_pos, 0.4).set_trans(Tween.TransitionType.TRANS_QUART)

    # Do we need to rotate to get into the right orientation?
    if rotation != new_rotation:
        tween.tween_property(self, "rotation", new_rotation, 0.15).set_trans(Tween.TransitionType.TRANS_QUART)

    # Do we need to flip the token to a different facing?
    if token_facing != new_facing:
        var org_scale = scale.x
        tween.tween_property(self, "scale:x", 0, 0.15).set_trans(Tween.TransitionType.TRANS_QUART)
        tween.tween_property(self, "token_facing", new_facing, 0.01)
        tween.tween_property(self, "scale:x", org_scale, 0.15).set_trans(Tween.TransitionType.TRANS_QUART)

    # Do we need to change the scale of the token
    if scale != new_scale:
        tween.tween_property(self, "scale", new_scale, 0.2).set_trans(Tween.TransitionType.TRANS_QUART)

    # If the token is supposed to be hidden, tween that now; if it's supposed to
    # visible, good news, it already is.
    if new_visiblity == false:
        tween.tween_property(self, "visible", new_visiblity, 0.01)

    # Turn mouse detection back on
    tween.tween_property(self, "detect_mouse", true, 0.01)

    # Are we supposed to save the state of this move as the new base state?
    if save_state_on_finish:
        tween.tween_callback(save_spawn_state)
    return true


## -----------------------------------------------------------------------------


# Capture the current position, rotation, scale and facing of this token so that
# it can be later restored.
func save_spawn_state() -> void:
    spawn_rotation = rotation
    spawn_position = position
    spawn_scale = scale
    spawn_facing = token_facing


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list.
func _enter_tree() -> void:
    # Don't register this token with the token manager if we're running in the
    # editor, since there the preload is not available.
    if Engine.is_editor_hint() == false:
        TokenManager.add_token(self)

    for group in _deferred_groups:
        add_to_group(group)


func _ready() -> void:
    # Pad out our tokens to have the appropriate border so we can activate them.
    # TODO: This should all be done in some global loader object of some sort or
    #       something, so that all textures are padded at once, at start time.
    #       this would include the placeholder that all nodes reference when a
    #       texture is missing.
    if token_details != null:
        token_details.front_image = pad_texture(token_details.front_image)
        token_details.back_image = pad_texture(token_details.back_image)
    _missing_placeholder = pad_texture(_missing_placeholder)

    # When we're ready, set the texture based on our current facing.
    set_texture_for_facing(token_facing)

    # Capture the spawn properties of the token so that they can be restored
    # later if desired.
    save_spawn_state()


## -----------------------------------------------------------------------------


## Given a vector that represents a position on the screen, determine whether or
## not that point is within the bounding rectangle of this token.
func is_point_inside(point: Vector2) -> bool:
    # Get the rectangle that bounds the token, and then convert the incoming
    # point into the local coordinate space of the collider.
    var bounds = $Collider.shape as RectangleShape2D
    var local_point = $Collider.global_transform.affine_inverse() * point

    # The location of the bounding box is at its center, so get the size and
    # split it in two so that we can see if we're within the range of points or
    # not.
    var half_extents = bounds.size / 2.0
    return abs(local_point.x) <= half_extents.x and abs(local_point.y) <= half_extents.y


## -----------------------------------------------------------------------------


## This assumes that we are being delivered an event to tell us that the mouse
## has either entered or exited our bounding rectangle, and returns whether or
## not we should handle that event.
##
## In particular, if there are multiple tokens sharing the same physical space,
## then only the token that is uppermost in the draw order (and thus lower in
## the tree) should handle the event; others should ignore it.
func _should_handle_mouse_state() -> bool:
    # Collect all of the areas that overlap with our token, if any; this is
    # directly calculated by the collision handler.
    #
    # This tells us only those areas whose bounds touch ours, even if they are
    # not currently candidates for a mouse enter/exit ecvent.
    #
    # If there are no such overlaps, then we should definitely handle the event.
    var overlaps : Array[Area2D] = get_overlapping_areas()
    if len(overlaps) == 0:
        return true

    # The is as least one overlap with us, so we need to double check if we
    # should be handling the event or not. Capture the current mouse location
    # and our index in the tree
    var mouse = get_viewport().get_mouse_position()
    var index = get_index()

    print_verbose("mouse position is %s" % str(mouse))
    print_verbose("%s:%s(%d) has %d overlaps; checking" % [name, token_details.name, index, len(overlaps)])

    # Scan over all of the tokens that overlap us. If we find any that should be
    # handling the event instead of us, the loop prematurely exits with a false
    # return value.
    for overlap: BaseToken in overlaps:
        print_verbose("  testing %s:%s(%d)" % [overlap.name, overlap.token_details.name, overlap.get_index()])

        # We can't conflict with nodes that are not actually visible on screen.
        if not overlap.visible:
            print_verbose("    not currently visible in the scene tree")
            continue

        # We don't conflict with things that are not tokens.
        if "token_details" not in overlap:
            print_verbose("    it does not appear to be a token")
            continue

        # If the other token does not have our parent, there's not a lot to
        # do, since our index is specific to our position under our parent.
        if get_parent() != overlap.get_parent():
            print_verbose("    has a different parent")
            continue

        # If the captured mouse position is not in the collion space for this
        # overlapped token, we don't need to consider it because it's not going
        # to trigger a competing event.
        if not overlap.is_point_inside(mouse):
            print_verbose("    mouse is not currently inside it")
            continue

        # This might compete with us; if it has a higher index, it's topmost on
        # the screen in relation to us, in which case we should not handle this
        # event.
        if overlap.get_index() > index:
            print_verbose("  token is above us; skipping this event")
            return false
        else:
            print_verbose("    token is below us")

    print_verbose("  no overlaps above us; handling this event")
    return true


## -----------------------------------------------------------------------------


# When the mouse enters or exits a token, emit a signal so that interested
# parties can tell which token has the "mouse focus"
func _mouse_enter_exit_state_change(entered: bool) -> void:
    # Don't handle this event if we're not supposed to.
    if _should_handle_mouse_state() == false:
        return

    if entered:
        token_mouse_in.emit(self)
    else:
        token_mouse_out.emit(self)


func activate() -> void:
    is_active = true
    $Texture.material = _activation_material


func deactivate() -> void:
    is_active = false
    is_grabbed = false
    $Texture.material = null
    execute_tween(scale_token.bind(false, spawn_scale))


## -----------------------------------------------------------------------------


## Given a token group name, return a list of all tokens that exist in that
## group; the list may be empty.
func find_token_by_group(group: String) -> Array[BaseToken]:
    # Get the scene tree, but only if there is a group provided to look in.
    var tree := null if group == null else get_tree()

    # Find all of the tokens in the group, if we found the tree
    if tree != null:
        var result = tree.get_nodes_in_group(group) as Array[BaseToken]

        # The resulting value is actually an array of nodes of type BaseToken
        # at a minimum, but you can't type cast an array, so we need to do some
        # weird hackery to shut the compiler up. *sigh*
        var superhack : Array[BaseToken]
        superhack.assign(result)

        return superhack

    # If there is no scene tree or no group, we can't look up the contents.
    return []


## Given a token group name and a token ID, find the token with that ID in
## the given token group.
##
## The return value is null if the token can't be found; otherwise it is the
## token.
func find_token_by_id(search_id: String, group: String) -> BaseToken:
    # If we were given a token ID that is non-empty and non-null, find all of
    # the tokens in the provided group and then distill it down to the one
    # selected.
    if search_id != null and search_id != '':
        var tokens := find_token_by_group(group)
        for token in tokens:
            if token.token_id == search_id:
                return token

    return null


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
        position = event.position + drag_offset

    # Grab or drop the token via the left mouse button; uses the press state to
    # know what to do. We don't use an input action for this because it might
    # end up accidentally mapped to a key. Also is_action_pressed() seems to
    # only return true for the first frame this happens in, and then it starts
    # reporting as unpressed, which would screw up dragging.
    if event is InputEventMouseButton and event.button_index == 1:
        is_grabbed = event.pressed
        if is_grabbed == true:
            drag_offset = position - event.position
            move_to_front()
            print("Grabbing Token: %s (%s)" % [token_details.name, token_details.token_type_name()])
        else:
            print("Dropping Token: %s (%s)" % [token_details.name, token_details.token_type_name()])
            if OS.is_stdout_verbose():
                dump()
        token_grabbed_or_dropped.emit(self, is_grabbed)

    # Flip the token front to back; via keyboard or right click.
    elif event.is_action_pressed("token_flip"): # W or right mouse button
        execute_tween(flip_token)

    # Zoom the token in somewhat for easier viewing
    elif event.is_action_pressed("token_zoom") or event.is_action_released("token_zoom"): # S or middle button click
        var zoom_in := true if event.is_action_pressed("token_zoom") else false
        var new_scale := Vector2(token_zoom, token_zoom) if zoom_in else spawn_scale
        execute_tween(scale_token.bind(zoom_in, new_scale))

    # Rotate to the left or right 90 degrees
    elif event.is_action_pressed("token_rotate_left") or event.is_action_pressed("token_rotate_right"): # A,D
        execute_tween(rotate_token.bind(event.is_action_pressed("token_rotate_right")))

    # Reset token rotation back to the default; leaves the flip state alone
    elif event.is_action_pressed("token_reset"): # R
        execute_tween(restore_token)


## -----------------------------------------------------------------------------


## Dump information about this token and all of its details out to the console
## for debugging purposes.
func dump() -> void:
    if token_details != null:
        token_details.dump()
    else:
        print("No token details to dump")


## -----------------------------------------------------------------------------
