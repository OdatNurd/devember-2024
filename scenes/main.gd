extends Node2D


## -----------------------------------------------------------------------------


# The minimal user interface on the game includes a button that causes the
# rocket token that marks the planet that the player is currently on to bring
# itself to the top of the display order and zoom temporarily to draw your
# attention to it in case it's not immediately visible.
func _on_find_ship_button_pressed() -> void:
    # Alias the ship token so we can work with it easier
    var token = $RocketToken

    # Capture the current scale of the token. Then calculate what the new
    # scale value should be. We want to grow the token by 100% to call attention
    # to it.
    var org_scale = token.scale
    var new_scale = org_scale * 2

    # Bring the token to the front and then zoom the scale up to make the
    # token visible on the screen.
    token.move_to_front()
    token.execute_tween(token.scale_token.bind(true, new_scale))

    # Fire a simple timer to wait for a moment, and then scale the token back to
    # the original scale.
    await get_tree().create_timer(1.0).timeout
    token.execute_tween(token.scale_token.bind(true, org_scale))


## -----------------------------------------------------------------------------


# In order to make setting up for a new game easier, this button does the work
# of recalling all of the tokens and cards and reshuffling the decks.
func _on_new_game_button_pressed() -> void:
    # The confirmation dialog is currently hidden; make it visible. This will
    # make it modally consume input until the user interacts with one of the
    # buttons, which will then trigger a signal and hide the dialog again.
    $Layout/NewGameConfirmation.visible = true


## -----------------------------------------------------------------------------


# This is invoked when the player presses the button for a new game and then
# uses the confirmation dialog to say that they want to proceed.
func _on_new_game_confirmation() -> void:
    print("Request for a new game confirmed")
    var resets = []

    # Find all of the card decks that are defined and get them to gather the
    # cards that they contain. This will cause all of the dealt cards to be
    # pulled back to the deck, flippuing and rotating back into the deck
    # position before hiding.
    #
    # The cards are pulled in deck order, unless the deck is marked as being
    # shuffled, in which case it will also shuffle.
    for deck in get_tree().get_nodes_in_group('_card_decks'):
        deck.gather_cards()

    # Grab all of the tokens that represent card piles, player aids and tokens
    # that need to be reset.
    resets.append_array(get_tree().get_nodes_in_group('_card_piles'))
    resets.append_array(get_tree().get_nodes_in_group('_resettable_player_aids'))
    resets.append_array(get_tree().get_nodes_in_group('_marker_tokens'))

    # Tell them all to reset back to their stored starting location bow. This
    # will fire all of the tweens and return back asyncronously.
    for token in resets:
        token.execute_tween(token.restore_token)

    for tween in get_tree().get_processed_tweens():
        if tween.is_valid():
            await tween.finished

    # Ensure that the ship token is on top; this also calls attention to it in
    # a way that makes it appear as if the ship is just arriving. Meta!
    _on_find_ship_button_pressed()


# This is invoked when the player presses the button for a new game and then
# uses the confirmation dialog to say that they want to cancel the operation.
func _on_new_game_canceled() -> void:
    print("Request for a new game cancelled")


## -----------------------------------------------------------------------------
