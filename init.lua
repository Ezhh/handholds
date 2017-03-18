
-- climbable air!
minetest.register_node("handholds:climbable_air", {
	description = "Air!",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	climbable = true,
	drop = "",
	groups = {not_in_creative_inventory=1}
})


-- handholds node
minetest.register_node("handholds:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	tiles = {"default_stone.png", "default_stone.png", 
		"default_stone.png", "default_stone.png", 
		"default_stone.png", "default_stone.png^handholds_holds.png"},
	paramtype2 = "facedir",
	groups = {cracky = 3, stone = 1},
	drop = 'default:cobble',
	sounds = default.node_sound_stone_defaults(),
	on_destruct = function(pos)
		local node = minetest.get_node(pos)
		local dir = minetest.facedir_to_dir(node.param2)
		local airpos = vector.subtract(pos, dir)
		minetest.set_node(airpos, {name = "air"})
	end,
})


-- handholds tool
minetest.register_tool("handholds:tool", {
	description = "Climbing Pick",
	inventory_image = "handholds_tool.png",
	sound = {breaks = "default_tool_breaks"},
	on_use = function(itemstack, player, pointed_thing)
		if not pointed_thing then
			return
		end
		if pointed_thing.type ~= "node"
		or minetest.is_protected(pointed_thing.under, player:get_player_name()) then
			return 
		end
		local node = minetest.get_node(pointed_thing.under).name
		if node == "default:stone" then
			local rotation = minetest.dir_to_facedir(vector.subtract(pointed_thing.under, pointed_thing.above))
			minetest.set_node(pointed_thing.under, {name = "handholds:stone", param2 = rotation})
			minetest.set_node(pointed_thing.above, {name = "handholds:climbable_air"})
		end	
	end
})

minetest.register_craft({
	output = "handholds:handhold_tool",
	recipe = {
		{'default:diamond', 'default:diamond', 'default:diamond'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

