@tool
class_name MarkerToken extends BaseToken


# This class represents a standard game marker; a chit or marker that is used to
# keep scores, etc. It differs from player aids in that it generaly has less
# functionality.


## -----------------------------------------------------------------------------


@export_group("Marker Details", "marker")


## If set to a string, this marker will try to snap iteself to the cloest
## snap point in this group when it is dropped.
@export var marker_snap_group : String = ''


## Marker tokens can snap themselves to the closest snapping point when you
## drop them. This sets the distance (in pixels) for the snap effect. Larger
## values allow the snap to happen from a further distance.
@export var marker_snap_distance := 16


## -----------------------------------------------------------------------------


# When this node gets added to the scene tree, dynamically add it to the list
# of groups that are in its deferred groups list defined by the parent, and also
# a specific group that marks us as a card.
func _enter_tree() -> void:
    _deferred_groups.append("_marker_tokens")
    super._enter_tree()


## -----------------------------------------------------------------------------


func _ready() -> void:
    super._ready()

    # Distance is measured as the square for speed, so adjust the tolerance to
    # that scale.
    if not Engine.is_editor_hint():
        marker_snap_distance *= marker_snap_distance

## -----------------------------------------------------------------------------


# Invoked every time a token is dropped; the token can use this to decide if it
# wants to take any action in regards to the drop. The base class version of
# this only shows that something was dropped.
func _did_drop() -> void:
    super._did_drop()

    # If there is not a snap group for this token, we don't need to proceed.
    if marker_snap_group == '':
        return

    # Find all of the snap points in the group.
    var markers : Array = get_tree().get_nodes_in_group(marker_snap_group)

    # Stores the closest found snap point to this marker's position.
    var closest_dist = 1000000000000
    var closest = null

    for i in range(len(markers)):
        var dist = position.distance_squared_to(markers[i]. position)
        if dist < closest_dist:
            closest_dist = dist
            closest = markers[i]

    # If the closest marker is in tolerance, snap us.
    if closest_dist <= marker_snap_distance:
        position = closest.position



## -----------------------------------------------------------------------------
