-- The floor is unlocked together with the base game concrete technology.

local concrete_technology = data.raw["technology"]["concrete"]

table.insert(concrete_technology.effects, {
	type = "unlock-recipe",
	recipe = "electric-floor"
})
