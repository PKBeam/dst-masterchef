local Grinder = Class(function(self, inst)
    self.inst = inst
end)

function Grinder:Grind(target)
    target.components.stackable:Get(1):Remove()
    self.inst.components.finiteuses:Use(1)
    return true
end

return Grinder