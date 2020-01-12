local assets =
{
    Asset("ANIM", "anim/mortarpestle.zip"),
    Asset("ATLAS", "images/inventoryimages/mortarpestle.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("mortarpestle")
    inst.AnimState:SetBank("mortarpestle")
    inst.AnimState:PlayAnimation("idle")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(20)
    inst.components.finiteuses:SetUses(20)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("grinder")
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mortarpestle"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mortarpestle.xml"

    MakeHauntableLaunch(inst)

    return inst
end

STRINGS.NAMES.MORTARPESTLE = "Mortar and Pestle"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MORTARPESTLE = "I can use this to grind things."

return Prefab("common/inventory/mortarpestle", fn, assets)