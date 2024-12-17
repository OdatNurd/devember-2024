@tool
class_name EventCard extends BaseCard


## This class represents the Event card specifialization for all event cards in
## the game. It adds to the base card functionality everything required to
## distinctly mark this card as an event card.


@export_group("Card Details", "card")

## The underlying statistics and information for this event card
@export var card_details : EventCardDetails


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as an event card.
func _enter_tree() -> void:
    _deferred_groups.append("_event_cards")
    super._enter_tree()


## -----------------------------------------------------------------------------
