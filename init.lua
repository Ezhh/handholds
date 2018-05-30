-- global functions container
handholds = {}

-- function to safely remove climbable air
local function remove_air(pos, oldnode)
	local dir = minetest.facedir_to_dir(oldnode.param2)
	local airpos = vector.subtract(pos, dir)

	local north_node = minetest.get_node({x = airpos.x, y = airpos.y, z = airpos.z+1})
	local south_node = minetest.get_node({x = airpos.x, y = airpos.y, z = airpos.z-1})
	local east_node = minetest.get_node({x = airpos.x+1, y = airpos.y, z = airpos.z})
	local west_node = minetest.get_node({x = airpos.x-1, y = airpos.y, z = airpos.z})

	local keep_air =
		(minetest.get_item_group(north_node.name, "handholds") == 1 and
		north_node.param2 == 0) or
		(minetest.get_item_group(south_node.name, "handholds") == 1 and
		south_node.param2 == 2) or
		(minetest.get_item_group(east_node.name, "handholds") == 1 and
		east_node.param2 == 1) or
		(minetest.get_item_group(west_node.name, "handholds") == 1 and
		west_node.param2 == 3)

	if not keep_air then
		minetest.set_node(airpos, {name = "air"})
	end
end


-- remove handholds from nodes buried under falling nodes
local function remove_handholds(pos)
	local north_pos = {x = pos.x, y = pos.y, z = pos.z+1}
	local south_pos = {x = pos.x, y = pos.y, z = pos.z-1}
	local east_pos = {x = pos.x+1, y = pos.y, z = pos.z}
	local west_pos = {x = pos.x-1, y = pos.y, z = pos.z}
	local north_node = minetest.get_node(north_pos)
	local south_node = minetest.get_node(south_pos)
	local east_node = minetest.get_node(east_pos)
	local west_node = minetest.get_node(west_pos)

	local node_pos

	if minetest.get_item_group(north_node.name, "handholds") == 1 and
			north_node.param2 == 0 then
		node_pos = north_pos
	elseif minetest.get_item_group(south_node.name, "handholds") == 1 and
			south_node.param2 == 2 then
		node_pos = south_pos
	elseif minetest.get_item_group(east_node.name, "handholds") == 1 and
			east_node.param2 == 1 then
		node_pos = east_pos
	elseif minetest.get_item_group(west_node.name, "handholds") == 1 and
			west_node.param2 == 3 then
		node_pos = west_pos
	end

	if node_pos then
		local handholds_node = string.split(minetest.get_node(node_pos).name, ":")
		minetest.set_node(node_pos, {name = "default:"..handholds_node[2]})
	end
end


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
	groups = {not_in_creative_inventory = 1},
	on_destruct = function(pos)
		remove_handholds(pos)
	end,
})

-- a simple recursive table-copying function.
-- Doesn't handle reference loops, but that shouldn't come up in normal node defs
local simple_copy
simple_copy = function(t)
	local r = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			r[k] = simple_copy(v)
		else
			r[k] = v
		end
	end
	return r
end

--Duplicates a tile definition
local copy_tile_def = function(tile_def)
	if type(tile_def) == "string" then
		return tile_def
	else
		return simple_copy(tile_def)
	end
end

--Modifies a tile definition to have handholds_holds overlaid on it and returns the modified version
local apply_handholds_to_tile = function(tile_def)
	if type(tile_def) == "string" then
		return tile_def .. "^handholds_holds.png"
	else
		new_def = simple_copy(tile_def)
		new_def.name = new_def.name.."^handholds_holds.png"
		return new_def
	end
end

-- base_node to handhold name mapping
local registered_handholds = {}

--base_node_name is the node that's having a handholds node created for it
--handhold_node_name is the name of the handhold node to be registered
--handhold_def_override is a table of properties to override on the handhold def before it is registered
-- for example, {description="Climbable Dirt"} would override the description of the resulting handhold node
handholds.register_handholds_node = function(base_node_name, handhold_node_name, handhold_def_override)

	local base_def = minetest.registered_nodes[base_node_name]
	local handhold_def = simple_copy(base_def)
	
	handhold_def.description = base_def.description .. " Handholds"
	
	-- If no special drop was defined for this node, have it drop its old non-handhold self
	if handhold_def.drop == nil then
		handhold_def.drop = base_node_name
	end
	
	if handhold_def.after_destruct == nil then
		handhold_def.after_destruct = function(pos, oldnode)
			remove_air(pos, oldnode)
		end
	else
		-- If the base node has an after_destruct, run that and then run remove_air
		handhold_def.after_destruct = function(pos, oldnode)
			base_def.after_destruct(pos, oldnode)
			remove_air(pos, oldnode)
		end
	end
	handhold_def.on_rotate = function()
		return false
	end
	handhold_def.paramtype2 = "facedir"
	
	local tiles_length = table.getn(handhold_def.tiles)
	for i = tiles_length+1, 6 do
		handhold_def.tiles[i] = copy_tile_def(handhold_def.tiles[tiles_length])
	end
	handhold_def.tiles[6] = apply_handholds_to_tile(handhold_def.tiles[6])
	
	if handhold_def_override then 
		for k,v in pairs(handhold_def_override) do
			handhold_def[k] = v
		end
	end

	minetest.register_node(handhold_node_name, handhold_def)
	registered_handholds[base_node_name] = handhold_node_name
end

handholds.register_handholds_node("default:ice", "handholds:ice")
handholds.register_handholds_node("default:stone", "handholds:stone")
handholds.register_handholds_node("default:sandstone", "handholds:sandstone")
handholds.register_handholds_node("default:desert_stone", "handholds:desert_stone")

-- handholds tool
minetest.register_tool("handholds:climbing_pick", {
	description = "Climbing Pick",
	inventory_image = "handholds_tool.png",
	sound = {breaks = "default_tool_breaks"},
	on_use = function(itemstack, player, pointed_thing)
		if not pointed_thing or 
				pointed_thing.type ~= "node" or 
				minetest.is_protected(pointed_thing.under, player:get_player_name()) or
				minetest.is_protected(pointed_thing.above, player:get_player_name()) or
				pointed_thing.under.y + 1 == pointed_thing.above.y or
				pointed_thing.under.y - 1 == pointed_thing.above.y then
			return
		end

		local node_def = 
			minetest.registered_nodes[minetest.get_node(pointed_thing.above).name]
		if not node_def or not node_def.buildable_to then
			return
		end

		local node_name = minetest.get_node(pointed_thing.under).name
		local rotation = minetest.dir_to_facedir(
			vector.subtract(pointed_thing.under, pointed_thing.above))

		local handhold_node_name = registered_handholds[node_name]
		if handhold_node_name ~= nil then
			minetest.set_node(pointed_thing.under,
				{name = handhold_node_name, param2 = rotation})
		else
			return
		end

		minetest.set_node(pointed_thing.above, {name = "handholds:climbable_air"})
		minetest.sound_play(
			"default_dig_cracky",
			{pos = pointed_thing.above, gain = 0.5, max_hear_distance = 8}
		)

		if not minetest.settings:get_bool("creative_mode") then
			local wdef = itemstack:get_definition()
			itemstack:add_wear(256)
			if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
				minetest.sound_play(wdef.sound.breaks,
					{pos = pointed_thing.above, gain = 0.5})
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "handholds:climbing_pick",
	recipe = {
		{'default:diamond', 'default:diamond', 'default:diamond'},
		{'group:stick', '', ''},
		{'group:stick', '', ''},
	},
})
