
-- climbable air!
minetest.register_node("handholds:climbable_air", {
	description = "Air!",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	climbable = true,
	drop = "",
	groups = {not_in_creative_inventory = 1}
})


-- handholds node
minetest.register_node("handholds:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	tiles = {"default_stone.png", "default_stone.png", 
		"default_stone.png", "default_stone.png", 
		"default_stone.png", "default_stone.png^handholds_holds.png"},
	paramtype2 = "facedir",
	groups = {cracky = 3, stone = 1, not_in_creative_inventory = 1},
	drop = 'default:cobble',
	sounds = default.node_sound_stone_defaults(),
	after_destruct = function(pos, oldnode)
		local dir = minetest.facedir_to_dir(oldnode.param2)
		local airpos = vector.subtract(pos, dir)

		local north_node = minetest.get_node({x = airpos.x, y = airpos.y, z = airpos.z+1})
		local south_node = minetest.get_node({x = airpos.x, y = airpos.y, z = airpos.z-1})
		local east_node = minetest.get_node({x = airpos.x+1, y = airpos.y, z = airpos.z})
		local west_node = minetest.get_node({x = airpos.x-1, y = airpos.y, z = airpos.z})

		local keep_air = (north_node.name == "handholds:stone" and north_node.param2 == 0) or
			(south_node.name == "handholds:stone" and south_node.param2 == 2) or
			(east_node.name == "handholds:stone" and east_node.param2 == 1) or
			(west_node.name == "handholds:stone" and west_node.param2 == 3)

		if not keep_air then
			minetest.set_node(airpos, {name = "air"})
		end
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
			minetest.sound_play(
				"default_dig_cracky",
				{pos = pointed_thing.above, gain = 0.5, max_hear_distance = 8}
			)
		end	
	end
})

minetest.register_craft({
	output = "handholds:handhold_tool",
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})

