extends Node

## -----------------------------------------------------------------------------


## When a token that is not currently the active token gains the mouse focus,
## that token becomes the newly active token and this signal is emitted to let
## interested parties know.
##
## This signal is emited AFTER the current token is deactivated (if any).
signal token_activated(token: Node2D)

## When a token that is currently the active token loses the mouse focus to
## another token, that token becomes the newly active token and this signal is
## emitted to let interested parties know.
##
## This signal is emited BEFORE the new token is activated.
signal token_deactivated(token: Node2D)


## -----------------------------------------------------------------------------


## The currently active token, if any.
var _active_token : Node = null


## -----------------------------------------------------------------------------


func _ready() -> void:
    for token in get_tree().get_nodes_in_group("tokens"):
        token.token_mouse_in.connect(_mouse_state_change.bind(true))
        token.token_mouse_out.connect(_mouse_state_change.bind(false))


## -----------------------------------------------------------------------------


# This is connected to all game tokens and allows them to signal us when the
# mouse enters or exits their area.
func _mouse_state_change(token: Node, entered: bool) -> void:
    print("mouse state change:", token.get_path(), " ", entered)
    var new_active = null
    var old_active = null

    # If this is an enter, then a token is gaining the activation status.
    if entered:
        new_active = token
        old_active = _active_token

    # If this an exit, then a token is being deactivated, and that token must
    # be the one that is currently active.
    else:
        old_active = _active_token

    # If there is an old active token, that one is no longer going to be
    # active, so deactivate it.
    if old_active != null:
        print("deactivating token: ", old_active.get_path())
        token_deactivated.emit(old_active)
        old_active.deactivate()

    # Set the active token to be the newly activated token; if there is actually
    # a token to be active, then emit the signal as well.
    _active_token = new_active
    if new_active != null:
        print("activating token: ", _active_token.get_path())
        token_activated.emit(_active_token)
        _active_token.activate()


## -----------------------------------------------------------------------------
