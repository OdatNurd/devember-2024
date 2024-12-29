@tool
class_name MarkerToken extends BaseToken


# This class represents a standard game marker; a chit or marker that is used to
# keep scores, etc. It differs from player aids in that it generaly has less
# functionality.


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a card.
func _enter_tree() -> void:
    _deferred_groups.append("_marker_tokens")
    super._enter_tree()


## -----------------------------------------------------------------------------
