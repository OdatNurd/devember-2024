@tool
class_name CardPile extends BaseToken


# This class represents a card pile; a location on the screen to which cards
# can be dealt and moved,


## -----------------------------------------------------------------------------


@export_group("Pile Details", "pile")


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a card.
func _enter_tree() -> void:
    _deferred_groups.append("_card_piles")
    super._enter_tree()


## -----------------------------------------------------------------------------
