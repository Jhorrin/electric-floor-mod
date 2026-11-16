-- Item: electric-floor

local base_concrete_item = data.raw["item"]["concrete"]

local electric_floor_item = table.deepcopy(base_concrete_item)

electric_floor_item.name = "electric-floor"
electric_floor_item.icon = "__electric-floor__/graphics/icons/electric-floor.png"
electric_floor_item.icon_size = 64
electric_floor_item.order = "b[concrete]-b[electric-floor]"
electric_floor_item.place_as_tile = {
	result = "electric-floor",
	condition_size = 1,
	condition = {layers = {water_tile = true}}
}

data:extend({electric_floor_item})
