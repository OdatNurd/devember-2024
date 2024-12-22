@tool
class_name PlayerAid extends BaseToken


# This class represents a player aid; a specific type of token which is meant
# just to provide help to the player in how to play the game, or otherwise
# provide some sort of tracking ability for game progress.


## -----------------------------------------------------------------------------


@export_group("Aid Details", "aid")


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a card.
func _enter_tree() -> void:
    _deferred_groups.append("_player_aids")
    super._enter_tree()


## -----------------------------------------------------------------------------
