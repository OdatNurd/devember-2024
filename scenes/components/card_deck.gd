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


## -----------------------------------------------------------------------------


func _ready() -> void:
    super._ready()
    _load_cards()



## -----------------------------------------------------------------------------


# Using our configured resource, create all of the required cards in the deck.
#
# 1. Get the list of card details from the deck layout
# 2. For each card in the deck details:
#    b. Create an instance of the card details
#    c. Configure the base properties of the instance
#    d. Configure the token and detail resources for the card
#
# None of these resources will be added to the tree, hence they will not
# actually be visible anyway until they are "dealt".
func _load_cards() -> void:
    if deck_cards == null:
        print("cannot load cards; no deck defined")
        return

    print("Creating %d cards for %s" % [len(deck_cards.cards), token_details.name])

    var card := deck_cards.card_scene
    for item in deck_cards.cards:
        print("Adding card %s" % item.token.name)
        #var new_card = card.instantiate()
        #new_card.token_details = item.token
        #new_card.card_details = item.card
        #new_card.position = Vector2(300, 300)
        #get_parent().add_child(new_card)




## -----------------------------------------------------------------------------
