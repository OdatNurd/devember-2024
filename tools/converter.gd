extends Control

# Original version of this script by eumario (https://gist.github.com/eumario)
# aka CasperDragonWolf.
#
# The original version of the gist that was used to kindly provide this is:
#     https://gist.github.com/eumario/bad489894ecd66d5e66256a6eb57d39f
#
# This was used when we swapped the underlying resource that is used to hold
# event card market data from a vector to a sub resource so that the fields
# look better.
#
# As such it was a run-and-done kind of thing, but leaving it here as a reminder
# and a self document on how to pull this off for future machinations.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    %RunConv.pressed.connect(_handle_run_conv)


func _handle_run_conv() -> void:
    var path = "res://resources/cards/events"
    for file in DirAccess.get_files_at(path):
        var res : EventCardDetails = load("res://resources/cards/events/%s" % file)
        res.agriculturals_new = MarketData.new(res.agriculturals.x, res.agriculturals.y)
        res.weapons_new = MarketData.new(res.weapons.x, res.weapons.y)
        res.industrials_new = MarketData.new(res.industrials.x, res.industrials.y)
        res.illegals_new = MarketData.new(res.illegals.x, res.illegals.y)
        ResourceSaver.save(res, "res://resources/cards/events/%s" % file)
        print("Updated %s" % file)
