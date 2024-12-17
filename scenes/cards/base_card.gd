@tool
class_name BaseCard extends BaseToken


## This class represents the common base class specialization for all of the
## cards that appear in the game. This class is not intended to be directly
## used within a node, and instead should be the super class right up until we
## need to access a node or its properties and realize we're boned or something.


## -----------------------------------------------------------------------------


@export_group("Card Details", "card")


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a card.
func _enter_tree() -> void:
    _deferred_groups.append("_base_cards")
    super._enter_tree()


## -----------------------------------------------------------------------------


## Dump information about this card and all of its details out to the console
## for debugging purposes.
func dump() -> void:
    super.dump()

    # Only our subclasses have access to the actual property, but our contract
    # is that it will always be the same (just a different distinguishable
    # type). So, pluck the value of the property that way.
    var card_details = get("card_details")
    if card_details != null:
        card_details.dump()
    else:
        print("No card details to dump")


## -----------------------------------------------------------------------------
