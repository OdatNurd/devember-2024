extends Node2D


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
