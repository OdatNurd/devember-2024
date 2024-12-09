## The resouce type for planet cards
extends GenericCardResource
class_name PlanetCardStats


## -----------------------------------------------------------------------------


## The travel distance to the planet (cost in Vectorium)
@export var distance := 0

## The relative cost of agriculturals at this planet
@export var agriculturals := 0

## The relative cost of weapons at this planet
@export var weapons := 0

## The relative cost of industrials at this planet
@export var industrials := 0

## The relative cost of illegals at this planet
@export var illegals := 0

## The police presence on this planet
@export var police := 0


## -----------------------------------------------------------------------------


func dump():
    super.dump()
    print("Distance: %d" % distance)
    print("Police: %d" % police)
    print("Agriculturals: %d" % agriculturals)
    print("Weapons: %d" % weapons)
    print("Industrials: %d" % industrials)
    print("Illegals: %d" % illegals)
    print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")


## -----------------------------------------------------------------------------
