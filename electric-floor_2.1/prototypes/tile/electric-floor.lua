-- Tile: electric-floor
--
-- Extracted from Dectorio's "dect-concrete-grid" tile (GPLv3, by PantherX).
-- The tile is a plain Factorio 2.1 concrete tile whose surface texture is
-- replaced by the grid material, so it transitions and behaves exactly like
-- the base game concrete.

local base_concrete = data.raw["tile"]["concrete"]

local electric_floor_tile = table.deepcopy(base_concrete)

electric_floor_tile.name = "electric-floor"
electric_floor_tile.order = "a[artificial]-b[tier-2]-b[electric-floor]"
electric_floor_tile.minable = {mining_time = 0.1, result = "electric-floor"}

-- Merge with concrete so no border is drawn between them.
electric_floor_tile.transition_merges_with_tile = "concrete"

-- The only visual difference from base concrete: the grid surface texture.
-- The original Dectorio asset is a high resolution spritesheet, so it needs
-- the same `count`/`scale` as the base game's own concrete texture.
electric_floor_tile.variants.material_background = {
	picture = "__electric-floor__/graphics/terrain/electric-floor.png",
	count = 8,
	scale = 0.5
}

data:extend({electric_floor_tile})
