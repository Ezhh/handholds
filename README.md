handholds
===

Mountain climbing mod for Minetest by Shara RedCat which adds a climbing pick tool. Use the tool to add handholds to stone, desert stone, sandstone and ice which can then be climbed.

The tool can be crafted using diamonds and sticks. 

Nodes cannot be placed directly in front of handholds, and falling nodes landing in front of handholds will remove the handholds and restore the original node.

Thanks to paramat, Zeno, LazyJ, Billre and NathanS21 for testing and suggestions.

API
---

This mod offers an API that other mods can call to add new types of handhold nodes:

```
handholds.register_handholds_node(base_node_name, handhold_node_name, handhold_def_override)
```

base_node_name is the node that's having a handholds node created for it.

handhold_node_name is the name of the handhold node to be registered.

handhold_def_override is an optional table of properties to override on the handhold def before it is registered.

for example:

```
handholds.register_handholds_node("default:dirt", "dirtyfun:dirt_handholds", {description="Climbable Dirt"})
```

Licenses and Attribution 
-----------------------

Code for this mod is released under MIT (https://opensource.org/licenses/MIT).

Textures for this mod are released under CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/), attribution: Shara RedCat.
