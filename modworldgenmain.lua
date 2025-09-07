----------------------------------------------------------------------------------
--[[		*			*				NOTES			*			*			--
----------------------------------------------------------------------------------
]]

----------------------------------------------------------------------------------
--			*			*		UNIVERSAL FUNCTIONS		*			*			--
----------------------------------------------------------------------------------

GLOBAL.setmetatable(env, {__index = function(self, index)
	return GLOBAL.rawget(GLOBAL, index)
end})

function env.NOTHING_FUNCTION() end 

function env.print(...)
	GLOBAL.print("[" .. modinfo.name .. "]", ...)
end

function env.overwrite(tabula, name, ante, post, replace_this_with_nil)
	if not tabula then 
		return 
	end 
	
	local old = tabula[name] 
	tabula[name] = function(...)
		
		if ante then 
			local results = {ante(...)}
			
			if #results > 0 then 
				if (replace_this_with_nil ~= nil) 
				and #results == 1 
				and results[1] == replace_this_with_nil then 
					results = {nil}
				end 
				return unpack(results) 
			end 
		end 
		
		local results = 
			type(old) == "function" and {old(...)} 
			or {old}
					
		if post then 
			local results = {post(...)}

			if #results > 0 then 
				if (replace_this_with_nil ~= nil) 
				and #results == 1 
				and results[1] == replace_this_with_nil then 
					results = {nil}
				end 
				return unpack(results) 
			end 
		end 
		
		return unpack(results)
	end	
	
	return tabula[name]
end 

for _ , data in pairs(modinfo.configuration_options or {}) do 
	env[data.name] = GetModConfigData(data.name)
end 

env.NAME = string.upper(string.gsub(modinfo.name, " ", "_"))
local MAKE_NAME_INDEX = 0
local IDENTIFIERS = {}
function env.MakeName(identifier, initiation_function)
	if IDENTIFIERS[identifier] == nil then
		MAKE_NAME_INDEX = MAKE_NAME_INDEX + 1
		IDENTIFIERS[identifier] = NAME .. MAKE_NAME_INDEX
		
		if initiation_function then 
			initiation_function(IDENTIFIERS[identifier])
		end
	end 
	return IDENTIFIERS[identifier]
end

----------------------------------------------------------------------------------
--			*			*			MICRO FUNCTIONS		*			*			--
----------------------------------------------------------------------------------

local function TreatSetpiece(data)
	if not data then data = {} end 
	for k, v in pairs{
		layout_position = LAYOUT_POSITION.CENTER,
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED, 
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED, 
		type = LAYOUT.STATIC,
		ground = {{0}}, 
	} do 
		if data[k] == nil then 
			data[k] = v
		end 
	end 	
	
	return data
end

function env.RetreatSetpiece(name, data)
	if Layouts[name] then 
		Layouts[name].start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
		Layouts[name].fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
		Layouts[name].layout_position = LAYOUT_POSITION.CENTER
		
		for k, v in pairs(data or {}) do 
			Layouts[name][k] = v
		end 
		
		return {[name] = 1}
	end 
end

env.Layouts = require"map/layouts".Layouts
function env.MakeSetpiece(name, data)
	if data == nil then 
		data = name
		name = MakeName(data)
	end 
	
	require"map/layouts".Layouts[name] = TreatSetpiece(data)
	
	return {[name] = 1}
end

function env.GetSetpiece(name, data)
	require"map/layouts".Layouts[name] = 
		require"map/static_layout".Get("map/static_layouts/" .. name, 
			TreatSetpiece(data))
			
	return {[name] = 1}
end

function env.Noise(func)
	local name = MakeName(func)
	if not WORLD_TILES[name] then 
		AddTile(name, "NOISE")
		require"noisetilefunctions"[WORLD_TILES[name]] = func
	end 
	return WORLD_TILES[name]
end

----------------------------------------------------------------------------------
--			*			*			MACRO FUNCTIONS		*			*			--
----------------------------------------------------------------------------------

-- for the express purpose of handling formalities  
function env.Room(name, data)
	if data == nil then 
		data = name
		name = MakeName(data)
	end 
	
	for k, v in pairs{
		tags = {}, 
		colour = { r = 1, g = 0, b = 0.0, a = 1 }
	} do 
		if data[k] == nil then 
			data[k] = v
		end 
	end 
		
	AddRoom(name, data)
	
	return 1
end

-- pre init for the express purpose of fixing the random contents
-- also saves the trouble of adding tags like the astral ones
-- makes the countprefab and distrinbute prefab table in case it doenst exist yet 
function env.FixRoom(name, func)
	AddRoomPreInit(name, function(self)
		if not self.tags then self.tags = {} end 
		
		if not self.required_prefabs then 
			self.required_prefabs = {}
		end 
		
		if not self.contents then 
			self.contents = {} 
		end 
		
		if not self.contents.countprefabs then 
			self.contents.countprefabs = {} 
		end 
		
		if not self.contents.distributeprefabs then 
			self.contents.distributeprefabs = {} 
		end 
		
		func(self)
	end)
	
	return 1
end

function env.Task(name, data)
	if data == nil then 
		data = name
		name = MakeName(data)
	end 
	
	for k, v in pairs{
		colour = { r = 1, g = 0, b = 0.0, a = 1 }, 
		room_bg = GROUND.IMPASSABLE, 
		background_room = "Empty_Cove", 
		room_tags = {}, 
		room_choices = {}, 
	} do 
		if data[k] == nil then 
			data[k] = v
		end 
	end 
	
	AddTask(name, data)
	IncludeTask(name)
	return name
end

function env.IslandTask(name, data)
	local name = Task(name, data)
	
	AddTaskPreInit(name, function(self)
	-- INSULARITY
		if self.region_id == nil then 
			self.region_id = name
		end
		self.type = NODE_TYPE.SeparatedRoom
		table.insert(self.room_tags, "ForceDisconnected")
		table.insert(self.room_tags, "RoadPoison")
--		self.level_set_piece_blocker = true

		self.cove_room_name = "Empty_Cove"
		self.cove_room_chance = 1
		self.cove_room_max_edges = 1
	end)
	
	return name
end

function env.IslandRoomTask(name, data)
	if data == nil then 
		data = name
		name = MakeName(data)
	end 

	local name = IslandTask(name, {})
	
	Room(name, data)
	FixRoom(name, function(self)
		table.insert(self.tags, "ForceDisconnected")
		table.insert(self.tags, "RoadPoison")
	end)
	
	AddTaskPreInit(name, function(self)
		self.room_choices = {[name] = 1}
		if not self.room_tags then self.room_tags = {} end 
										
		if data.task_init then 
			print("task_init", self, name)
			data.task_init(self)
		end 
	end)
	
	return name
end

function env.Level(data)	
	for k, v in pairs{
		id = NAME,
		name = modinfo.name, 
		desc = modinfo.description, 
		version = 4, 
		location = "forest",
	} do 
		if data[k] == nil then 
			data[k] = v
		end 
	end 
	
	AddLevel(LEVELTYPE.SURVIVAL, data)
	return data.id
end

overwrite(env, "AddLevel", nil, function(type, data)
	if rawget(GLOBAL, "TheFrontEnd") then 
		for _, screen_in_stack in pairs(TheFrontEnd.screenstack) do
			if screen_in_stack.name == "ServerCreationScreen" then
				servercreationscreen = screen_in_stack
				for k, v in pairs(servercreationscreen.world_tabs) do 
					if v:GetCurrentLocation() == data.location then
						v.worldgen_widget:LoadPreset(data.id)
						v.worldgen_widget:Refresh()
						v.settings_widget:LoadPreset(data.id)
						v.settings_widget:Refresh()
						v:RefreshOptionItems()
					end
				end
			end
		end
	end
end)

----------------------------------------------------------------------------------
--			*			*		STRUCTURATION			*			*			--
----------------------------------------------------------------------------------

env.required_prefabs = {}
env.ocean_prefill_setpieces = {} 
env.tasks = {}
AddTaskSet(NAME, {
	location = "forest", 
	required_prefabs = required_prefabs, 
	tasks = tasks, 
	ocean_prefill_setpieces = ocean_prefill_setpieces, 
	ocean_population = {
		"OceanCoastalShore",
		"OceanCoastal",
		"OceanSwell",
		"OceanRough",
		"OceanHazardous",
	}
})

AddLevel(LEVELTYPE.SURVIVAL, {
	id = NAME, 
	name = modinfo.name, 
	desc = modinfo.description, 
	version = 4, 
	location = "forest", 
	
	overrides = {
		world_size = "small", 
		task_set = NAME, 
--		loop = "never", 
		
	--  CLACISSISM
        prefabswaps_start = "classic",
		spawnprotection = "never",
		extrastartingitems = "none",
		seasonalstartingitems = "never", 
		specialevent = "none",
		
	-- DERANDOMIZATION: SETPIECES
		boons = "never",
--		touchstone = "never",
		traps = "never",
		poi = "never",
		protected = "never",
--		stageplays = "never", 
		
	-- MISC ITEMS 
--		roads = "never", 
--		spawnmode = "scatter", 
		portalresurection = "always", 
		petrification = "none", 
--		grass = "often", 
--		sapling = "often", 
--		basicresource_regrowth = "always", 
		regrowth = "never", 
--		twiggytrees_regrowth = "never", 
		
	-- OCEAN ITEMS
--		ocean_bullkelp = "rare", 
--		ocean_otterdens = "rare", 
		ocean_wobsterden = "often", 
		
	-- ALWAYS
		hounds = "always", 
		krampus = "always", 
		liefs = "always", 
		pirateraids = "often", 
		squid = "always", 
}})

---------------------------------------------------
---------------------------------------------------

function env.IncludeTask(name, func)
	table.insert(tasks, name)
	AddTaskPreInit(name, function(self)
		self.background_room = "BGImpassable"
		
--		self.cove_room_name = "Empty_Cove"
--		self.cove_room_chance = 1
		if func then
			func(self)
		end
	end)
end

---------------------------------------------------
---------------------------------------------------

AddRoomPreInit("Clearing", function(self)
	self.value = WORLD_TILES.IMPASSABLE
	self.contents = {}
end)

IncludeTask("Dig that rock", function(self)
	self.make_loop = true
	self.locks = {}
	self.keys_given = {KEYS.TIER1}
	self.room_choices = {
		Graveyard = 1, 
		Rocky = 1, 
		CritterDen = 1,
	}
end)

RetreatSetpiece"Charlie1"
RetreatSetpiece"Charlie2"
Layouts.Charlie2.layout_position = LAYOUT_POSITION.RANDOM

FixRoom("Graveyard", function(self)
	self.contents.countstaticlayouts = {
		Charlie1 = 1, 
		Charlie2 = 1
	}
	self.contents.countprefabs.molehill = 3
--	self.contents.countprefabs.cave_entrance = 1
--	self.contents.countprefabs.wormhole_MARKER = 1
end)

FixRoom("Rocky", function(self)
	self.required_prefabs = {
		"resurrectionstone", 
		"moon_altar_rock_idol"
	}
	self.contents.countstaticlayouts = RetreatSetpiece"ResurrectionStone"
	self.contents.countprefabs.meteorspawner = nil
	self.contents.countprefabs.flint = 3
	self.contents.countprefabs.moon_altar_rock_idol = 1
	self.contents.countprefabs.rock2 = 5
	self.contents.countprefabs.rock_flintless = 9
	self.contents.distributeprefabs.rock_ice = nil
	self.contents.countprefabs.burntground_faded = nil
end)

FixRoom("CritterDen", function(self)
	self.required_prefabs = {
		"terrariumchest", 
		"oceantreenut"
	}
	self.contents.countprefabs.flint = 1
	self.contents.countstaticlayouts = RetreatSetpiece"Terrarium_Forest_Spiders"
	self.contents.countprefabs.oceantreenut = 1
end)

---------------------------------------------------
---------------------------------------------------

IncludeTask("Forest hunters", function(self)
	self.make_loop = true	
	self.locks = {LOCKS.TIER1}
	self.keys_given = {}
	self.room_choices = {
		MoonbaseOne = 1, 
		WalrusHut_Grassy = 1, 
		MagicalDeciduous = 1, 
	}
end)

FixRoom("MagicalDeciduous", function(self)
	self.required_prefabs = {
		"rock_moon_shell", 
		"pigking"
	}
	self.random_node_entrance_weight = 0
--	self.contents.countprefabs.pond = 1
	self.contents.countprefabs.pighouse = 4
	self.contents.countprefabs.rock_moon_shell = 1
	self.contents.countprefabs.deerspawningground = 1
	self.contents.countprefabs.statueglommer = 1
	self.contents.countprefabs.molehill = 1
	self.contents.countstaticlayouts = RetreatSetpiece"DefaultPigking"
	
	self.contents.distributeprefabs.red_mushroom = nil
	self.contents.distributeprefabs.blue_mushroom = nil
	self.contents.distributeprefabs.green_mushroom = nil
	
	self.contents.countprefabs.mushtree_small = 2
	self.contents.countprefabs.mushtree_medium = 2
	self.contents.countprefabs.mushtree_tall = 2
	
	self.contents.countprefabs.grass = 1
	self.contents.countprefabs.sapling = 1
	self.contents.countprefabs.berrybush = 1
end)

FixRoom("MoonbaseOne", function(self)	
	self.tags = nil
	self.required_prefabs = {
		"moonbase", 
		"moon_altar_rock_seed"
	}
	
	self.random_node_entrance_weight = 0
--	self.contents.countprefabs.walrus_camp = 1
	self.contents.countprefabs.moon_altar_rock_seed = 1
	self.contents.countprefabs.rabbithouse = 4
	
	self.contents.countprefabs.berrybush = 1
	self.contents.countprefabs.grass = 1
	self.contents.countprefabs.sapling = 1
end)

FixRoom("WalrusHut_Grassy", function(self)
	self.contents.countstaticlayouts = RetreatSetpiece"Maxwell5"
	self.contents.countprefabs.berrybush = 1
	self.contents.countprefabs.grass = 1
	self.contents.countprefabs.sapling = 1
	self.contents.countprefabs.walrus_camp = nil
end)

---------------------------------------------------
---------------------------------------------------

IncludeTask("For a nice walk", function(self)
	self.make_loop = true
	self.locks = {LOCKS.TIER1}
	self.keys_given = {}
	self.room_choices = {
		MandrakeHome = 1, 
		BeefalowPlain = 1, 
		DeepForest = 1, 
	}
end)

FixRoom("MandrakeHome", function(self)
	self.required_prefabs = {
		"beequeenhive", 
	}
	
	self.random_node_exit_weight = 0
	self.contents.countstaticlayouts = RetreatSetpiece"MooseNest"
	self.contents.countprefabs.beequeenhive = 1
	self.contents.countprefabs.mandrake_planted = 2
	
--	self.contents.countprefabs.berrybush = 1
	self.contents.countprefabs.grass = 1
	self.contents.countprefabs.sapling = 1
	
	self.contents.countprefabs.walrus_camp = 1
end)

FixRoom("BeefalowPlain", function(self)
	self.required_prefabs = {
		"beefalo", 
		"sculpture_rook",
		"sculpture_bishop",
		"sculpture_knight",
	}
	
--	self.random_node_entrance_weight = 0
	self.contents.countstaticlayouts = RetreatSetpiece"Sculptures_1"
	self.contents.countprefabs.beefalo = 1
	self.contents.countprefabs.babybeefalo = 2
--	self.contents.countprefabs.spiderden = 1
	self.contents.countprefabs.green_mushroom = 1
	
	self.contents.countprefabs.grass = 15
	self.contents.countprefabs.sapling = 1
	self.contents.countprefabs.rabbithole = 4
	self.contents.countprefabs.berrybush = 1
end)

FixRoom("DeepForest", function(self)
	self.tags = {}
	self.required_prefabs = {
		"junk_pile_big"
	}
	
	self.random_node_entrance_weight = 0
	self.contents.countstaticlayouts = RetreatSetpiece"junk_yard"
	self.contents.distributeprefabs.trees.prefabs = {"evergreen"}
	self.contents.countprefabs.spiderden_2 = 1
	self.contents.countprefabs.spiderden = 3
	self.contents.countprefabs.berrybush = 1
	self.contents.countprefabs.grass = 1
	self.contents.countprefabs.sapling = 1
end)

---------------------------------------------------
---------------------------------------------------

IncludeTask("Lightning Bluff", function(self)
	self.make_loop = true
	self.locks = {LOCKS.TIER1}
	self.keys_given = {}
	self.room_choices = {
		LightningBluffOasis = 1, 
		LightningBluffAntlion = 1,
		DragonflyArena = 1, 
	}
end)

FixRoom("LightningBluffOasis", function(self)
	self.tags = {"sandstorm"}
	self.random_node_exit_weight = 0
	self.LightningBluffAntlion = 0
	self.contents.countprefabs.lightninggoat = 1
	self.contents.countprefabs.oasis_cactus = 2
	self.contents.countprefabs.antlion_spawner = 1
	self.contents.countprefabs.rock_flintless = 5
	self.contents.countprefabs.marsh_tree = 3
	self.contents.countprefabs.marsh_bush = 1
end)

FixRoom("LightningBluffAntlion", function(self)
	self.tags = {"sandstorm"}
	self.random_node_exit_weight = 0
	self.contents.countprefabs.oasis_cactus = 2
	self.contents.countprefabs.marsh_tree = 3
	self.contents.countprefabs.rock_flintless = 5
	self.contents.countprefabs.marsh_bush = 1
	self.contents.countstaticlayouts = MakeSetpiece({
		layout = {
			daywalkerspawningground = {{x = 0, y = 0}}, 
			lightninggoat = {{x = 0, y = 0}}, 
			tumbleweedspawner = {{x = 0, y = 0}}, 
			buzzardspawner = {{x = 0, y = 0}}
		}
	})
end)

FixRoom("DragonflyArena", function(self)
	self.tags = {"sandstorm"}
	self.random_node_entrance_weight = 0
end)

---------------------------------------------------
---------------------------------------------------

--require"map/ocean_gen_config".final_level_shallow = 0.45 + 0.05-- 0.45
--require"map/ocean_gen_config".final_level_medium = 0.05 + 0.35-- 0.05
--require"map/ocean_gen_config".final_level_grave = 0.3 + 0.05-- 0.3

RetreatSetpiece"Waterlogged3"
--RetreatSetpiece"Waterlogged4"
table.insert(required_prefabs, "watertree_pillar")
ocean_prefill_setpieces.Waterlogged3 = {count = 1}
--ocean_prefill_setpieces.Waterlogged4 = {count = 1}

ocean_prefill_setpieces.BrinePool1 = {count = 1}

ocean_prefill_setpieces.HermitcrabIsland = {count = 1}

ocean_prefill_setpieces.www_crabking = {count = 1}
MakeSetpiece("www_crabking", {
	layout = {
		crabking_spawner = {{x = 0, y = 0}}, 
	}
})

ocean_prefill_setpieces.www_rocky = {count = 1}
MakeSetpiece("www_rocky", {
	layout = {
		ancienttree_gem = {{x = 0, y = 0}},
		rocky = {{x = 0, y = 0}}
	},
	ground_types = {
		WORLD_TILES.UNDERROCK
	},
	ground = {
		{0, 1, 0}, 
		{1, 1, 1}, 
		{0, 1, 0}
	}
})

ocean_prefill_setpieces.www_monkeyqueen = {count = 1}
MakeSetpiece("www_monkeyqueen", {
	layout = {
		monkeyqueen = {{x = 0, y = 0}},
		monkeypillar = {
			{x = 0, y = 1.75}, 
			{x = 0, y = -1.75}, 
			{x = 1.75, y = 0}, 
			{x = -1.75, y = 0}
		}
	},
	ground_types = {
		WORLD_TILES.MONKEY_GROUND
	},
	ground = {
		{0, 1, 1, 1, 0}, 
		{1, 1, 1, 1, 1}, 
		{1, 1, 1, 1, 1}, 
		{1, 1, 1, 1, 1}, 
		{0, 1, 1, 1, 0}, 
	},
})

ocean_prefill_setpieces.www_lonermerm = {count = 1}
MakeSetpiece("www_lonermerm", {
	layout = {
		mermwatchtower = {{x = 0, y = 0}},
	},

	ground_types = {
		WORLD_TILES.WOODFLOOR, 
	},
	ground = {
		{1, 1}, 
		{1, 1}
	},
}) 

---------------------------------------------------
---------------------------------------------------

FixRoom("OceanCoastalShore", function(self)
	self.contents.countprefabs.wobster_den_spawner_shore = 1
end)

FixRoom("OceanCoastal", function(self)
	self.contents.countstaticlayouts = nil
	self.contents.countprefabs.boat_otterden = 1
end)

FixRoom("OceanSwell", function(self)
	self.contents.countstaticlayouts = nil
	self.required_prefabs = nil
	self.contents.countprefabs.seastack_spawner_swell = 1
	self.contents.countprefabs.oceanfish_shoalspawner = 2
end)

FixRoom("OceanRough", function(self)
	self.contents.countstaticlayouts = nil
	self.required_prefabs = nil
	self.contents.countprefabs.seastack_spawner_rough = 1
	self.contents.countprefabs.waterplant_spawner_rough = 1
end)

FixRoom("OceanHazardous", function(self)
	self.contents.countstaticlayouts = nil
	self.required_prefabs = nil
end)

---------------------------------------------------
---------------------------------------------------

AddLevelPreInitAny(function(self)
	for name, data in pairs(Layouts) do 
		if (data.start_mask == nil) 
		or (data.start_mask == PLACE_MASK.NORMAL) then 
			data.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
		end 
		
		if (data.fill_mask == nil) 
		or (data.fill_mask == PLACE_MASK.NORMAL) then 
			data.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
		end 
	end
end)

---------------------------------------------------
---------------------------------------------------

IslandRoomTask{
	tags = {
		"lunacyarea", 
		"moonhunt", 
--		"MushGnomeSpawnArea", 
	}, 
	value = WORLD_TILES.METEORCOAST_NOISE, 
	required_prefabs = {
		"moon_fissure", 
		"moon_altar_rock_glass", 
	}, 	
	task_init = function(self)
		table.insert(self.room_tags, "MushGnomeSpawnArea")
	end, 
	-----------------------------------------------------
	contents = {
		countstaticlayouts = MakeSetpiece{
			layout = {
				moonspiderden = {{x = 0, y = 0}}, 
				mushgnome_spawner = {{x = 0, y = 0}}, 
				cavelightmoon = {
					{x = 0, y = 0}
--					{x = 0, y = 1}, 
--					{x = 0.75, y = -0.5}, 
--					{x = -0.75, y = -0.5}
				}, 
				moon_fissure = {
					{x = 0, y = 1}, 
					{x = 0.75, y = -0.5}, 
					{x = -0.75, y = -0.5}
				}, 
			},
	
			ground_types = {
				WORLD_TILES.PEBBLEBEACH
			},
			ground = {
				{1, 1, 1}, 
				{1, 1, 1}, 
				{1, 1, 1}, 
			},
		}, 
-----------------------------------------------------
		countprefabs = {
			archive_resonator = 1, 
--			wormhole_MARKER = 1, 
			
		-- VEGETATION
			sapling_moon = 5, 
			grass = 3, 
			berrybush = 1, 
			rock_avocado_bush = 2, 
			
		-- NATIVES
			hotspring = 2, 
			fruitdragon = 1,
			carrat_planted = 2,  
			
		-- MINERALS 
			moonglass_rock = 3, 
			rock2 = 1, 
			
		-- PETRIFICATION
			driftwood_small2 = 1, 
			driftwood_small1 = 1, 
			driftwood_tall = 1, 
			dead_sea_bones = 1, 
			
		-- LUNARITIES
			moon_altar_rock_glass = 1, 
			
		-- TREES
			moon_tree = 20, 
--			mushtree_moon = 1, 
			
		-- INDICES OF CIVILISAION
--							skeleton = 1, 
--							pickaxe = 1, 
			flower_rose = 1, 
--							flower_evil = 1, 
		}
	}
}

---------------------------------------------------
---------------------------------------------------

IslandRoomTask{
	tags = {
	}, 
	value = WORLD_TILES.MARSH, 
	required_prefabs = {
		"toadstool_cap", 
		"mermhouse", 
	}, 	
	-----------------------------------------------------
	contents = {
		countstaticlayouts = MakeSetpiece{
			layout = {
				toadstool_cap = {{x = 0, y = 0}}, 
			},
	
			ground_types = {
				WORLD_TILES.CAVE
			},
			ground = {
				{0, 1, 1, 0}, 
				{1, 1, 1, 1}, 
				{1, 1, 1, 1}, 
				{0, 1, 1, 0}, 
			},
		}, 
-----------------------------------------------------
		countprefabs = {
			reeds = 8, 
			pond_mos = 2, 
			
			mermhouse = 3, 
			
			marsh_tree = 12, 
			marsh_bush = 8, 
			
			flower_cave = 4, 
			flower_cave_double = 2, 
			flower_cave_triple = 2, 
			
			slurtlehole = 5, 
		}
	}
}

---------------------------------------------------
---------------------------------------------------

IslandRoomTask{
	tags = {
		"Nightmare", 
		"Atrium"
	}, 
	value = WORLD_TILES.MUD, 
	required_prefabs = {
		"ancient_altar", 
		"minotaur_spawner", 
	}, 	
	-----------------------------------------------------
	contents = {
		countstaticlayouts = MakeSetpiece{
			layout = {
				ancient_altar = {{x = 0, y = 0}},
				ruins_statue_mage_spawner = {
					{x = 2, y = 2}, 
					{x = 2, y = -2}, 
					{x = -2, y = -2}, 
					{x = -2, y = 2}
				}
			},
		
			ground_types = {
				WORLD_TILES.TRIM, 
				WORLD_TILES.BRICK
			},
			ground = {
				{0, 2, 2, 2, 2, 0}, 
				{2, 2, 1, 1, 2, 2},
				{2, 1, 1, 1, 1, 2}, 
				{2, 1, 1, 1, 1, 2}, 
				{2, 2, 1, 1, 2, 2},
				{0, 2, 2, 2, 2, 0}
			},
		}, 
-----------------------------------------------------
		countprefabs = {
			monkeybarrel_spawner = 3, 
			cave_banana_tree = 5, 
			slurper_spawner = 1, 
			pond_cave = 1, 
			nightmarelight = 1, 
			fissure_lower = 3, 
			fossil_stalker = 8, 
			ruins_cavein_obstacle = 8, 
			minotaur_spawner = 1, 
			atrium_gate = 1, 
			hutch_fishbowl = 1, 
		}
	}
}

----------------------------------------------------------------------------------
--			*			*	POST DEVELOPMENT ADDITIONS	*			*			--
----------------------------------------------------------------------------------

AddLevelPreInit(NAME, function(self)
--	self.overrides.no_joining_islands = false 
	getmetatable(WorldSim).__index.SeparateIslands = function() 
		print("Nullifying SeparateIslands")
	end 
end)

local hacker = require"tools/upvaluehacker"
local WORLDSETTINGS_GROUP = hacker.GetUpvalue(
	require"map/customize".GetWorldSettingsOptions, 
	"WORLDSETTINGS_GROUP")
	
if WORLDSETTINGS_GROUP then 	
	for prefab, group in pairs{
		rifts_frequency_cave = "misc", 
		rifts_enabled_cave = "misc", 
		atriumgate = "misc", 
		
		toadstool = "giants", 
		daywalker = "giants", 
		
		mushtree_regrowth = "resources", 
		mushtree_moon_regrowth = "resources", 
		flower_cave_regrowth = "resources", 
		
		itemmimics = "monsters", 
		chest_mimics = "monsters", 
		molebats = "monsters", 
		nightmarecreatures = "monsters", 
		
		monkey_setting = "animals", 
		rocky_setting = "animals", 
		slurtles_setting = "animals", 
		mushgnome = "animals", 
		lightfliers = "animals", 
	} do
		if WORLDSETTINGS_GROUP[group]
		and WORLDSETTINGS_GROUP[group].items
		and WORLDSETTINGS_GROUP[group].items[prefab]
		and WORLDSETTINGS_GROUP[group].items[prefab].world then 
			table.insert(WORLDSETTINGS_GROUP[group].items[prefab].world, "forest")
		end  
	end 
end
