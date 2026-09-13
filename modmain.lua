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
