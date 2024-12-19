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

## Cards dealt from this deck are sent to the location of the pile with this
## id; if invalid or empty, cards deal on top of the deck.
@export var deck_pile_id : String

# The cards that appear in the deck; this stores the nodes, which have already
# been added to the tree (or will be, if we're still starting up), but this
# gives us an easy handle on them.
var _cards : Array[BaseCard]


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
# This will create all of the cards, ensure they're in a group named for this
# deck, and will add them to the tree as invisible.
#
# The new cards will take on the position and display properties of the deck
# itself (position, scale, outline, etc) but this can be altered  when the card
# is dealt.
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
        new_card.position = Vector2(position.x, position.y)
        new_card.token_facing = TokenOrientation.FACE_DOWN
        new_card.visible = false

        # Set up the visuals for the card itself.
        new_card.token_details = item.token
        new_card.card_details = item.card

        # Set up the other token properties to match those of the deal token.
        new_card.token_padding = token_padding
        new_card.token_outline_width = token_outline_width
        new_card.token_zoom = token_zoom
        new_card.scale = scale

        # Inject the card into the tree; it is currently invisible.
        get_parent().add_child.call_deferred(new_card)
        _cards.append(new_card)


## -----------------------------------------------------------------------------


## If this deck has at least one card still in it, deal that card out. Otherwise
## this will do nothing.
##
## The card will be dealt either face up or face down and will be sized and
## positioned to be over top of the provided dest_token.
func deal_card(dest_token: BaseToken, face_up: bool) -> void:
    # Get the card that we want to deal; if there is not one, then we can just
    # leave.
    var card := _cards.pop_back() as BaseCard
    if card == null:
        return

    var orientation = TokenOrientation.FACE_UP if face_up else TokenOrientation.FACE_DOWN
    card.execute_tween(card.move_card.bind(dest_token.rotation, dest_token.scale,
                                      dest_token.position, orientation,
                                      true, true))

    # If the deck is empty now, flip it over.
    if len(_cards) == 0:
        execute_tween(flip_token)


func _input(event: InputEvent):
    # Don't consume any input events if this node is not the active node
    if not is_active:
        return

    if event is InputEventMouseButton and event.pressed:
        # Try to find the token that represents the pile we should be dealing
        # to; if we don't find one, then deal to our own location instead.
        var dest_token = find_token_by_id(deck_pile_id, "_card_piles")
        if dest_token == null:
            dest_token = self

        deal_card(dest_token, event.button_index == 1)


## -----------------------------------------------------------------------------
