-- Chunk covering: "which tiles of this chunk are electric floor" -> "the fewest
-- proxies that cover exactly those tiles".
--
-- How it works:
--   1. Read the floor tiles of one 32x32 chunk.
--   2. Build a 2D prefix sum over a 32x32 boolean grid (no bit library needed).
--      "Is this sub-square completely floor?" is then four table lookups, which
--      makes the covering below almost free.
--   3. Quadtree-subdivide the chunk: a fully covered square becomes one proxy,
--      anything else splits into four halves until size 1.
--
-- The scratch buffers are reused between calls on purpose; this code runs once
-- per dirty chunk and must not allocate.

local constants = require("scripts.constants")

local coverage = {}

local CHUNK = constants.CHUNK_SIZE
local STRIDE = CHUNK + 1

local present = {}
local prefix = {}

local function square_sum(x, y, size)
	local x2, y2 = x + size - 1, y + size - 1
	return prefix[y2 * STRIDE + x2]
		- prefix[(y - 1) * STRIDE + x2]
		- prefix[y2 * STRIDE + (x - 1)]
		+ prefix[(y - 1) * STRIDE + (x - 1)]
end

local function subdivide(x, y, size, out, x0, y0)
	if square_sum(x, y, size) == size * size then
		-- A pole placed in the middle of this square has a supply area of
		-- exactly `size`, so radius = size / 2 covers the square precisely.
		out[#out + 1] = {
			name = constants.PROXY_PREFIX .. size,
			x = x0 + x - 1 + size / 2,
			y = y0 + y - 1 + size / 2,
		}
		return
	end

	if size == 1 then return end

	local half = size / 2
	subdivide(x, y, half, out, x0, y0)
	subdivide(x + half, y, half, out, x0, y0)
	subdivide(x, y + half, half, out, x0, y0)
	subdivide(x + half, y + half, half, out, x0, y0)
end

--- Returns the proxies that should exist for the floor tiles of one chunk.
--- @param surface LuaSurface
--- @param x0 number left edge of the chunk, in tiles
--- @param y0 number top edge of the chunk, in tiles
--- @return table list of {name = <prototype>, x = <number>, y = <number>}
function coverage.cover_chunk(surface, x0, y0)
	for key in pairs(present) do present[key] = nil end

	local found = false

	for _, tile in
		ipairs(surface.find_tiles_filtered {
			name = constants.TILE_NAME,
			area = {{x0, y0}, {x0 + CHUNK, y0 + CHUNK}},
		})
	do
		local tx = tile.position.x - x0
		local ty = tile.position.y - y0

		if tx >= 0 and tx < CHUNK and ty >= 0 and ty < CHUNK then
			present[ty * CHUNK + tx + 1] = true
			found = true
		end
	end

	if not found then return {} end

	-- Rows 0 and columns 0 of the prefix table are all zero, and every other
	-- entry is written below, so the table never needs clearing.
	for x = 0, CHUNK do prefix[x] = 0 end

	for y = 1, CHUNK do
		local row = y * STRIDE
		local previous_row = row - STRIDE
		local row_sum = 0

		prefix[row] = 0

		for x = 1, CHUNK do
			if present[(y - 1) * CHUNK + x] then row_sum = row_sum + 1 end
			prefix[row + x] = prefix[previous_row + x] + row_sum
		end
	end

	local out = {}
	subdivide(1, 1, CHUNK, out, x0, y0)

	return out
end

return coverage
