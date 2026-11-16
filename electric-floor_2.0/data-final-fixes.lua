-- The runtime prototype API does not expose `supply_area_distance` for electric
-- poles: reading an unknown key from a LuaEntityPrototype raises an error
-- instead of returning nil. The values are therefore collected here and handed
-- to the control stage through a mod-data prototype.
--
-- This runs in data-final-fixes so that poles added by every other mod are
-- included.

local by_name = {}
local largest = 0

for name, prototype in pairs(data.raw["electric-pole"] or {}) do
	local distance = prototype.supply_area_distance or 0

	by_name[name] = distance

	if distance > largest then largest = distance end
end

data:extend({
	{
		type = "mod-data",
		name = "electric-floor-pole-supply",
		data = {
			by_name = by_name,
			largest = largest,
		},
	},
})
