-- Recipe: electric-floor

data:extend({
	{
		type = "recipe",
		name = "electric-floor",
		energy_required = 10,
		enabled = false,
		categories = {"crafting"},
		ingredients = {
			{type = "item", name = "concrete", amount = 10},
			{type = "item", name = "copper-cable", amount = 50},
			{type = "item", name = "electronic-circuit", amount = 5}
		},
		results = {
			{type = "item", name = "electric-floor", amount = 10}
		}
	}
})
