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

# This is connected to the mouse event signals of all tokens in the "tokens"
# group in _ready(); every time a token has the mouse enter or exit it, we get
# invoked, so that we can track the state of which token is active.
#
# Note that due to the vagaries of signals, if the mouse is moving fast enough
# to enter and exit multiple tokens in quick succession, it is possible for the
# events to arrive to tell you about things in an order that you don't expect
# (such as two enters followed by two leaves). So this needs to take care.
func _mouse_state_change(token: Node, entered: bool) -> void:
    var new_active = null
    var old_active = null

    # When the mouse enters a token, that token always gains the activation
    # status, possibly from an already active token.
    if entered:
        new_active = token
        old_active = _active_token

    # When the mouse is exiting a token, that token is deactivated, but only if
    # it is currently active. Otherwise we ignore the event because it might be
    # coming out of order.
    else:
        if _active_token == token:
            old_active = _active_token
        else:
            # Exit because the code below will change the active token to null,
            # which might not be what we want.
            return

    # If there used to be something active that now is not, deactivate it.
    if old_active != null:
        old_active.deactivate()
        token_deactivated.emit(old_active)

    # Set the newly activated token, and if required signal people to tell them
    # about the change. This also handles the fall through from the exited state
    # to remove the active token.
    _active_token = new_active
    if new_active != null:
        _active_token.activate()
        token_activated.emit(_active_token)


## -----------------------------------------------------------------------------
