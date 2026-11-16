-- Helpers around the hidden proxy entities.

local constants = require("scripts.constants")

local proxies = {}

local PREFIX_LENGTH = #constants.PROXY_PREFIX

--- Is this prototype name one of our hidden proxies?
--- @param name string?
--- @return boolean
function proxies.is_proxy(name)
	return name ~= nil and name:sub(1, PREFIX_LENGTH) == constants.PROXY_PREFIX
end

--- Supply radius of a proxy, read straight from its name.
--- @param name string
--- @return number
function proxies.radius_from_name(name)
	return tonumber(name:sub(PREFIX_LENGTH + 1)) / 2
end

--- Stable string key for a proxy at a position. Positions are either whole or
--- half tiles, so the doubled value is always an exact integer.
--- @return string
function proxies.position_key(name, x, y)
	return name .. "|" .. math.floor(x * 2 + 0.5) .. "|" .. math.floor(y * 2 + 0.5)
end

--- @param entity LuaEntity
--- @return string
function proxies.entity_key(entity)
	return proxies.position_key(entity.name, entity.position.x, entity.position.y)
end

--- Do two supply squares touch (edges or corners included)? Used both for
--- proxy-to-proxy and for pole-to-proxy, since a real pole's supply area is a
--- square in exactly the same way.
--- @return boolean
function proxies.touch(a_position, a_radius, b_position, b_radius)
	local reach = a_radius + b_radius + 0.001
	return math.abs(a_position.x - b_position.x) <= reach and math.abs(a_position.y - b_position.y) <= reach
end

--- Wires two entities together.
--- `reach_check = false` skips the wire reach check, which is what lets the
--- floor conduct over any distance. Returns whether they are connected.
---
--- `or_create = true` is required: while `on_built_entity` runs, an entity the
--- game has just built has not been given its wire connectors yet, so asking
--- for an existing one returns nil and the connection would be silently
--- dropped (this is why only the chunk rebuild could ever join a fresh pole).
--- @param a LuaEntity
--- @param b LuaEntity
--- @return boolean
function proxies.connect(a, b)
	local connector_a = a.get_wire_connector(constants.POLE_COPPER, true)
	local connector_b = b.get_wire_connector(constants.POLE_COPPER, true)

	if not connector_a or not connector_b then return false end
	if connector_a.is_connected_to(connector_b) then return true end

	return connector_a.connect_to(connector_b, false)
end

--- Can this pole power - and therefore feed or draw from - any part of the
--- floor? Used to decide whether a freshly built pole is worth re-checking.
--- @param pole LuaEntity
--- @return boolean
function proxies.can_reach_floor(pole)
	local reach = proxies.supply_radius(pole)
	if reach <= 0 then reach = constants.MAX_RADIUS end

	local position = pole.position

	return pole.surface.count_tiles_filtered {
		name = constants.TILE_NAME,
		area = {
			{position.x - reach, position.y - reach},
			{position.x + reach, position.y + reach},
		},
	} > 0
end

--- Half the side of a real pole's supply square. This is the distance within
--- which the pole powers whatever stands next to it, so it is also the distance
--- within which it can feed or draw from the floor.
--- @param pole LuaEntity
--- @return number
function proxies.supply_radius(pole)
	return constants.pole_supply_radius(pole.name)
end

--- Joins a real electric pole to the floor network when their supply areas
--- touch - that is, whenever the pole can power part of the floor, it powers
--- the whole floor (and takes part in its network).
---
--- Requiring the pole to physically stand on a floor tile would be too strict:
--- a substation's supply area reaches 9 tiles out, so a substation standing next
--- to the floor already powers the tiles at its edge and therefore has to be
--- part of the same network.
---
--- @param surface LuaSurface
--- @param pole LuaEntity
--- @return number amount of proxies connected
function proxies.connect_pole(surface, pole)
	local supply = proxies.supply_radius(pole)
	local position = pole.position
	local search = supply + constants.MAX_RADIUS + 1

	local found = surface.find_entities_filtered {
		name = constants.PROXY_NAMES,
		area = {
			{position.x - search, position.y - search},
			{position.x + search, position.y + search},
		},
	}

	local connected = 0

	for i = 1, #found do
		local proxy = found[i]

		if
			proxy.valid
			and proxies.touch(position, supply, proxy.position, proxies.radius_from_name(proxy.name))
			and proxies.connect(pole, proxy)
		then
			connected = connected + 1
		end
	end

	return connected
end

return proxies
