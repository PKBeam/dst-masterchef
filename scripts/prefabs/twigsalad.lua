local assets =
{
    --Asset("ANIM", "anim/twigsalad.zip"),
    Asset("ATLAS", "images/inventoryimages/twigsalad.xml"),
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

    inst.AnimState:SetBuild("twigsalad")
    inst.AnimState:SetBank("twigsalad")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("preparedfood")

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
    inst.components.inventoryitem.imagename = "twigsalad"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/twigsalad.xml"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

STRINGS.NAMES.TWIGSALAD = "Twig Salad"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TWIGSALAD = "This is a sticky situation..."

return Prefab("common/inventory/twigsalad", fn, assets, prefabs)