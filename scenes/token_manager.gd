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

## The grabbed token, if any.
var _grabbed_token : Node = null

## -----------------------------------------------------------------------------


## Add the provided token to the list of tokens that are managed by this
## token manager; This will connect it to all of the signals for that token to
## allow the user to interact with the token.
func add_token(token: BaseToken) -> void:
    token.token_mouse_in.connect(_mouse_state_change.bind(true))
    token.token_mouse_out.connect(_mouse_state_change.bind(false))
    token.token_grabbed_or_dropped.connect(_grab_stage_change)


## -----------------------------------------------------------------------------


# This is connected to the signal from tokens that they generate when they are
# grabbed or dropped. We use this to set an internal state that indicates
# whether we should respond to mouse enter events or not.
func _grab_stage_change(token: Node, grabbed: bool) -> void:
    _grabbed_token = token if grabbed else null


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

    # If there is currently a grabbed token, we don't want to respond to mouse
    # enter or leave events because we're in the middle of a drag.
    if _grabbed_token != null:
        return

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
