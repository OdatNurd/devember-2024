@tool
class_name PlanetCard extends BaseCard


## This class represents the Planet card specifialization for all event cards in
## the game. It adds to the base card functionality everything required to
## distinctly mark this card as a planet card.


@export_group("Card Details", "card")

## The underlying statistics and information for this planet
@export var card_details : PlanetCardDetails


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a planet card.
func _enter_tree() -> void:
    _deferred_groups.append("_planet_cards")
    super._enter_tree()


## -----------------------------------------------------------------------------
