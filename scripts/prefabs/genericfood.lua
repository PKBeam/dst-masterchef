local assetName = "genericfood"

local assets =
{
    Asset("ANIM", "anim/" .. assetName .. ".zip"),
    Asset("ATLAS", "images/inventoryimages/" .. assetName .. ".xml"),
}

local prefabs =
{
    "spoiled_food",
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

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = TUNING.SANITY_TINY

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = assetName
    inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. assetName .. ".xml"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

STRINGS.NAMES.GENERICFOOD = "Generic Food"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GENERICFOOD = "So pedestrian."

return Prefab("common/inventory/" .. assetName, fn, assets, prefabs)