-- Hidden power "proxies".
--
-- A tile can never take part in the electric network: only entities can. The
-- way to make a floor conductive is therefore to place an invisible
-- electric pole on top of it. These prototypes are that pole.
--
-- Design notes (all of these keep the proxies free):
--   * `hidden` + `not-on-map` + `not-blueprintable` + `not-deconstructable`:
--     the player never sees, selects, blueprints or deconstructs them.
--   * empty `collision_mask`: the pole shares its cell with the machine it
--     powers, so it can sit under any entity.
--   * `maximum_wire_distance = 0`: the game will never wire these on its own
--     (nor let the player drag a wire onto them). All connections are made by
--     script with `wire_connector.connect_to(target, false)` - passing
--     `reach_check = false` is what lets the floor conduct over any distance.
--   * one prototype per square size, so a whole 32x32 chunk of floor can be
--     covered by a single entity instead of one pole per tile.

local sizes = {1, 2, 4, 8, 16, 32}

-- Wire attachment points. Wires are never drawn, so the offsets are irrelevant;
-- the property itself is required and needs one entry per direction.
local connection_point = {
	wire = {
		copper = {0, 0},
		green = {0, 0},
		red = {0, 0},
	},
	shadow = {
		copper = {0, 0},
		green = {0, 0},
		red = {0, 0},
	},
}

local prototype = {
	type = "electric-pole",
	hidden = true,
	selectable_in_game = false,
	flags = {
		"placeable-off-grid",
		"not-on-map",
		"not-blueprintable",
		"not-deconstructable",
	},
	collision_mask = {layers = {}},
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	maximum_wire_distance = 0,
	draw_copper_wires = false,
	draw_circuit_wires = false,
	create_ghost_on_death = false,
	rewire_neighbours_when_destroying = false,
	protected_from_tile_building = false,
	remove_decoratives = "false",
	connection_points = {connection_point, connection_point, connection_point, connection_point},
}

local proxies = {}

for i = 1, #sizes do
	local size = sizes[i]
	local p = table.deepcopy(prototype)

	p.name = "electric-floor-proxy-" .. size
	p.supply_area_distance = size / 2

	proxies[#proxies + 1] = p
end

data:extend(proxies)
