@tool
class_name PlanetCard extends BaseCard


## This class represents the Planet card specifialization for all event cards in
## the game. It adds to the base card functionality everything required to
## distinctly mark this card as a planet card.


@export_group("Card Details", "card")

## The underlying statistics and information for this planet
@export var card_details : PlanetCardDetails


## -----------------------------------------------------------------------------
