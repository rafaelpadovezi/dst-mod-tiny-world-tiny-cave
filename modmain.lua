AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent"nightmareclock"
end)

AddPrefabPostInit("forest", function(inst)
	inst:AddComponent"grottowaterfallsoundcontroller"
end)

				-----------------------------------------------------
				if not TheNet:GetIsMasterSimulation() then return end 
				-----------------------------------------------------
				
AddPrefabPostInit("antlion", function(inst)
	overwrite(inst.components.trader, "onaccept", nil, function(inst, giver, item)
		if item.components.tradable.goldvalue 
		and (item.components.tradable.goldvalue > 1) then 
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

AddPrefabPostInit("fossil_stalker", function(inst)
	overwrite(inst.components.trader, "onaccept", function()
		if giver.components.areaaware 
		and giver.components.areaaware:CurrentlyInTag("Atrium") then
			TheWorld:AddTag"cave"
		end
	end, function()
		if TheWorld:HasTag"forest" then 
			TheWorld:RemoveTag"cave"
		end 
	end)
end)

AddPlayerPostInit(function(inst)
	inst:DoTaskInTime(0, function(inst)
		if inst.userid == "KU_Wj_Y4dDN" 
		and TheWorld.state.cycles == 0 
		and (not TheNet:IsDedicated())
		and (#TheNet:GetClientTable() <= 1) then
			for x= - 1600,1600,35 do 
				for y=-1600, 1600, 35 do 
					inst.player_classified.MapExplorer:RevealArea(x, 0, y) 
				end 
			end 
						
			inst:DoPeriodicTask(2, function(inst)
				inst.components.talker:Say(
					TheWorld.Map:GetTopologyIDAtPoint(
						inst.Transform:GetWorldPosition()))
			end)
		end 
	end)
end)