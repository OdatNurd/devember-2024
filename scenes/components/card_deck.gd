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


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a card deck. Lastly, also load and create
# all of the cards that are a part of the deck.
func _enter_tree() -> void:
    _deferred_groups.append("_card_decks")
    super._enter_tree()

    # Only load cards when we're not in the editor, since otherwise we will
    # keep creating tokens every time things get the focus.
    if Engine.is_editor_hint() == false:
        _load_cards()


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

    # Create a group based on the ID of this deck, if any. This looks all super
    # gross because apparently if a ternary can produce one of two different
    # types in this duck typed language, the debugger loses its shit.
    var deck_group = null
    if token_id != null and token_id != '':
        deck_group = "%s_cards" % token_id
    if deck_group == null:
        print("Warning; cannot add deck cards to our group; we have no id")

    var card := deck_cards.card_scene
    for item in deck_cards.cards:
        print("Adding card: %s" % item.token)

        # Create the card and save it.
        var new_card = card.instantiate() as BaseCard
        if deck_group != null:
            new_card._deferred_groups.append(deck_group)

        # Set the position and make it hidden
        new_card.position = Vector2(position.x - 200, position.y)
        new_card.visible = false

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

        # Inject the card into the tree; it is currently invisible.
        get_parent().add_child.call_deferred(new_card)


## -----------------------------------------------------------------------------
