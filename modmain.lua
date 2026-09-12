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

AddPrefabPostInit("antlion", function(inst)
    overwrite(inst.components.trader, "onaccept", nil, function(inst, giver, item)
        if item.components.tradable.goldvalue and (item.components.tradable.goldvalue > 1) then
            if inst.pendingrewarditem == "townportaltalisman" then
                inst.pendingrewarditem = {}
            elseif inst.pendingrewarditem == nil then
                inst.pendingrewarditem = {}
            end

            for i = 1, item.components.tradable.goldvalue do
                table.insert(inst.pendingrewarditem, "rocks")
            end
        end
    end)
end)

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
