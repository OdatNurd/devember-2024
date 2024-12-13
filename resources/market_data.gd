class_name MarketData extends Resource


## Objects of this type are used to track the buy and sell vectors for each of
## the various event cards that adjust the base prices of things based on the
## planet that is currently being explored.


## -----------------------------------------------------------------------------


## The buy price for this particular market item.
@export var buy := 0

## The sell price for this particular market item.
@export var sell := 0


## -----------------------------------------------------------------------------


# For ease of debugging, report our contents as a string because looking at a
# resource address is not as illuminating as it could be.
func _to_string() -> String:
    return "<buy=%d, sell=%d>" % [buy, sell]


## -----------------------------------------------------------------------------


## Initialize a new instance and set up the values to use when doing so.
##
## This is here due to the conversion tooling script, which is for converting
## resource formats while we keep being unable to make up our minds about the
## form the data should take.
func _init(lbuy : int = 0, lsell : int = 0) -> void:
  buy = lbuy
  sell = lsell


## -----------------------------------------------------------------------------
