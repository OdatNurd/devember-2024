@tool
class_name EventCard extends BaseCard


## This class represents the Event card specifialization for all event cards in
## the game. It adds to the base card functionality everything required to
## distinctly mark this card as an event card.


@export_group("Card Details", "card")

## The underlying statistics and information for this event card
@export var card_details : EventCardDetails


## -----------------------------------------------------------------------------
