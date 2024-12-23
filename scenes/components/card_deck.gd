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

## If true, when the deck is created, the cards in it will be shuffled. When
## this is false, the cards in the deck will be in the order specified in the
## deck layout resource.
@export var deck_shuffle := true

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


## Determine the underling group name to be used for the cards that exist
## within this deck. This is based on the token_id of the deck, which should not
## be null or an empty string.
##
## The return value will be null if token_id of the deck is not valid.
func _get_deck_group() -> String:
    var deck_group = null
    if token_id != null and token_id != '':
        deck_group = "%s_cards" % token_id

    return deck_group


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
        push_warning("no deck contents are defined for this deck")
        print("cannot load cards; no deck defined")
        return

    # Invert the deck_cards list so that we create the deck bottom up; since we
    # bottom deal for speed, decks with no shuffle will have a reversed natural
    # deck order if we create top down.
    deck_cards.cards.reverse()

    print("Creating %d cards for %s" % [len(deck_cards.cards), token_details.name])

    # Create a group based on the ID of this deck, if any. This looks all super
    # gross because apparently if a ternary can produce one of two different
    # types in this duck typed language, the debugger loses its shit.
    var deck_group := _get_deck_group()
    if deck_group == null:
        push_warning("cannot add deck cards to our group; we have no id")

    var card := deck_cards.card_scene
    var counter := 0
    for item in deck_cards.cards:
        counter += 1
        print_verbose("Adding card %d: %s" % [counter, item.token])

        # Create the card and give it a node name that explicitly calls out who
        # created it and what its resource name was. We also include its index
        # in the deck, both for informational purposes and because that ensures
        # that the name is distinct.
        # TODO: The deck group could be null here, in which case the name will
        #       asplode.
        var new_card = card.instantiate() as BaseCard

        new_card.name = "%s_%d_%s" % [
            deck_group, counter, item.token.resource_path.get_basename().get_file()]

        # If there is a deck group, add it to the list of groups this token
        # should join when it enters the tree.
        if deck_group != null:
            new_card._deferred_groups.append(deck_group)

            # Since the deck group is made of the token ID of the deck, if we
            # have a group we have a deck, so record who owns us and what card
            # in the deck layout we are as well.
            new_card.deck_name = token_id
            new_card.deck_order = counter


        # Set the position and make it hidden
        new_card.position = Vector2(position.x, position.y)
        new_card.token_facing = TokenOrientation.FACE_DOWN
        new_card.visible = false

        # Set up the visuals for the card itself.
        new_card.token_details = item.token
        new_card.card_details = item.card

        # Set up the other token properties to match those of the deal token.
        new_card.token_zoom = token_zoom
        new_card.scale = scale

        # Inject the card into the tree; it is currently invisible.
        get_parent().add_child.call_deferred(new_card)
        _cards.append(new_card)

    # If we are supposed to shuffle the deck on load, do that now.
    if deck_shuffle:
        shuffle_cards(false)


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


## Given a card that exists within this deck, return the card back to the deck
## position via the same style of animation as was used to animate it.
##
## If the card is not visible on the screen, this will do nothing.
func return_card(card: BaseCard, delay: float) -> bool:
    # If this card is not visible, then we don't need to return it because the
    # player can't see it anyway.
    if not card.visible:
        return false

    card.execute_tween(card.move_card.bind(self.rotation, self.scale,
                                      self.position, TokenOrientation.FACE_DOWN,
                                      false, true, delay))
    return true


## Shuffle all of the cards that are currently within the _cards array that
## specifies the contents of this deck. This leaves out of the shuffle any cards
## that have previously been dealt.
##
## The shuffle can either be animated on screen, or done behind the scenes. When
## animate is true, the animation will be delayed by the delay time (in seconds)
## provided.
func shuffle_cards(animate: bool, delay: float = 0.0) -> void:
    print("shuffling: %s" % token_details.name)
    _cards.shuffle()
    if animate:
        execute_tween(wiggle_card.bind(delay))


## Gather up all of the cards that were originally dealt from this deck that
## are on the table, animate them back into the deck and hide them.
##
## If the option to shuffle on load is set, then also shuffle the cards.
## Otherwise, this pulls them back into the same order they were in trhe deck
## to begin with.
func gather_cards() -> void:
    print("gathering: %s" % token_details.name)

    # Get the deck group; if we don't have one, we can't gather cards.
    var deck_group := _get_deck_group()
    if deck_group == null:
        push_error("cannot gather cards; we have no id")
        return

    # Using the group associated with this specific deck, find all of the
    # cards. This will find all of them, both dealt and undealt.
    var all_cards := find_token_by_group(deck_group)

    # For each card that we found, if it's currently visible on the screen,
    # tween it back to the deck location and hide it. Anything that's not
    # currently visible hasn't been dealt and doesn't need to change.
    var delay := 0.0
    for card in all_cards:
        if return_card(card, delay):
            delay += 0.1

    # Replace the current deck cards with the new, full list. Our versions only
    # contains the cards that were not yet dealt out.
    _cards = []
    _cards.assign(all_cards)

    # If we are currently face up, then we should flip face down since we are
    # only face up when we're empty.
    if token_facing == TokenOrientation.FACE_UP:
        execute_tween(flip_token)

    # If we're supposed to shuffle the deck, then shuffle it now; otherwise,
    # sort the cards back into the original deck order.
    if deck_shuffle:
        shuffle_cards(true, delay + 0.75)
    else:
        print("returning to deck order: %s" % token_details.name)
        _cards.sort_custom(func(l,r): return l.deck_order < r.deck_order)


func _input(event: InputEvent):
    # Don't consume any input events if this node is not the active node
    if not is_active:
        return

    if event is InputEventMouseButton and event.pressed:
        match event.button_index:
            # Left mouse button deals; if ctrl is held down, the deal is face down
            MouseButton.MOUSE_BUTTON_LEFT:
                # Try to find the token that represents the pile we should be dealing
                # to; if we don't find one, then deal to our own location instead.
                var dest_token = find_token_by_id(deck_pile_id, "_card_piles")
                if dest_token == null:
                    dest_token = self

                # Face up if ctrl is not pressed, face down otherwise.
                deal_card(dest_token, not event.ctrl_pressed)

            # Right mouse button shuffles cards that are still in the deck
            MouseButton.MOUSE_BUTTON_RIGHT:
                shuffle_cards(true)

            # Middle button gathers all of the cards in the deck back.
            MouseButton.MOUSE_BUTTON_MIDDLE:
                gather_cards()




## -----------------------------------------------------------------------------
