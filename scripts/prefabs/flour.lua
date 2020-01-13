local assetName = "flour"

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

    inst:AddTag("icebox_valid")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/3
    inst.components.edible.sanityvalue = 0

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

STRINGS.NAMES.FLOUR = "Flour"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FLOUR = "I think I spilled some on me."

return Prefab("common/inventory/flour", fn, assets, prefabs)