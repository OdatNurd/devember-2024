@tool
class_name CardDeck extends BaseToken


## Tokens of this type represent decks of cards. A deck nominally acts like a
## token, but has additional behaviours related to.
##
## In a deck, the token being face up means that it's empty, while being face
## down means that it has some number of cards in it.


## -----------------------------------------------------------------------------


@export_group("Deck Details", "deck")

## The cards that should be populated into this deck.
@export var deck_cards : DeckLayout

## The list of cards that this deck contains.
var _cards : Array[BaseCard]

## -----------------------------------------------------------------------------


func _ready() -> void:
    super._ready()
    _load_cards()

    _cards = []


## -----------------------------------------------------------------------------


# Using our configured resource, create all of the required cards in the deck.
#
# This creates the appropriate card instances and gets them ready to be used in
# the game.
#
# The deck can have a placeholder set for where the cards should go when they
# are dealt; the initial properties of the created cards are duplicates of
# these properties.
#
# None of these resources will be added to the tree, hence they will not
# actually be visible anyway until they are "dealt".
#
# TODO: For the time being, the destination location is based on our own token.
func _load_cards() -> void:
    if deck_cards == null:
        print("cannot load cards; no deck defined")
        return

    print("Creating %d cards for %s" % [len(deck_cards.cards), token_details.name])

    var card := deck_cards.card_scene
    for item in deck_cards.cards:
        print("Adding card: %s" % item.token)

        # Create the card and set its position.
        var new_card = card.instantiate() as BaseCard
        new_card.position = Vector2(position.x - 200, position.y)

        # Set up the visuals for the card itself.
        new_card.token_details = item.token
        new_card.card_details = item.card

        # Get the token that says where we should deal cards to and what other
        # token properties exist.
        # TODO: This should not be us; this should be some pre designated token
        #       that represents this location.
        var deal_token : BaseToken = self

        # Set up the other token properties to match those of the deal token.
        new_card.token_padding = deal_token.token_padding
        new_card.token_outline_width = deal_token.token_outline_width
        new_card.token_zoom = deal_token.token_zoom
        new_card.scale = deal_token.scale

        # Create and inject the cards; we can't add these to the tree right
        # away; if you want to do that, you need to do
        #     get_parent().add_child.call_deferred(new_card)
        _cards.append(new_card)


## -----------------------------------------------------------------------------
