AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent "nightmareclock"
end)

AddPrefabPostInit("forest", function(inst)
    inst:AddComponent "grottowaterfallsoundcontroller"
end)

-----------------------------------------------------
if not TheNet:GetIsMasterSimulation() then
    return
end
-----------------------------------------------------

TUNING.ARCHIVE_RESONATOR.USES = 100

AddPrefabPostInit("forest", function(inst)
    inst:AddComponent("toadstoolspawner")
    inst:AddComponent("grottowarmanager")
    inst:AddComponent("shadowparasitemanager")
    inst:AddComponent("daywalkerspawner")
    inst:AddComponent("archivemanager")
    inst:AddComponent("miasmamanager")
    inst:AddComponent("shadowthrallmanager")
    inst:AddComponent("ruinsshadelingspawner")
    inst:AddComponent("shadowthrall_mimics")
end)

local VANILLA_FOSSIL_CHANCE = 0.10
local STALAGMITE_FOSSIL_CHANCE = 0.25
local EXTRA_FOSSIL_CHANCE = 1 - (1 - STALAGMITE_FOSSIL_CHANCE) / (1 - VANILLA_FOSSIL_CHANCE)

for _, prefab in ipairs({
    "stalagmite", "stalagmite_full", "stalagmite_med", "stalagmite_low",
    "stalagmite_tall", "stalagmite_tall_full", "stalagmite_tall_med", "stalagmite_tall_low",
}) do
    AddPrefabPostInit(prefab, function(inst)
        inst.components.lootdropper:AddChanceLoot("fossil_piece", EXTRA_FOSSIL_CHANCE)
    end)
end
