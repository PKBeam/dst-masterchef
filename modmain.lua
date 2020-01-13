PrefabFiles = {
    "mortarpestle",
	"flour",
	"pineapple",
	"toast",
}

AssetList = {
	"mortarpestle",
	"flour",
	"pineapple",
	"pineapple_cooked",
	"genericfood",
}

Assets = {
}

for k, v in pairs(AssetList) do
	table.insert(Assets, Asset("IMAGE", "images/inventoryimages/" .. v .. ".tex"))
	table.insert(Assets, Asset("ATLAS", "images/inventoryimages/" .. v .. ".xml"))
end

-----------------------------------
-- Crafting recipes
--
--  AddRecipe("name", {ingredients}, tab, techlevel)
--  optional arguements:
--  AddRecipe("name", {ingredients}, tab, techlevel, "placer", minspacing, no_unlock, num_to_give)
--		Use this to create a new recipe object. Recipes automatically register
--		themselves.
--
--		Check out recipes.lua for plenty of examples.
--
--	Ingredient("type", amount, atlas)
--		If you want to specify a custom ingredient you must also specify the
--		atlas its inventory image is found in.
--
-----------------------------------

--[[
local mortarpestle = AddRecipe("mortarpestle", { Ingredient("rocks", 2), Ingredient("marble", 3) }, GLOBAL.RECIPETABS.FARM, GLOBAL.TECH.SCIENCE_ONE )
mortarpestle.atlas = "images/inventoryimages/mortarpestle.xml"
GLOBAL.STRINGS.NAMES.MORTARPESTLE = "Mortar and Pestle"
GLOBAL.STRINGS.RECIPE_DESC.MORTARPESTLE = "Grind nuts and vegetables into flour."

--this code was previously in my prefab def lua file
Recipe("bindingring", {Ingredient("goldnugget", 10),Ingredient("moonrocknugget", 1)}, RECIPETABS.MAGIC, TECH.NONE)
AllRecipes["bindingring"].atlas = resolvefilepath("images/inventoryimages/bindingring.xml")
--now it it is replaced with the following code in your modmain.lua
--]]
GLOBAL.IngredientAddRecipe(
	"mortarpestle", 
	{Ingredient("rocks", 3), Ingredient("marble", 3)}, 
	GLOBAL.RECIPETABS.FARM, 
	GLOBAL.TECH.SCIENCE_ONE,
	nil, nil, nil, nil, nil, 
	"images/inventoryimages/mortarpestle.xml", "mortarpestle.tex"
)

-----------------------------------
-- Cookpot recipes
--
--  AddIngredientValues({"item"}, {"tag"=value})
--		Lets the game know the "worth" of an item. You can supply a list of
--		items in the first parameter if they will all have the same values.
--
--		Each tag is a particular "kind" of thing that a recipe might require
--		(i.e. meat, veggie) and the value is how much of that kind your item is
--		worth.
--
--		See cooking.lua for examples. 
--
--	AddCookerRecipe("cooker", recipe)
--		Adds the recipe for that kind of cooker. In the base game the only
--		cooker is "cookpot".
--
--		See preparedfoods.lua for recipe examples.
--
-----------------------------------

AddIngredientValues({"flour"}, {inedible = 1})
AddIngredientValues({"pineapple", "pineapple_cooked"}, {fruit = 1})

local toast = {
	name = "toast",
	test = function(cooker, names, tags) return names.flour and names.flour >= 3 end,
	priority = 10,
	weight = 1,
	foodtype="VEGGIE",
	health = TUNING.HEALING_SMALL,
	hunger = TUNING.CALORIES_MED,
	sanity = 0,
	perishtime = TUNING.PERISH_MED,
	cooktime = 0.5,
}
AddCookerRecipe("cookpot", toast)
AddCookerRecipe("portablecookpot", toast)

local pinetrees = {
	"evergreen_normal", 
	"evergreen_tall", 
	"evergreen_short", 
	"evergreen_sparse",
	"evergreen_sparse_normal", 
	"evergreen_sparse_tall", 
	"evergreen_sparse_short",
}

function TreeLootModifier(inst) 
    local oldonfinish = inst.components.workable.onfinish
    inst.components.workable.onfinish = function(inst, chopper)       
        if chopper and inst.components.growable then
            if inst.components.growable.stage == 3 then
                inst.components.lootdropper:AddChanceLoot("pineapple", 0.20)
            elseif inst.components.growable.stage == 2 then
                inst.components.lootdropper:AddChanceLoot("pineapple", 0.15)
            elseif inst.components.growable.stage == 1 then
                inst.components.lootdropper:AddChanceLoot("pineapple", 0.10)
            end   
        end    
		oldonfinish(inst, chopper)        
	end
    return inst
end

for k,v in pairs(pinetrees) do 
	AddPrefabPostInit(v, TreeLootModifier)
end

local grindables = {
	"acorn",
	"acorn_cooked",
	"pinecone",
	"twiggy_nut",
	"potato",
	"potato_cooked",
	"corn",
	"corn_cooked",
}
for k, v in pairs(grindables) do
	AddPrefabPostInit(v, 
		function(inst)
			inst:AddTag("grindable")
			inst:AddComponent("grinder")
		end
	)
end

AddAction("GRIND", "Grind", function(act)
	
	-- remove grinded object and reduce durability
    act.invobject.components.grinder:Grind(act.target)

    local inventory = act.doer.components.inventory
    local loot = GLOBAL.SpawnPrefab("flour")
    if loot ~= nil then
        inventory:GiveItem(loot)
    end
    return true
end)

AddComponentAction("USEITEM", "grinder", function(inst, doer, target, actions, right)
    if right then
        if target:HasTag("grindable") then
            table.insert(actions, GLOBAL.ACTIONS.GRIND)
        end
    end
end)

AddStategraphState("wilson", GLOBAL.State{
    name = "grind",
    tags = {"doing", "busy"},
    onenter = function(inst)
		inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)
        inst.sg:SetTimeout(1)
	end,
    ontimeout = function(inst)
        inst:PerformBufferedAction()
        inst.AnimState:PlayAnimation("build_pst")
        inst.sg:GoToState("idle")
    end,
})
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.GRIND, "grind"))