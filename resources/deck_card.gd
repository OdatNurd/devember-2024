class_name DeckCard extends Resource


## Resources of this type are used to represent a card in a deck; it associates
## the token details that represent a card with the details contained within
## that card.


## -----------------------------------------------------------------------------


## The visual representation of this card
@export var token: TokenDetails


## The internal statistics for this card, if any
@export var card: CardDetails

## The snapping group that this card should be in, if any
@export var snap_group: String

## The snap distance that this card should use, if snapping is enabled.
@export var snap_distance: int


## -----------------------------------------------------------------------------
