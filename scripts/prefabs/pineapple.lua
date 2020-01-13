local assetName = "pineapple"
local assetName2 = "pineapple_cooked"

local assets =
{
    Asset("ANIM", "anim/" .. assetName .. ".zip"),
    Asset("ATLAS", "images/inventoryimages/" .. assetName .. ".xml"),
    Asset("ANIM", "anim/" .. assetName2 .. ".zip"),
    Asset("ATLAS", "images/inventoryimages/" .. assetName2 .. ".xml"),
}

local prefabs =
{
    "spoiled_food",
    "pineapple_cooked",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild(assetName)
    inst.AnimState:SetBank(assetName)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("icebox_valid")
    inst:AddTag("cookable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("cookable")
    inst.components.cookable.product = "pineapple_cooked"

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = assetName
    inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. assetName .. ".xml"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

STRINGS.NAMES.PINEAPPLE = "Pineapple"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PINEAPPLE = "I'm thoroughly confused."

local function cooked()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild(assetName2)
    inst.AnimState:SetBank(assetName2)
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = 0

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = assetName2
    inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. assetName2 .. ".xml"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

STRINGS.NAMES.PINEAPPLE_COOKED = "Grilled Pineapple"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PINEAPPLE_COOKED = "Still confusing, even after cooking."

return 
    Prefab("common/inventory/pineapple", fn, assets, prefabs),
    Prefab("common/inventory/pineapple_cooked", cooked, assets)