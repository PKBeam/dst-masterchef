PrefabFiles = {
    "mortarpestle",
}

Assets = {
    Asset("IMAGE", "images/inventoryimages/mortarpestle.tex"),
	Asset("ATLAS", "images/inventoryimages/mortarpestle.xml"),
	Asset("IMAGE", "images/inventoryimages/genericfood.tex"),
	Asset("ATLAS", "images/inventoryimages/genericfood.xml"),
}

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

local mortarpestle = Recipe("mortarpestle", { Ingredient("rocks", 2), Ingredient("marble", 3) }, GLOBAL.RECIPETABS.FARM, GLOBAL.TECH.SCIENCE_ONE )
mortarpestle.atlas = "images/inventoryimages/mortarpestle.xml"
GLOBAL.STRINGS.NAMES.MORTARPESTLE = "Mortar and Pestle"
GLOBAL.STRINGS.RECIPE_DESC.MORTARPESTLE = "Grind nuts and vegetables into flour."

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
--[[
local twigsalad = {
	name = "twigsalad",
	test = function(cooker, names, tags) return names.twigs end,
	priority = 300,
	weight = 1,
	foodtype="VEGGIE",
	health = TUNING.HEALING_TINY,
	hunger = TUNING.CALORIES_TINY,
	sanity = TUNING.SANITY_TINY,
	perishtime = TUNING.PERISH_SUPERSLOW,
	cooktime = 0.15,
}
AddCookerRecipe("cookpot", twigsalad)
AddCookerRecipe("portablecookpot", twigsalad)
--]]

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
	
    act.invobject.components.grinder:Grind(act.target)
    --[[print("debuginfo")
    for k, v in pairs(act) do
        print(k, v)
    end]]--
    local inventory = act.doer.components.inventory
    local loot = GLOBAL.SpawnPrefab("twigs")
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