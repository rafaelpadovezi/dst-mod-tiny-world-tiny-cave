----------------------------------------------------------------------------------
--[[		*			*				NOTES			*			*			--
----------------------------------------------------------------------------------
]] ----------------------------------------------------------------------------------
--			*			*		UNIVERSAL FUNCTIONS		*			*			--
----------------------------------------------------------------------------------
GLOBAL.setmetatable(env, {
    __index = function(self, index)
        return GLOBAL.rawget(GLOBAL, index)
    end
})

function env.NOTHING_FUNCTION()
end

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
                if (replace_this_with_nil ~= nil) and #results == 1 and results[1] == replace_this_with_nil then
                    results = {nil}
                end
                return unpack(results)
            end
        end

        local results = type(old) == "function" and {old(...)} or {old}

        if post then
            local results = {post(...)}

            if #results > 0 then
                if (replace_this_with_nil ~= nil) and #results == 1 and results[1] == replace_this_with_nil then
                    results = {nil}
                end
                return unpack(results)
            end
        end

        return unpack(results)
    end

    return tabula[name]
end

for _, data in pairs(modinfo.configuration_options or {}) do
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
    if not data then
        data = {}
    end
    for k, v in pairs {
        layout_position = LAYOUT_POSITION.CENTER,
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        type = LAYOUT.STATIC,
        ground = {{0}}
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

        return {
            [name] = 1
        }
    end
end

env.Layouts = require"map/layouts".Layouts
function env.MakeSetpiece(name, data)
    if data == nil then
        data = name
        name = MakeName(data)
    end

    require"map/layouts".Layouts[name] = TreatSetpiece(data)

    return {
        [name] = 1
    }
end

function env.GetSetpiece(name, data)
    require"map/layouts".Layouts[name] = require"map/static_layout".Get("map/static_layouts/" .. name,
        TreatSetpiece(data))

    return {
        [name] = 1
    }
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

    for k, v in pairs {
        tags = {},
        colour = {
            r = 1,
            g = 0,
            b = 0.0,
            a = 1
        }
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
        if not self.tags then
            self.tags = {}
        end

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

    for k, v in pairs {
        colour = {
            r = 1,
            g = 0,
            b = 0.0,
            a = 1
        },
        room_bg = GROUND.IMPASSABLE,
        background_room = "Empty_Cove",
        room_tags = {},
        room_choices = {}
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
        self.room_choices = {
            [name] = 1
        }
        if not self.room_tags then
            self.room_tags = {}
        end

        if data.task_init then
            print("task_init", self, name)
            data.task_init(self)
        end
    end)

    return name
end

function env.Level(data)
    -- for k, v in pairs {
    --     id = NAME,
    --     name = modinfo.name,
    --     desc = modinfo.description,
    --     version = 4,
    --     location = data.location
    -- } do
    --     if data[k] == nil then
    --         data[k] = v
    --     end
    -- end

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
    ocean_population = {"OceanCoastalShore", "OceanCoastal", "OceanSwell", "OceanRough", "OceanHazardous"}
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
        regrowth = "veryslow",
        --		twiggytrees_regrowth = "never", 

        -- OCEAN ITEMS
        --		ocean_bullkelp = "rare", 
        --		ocean_otterdens = "rare", 
        ocean_wobsterden = "often",

        -- ALWAYS
        hounds = "always",
        krampus = "always",
        liefs = "always",
        pirateraids = "rare",
        squid = "always"
    }
})

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
        CritterDen = 1
    }
end)

RetreatSetpiece "Charlie1"
RetreatSetpiece "Charlie2"
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
    self.required_prefabs = {"resurrectionstone", "moon_altar_rock_idol"}
    self.contents.countstaticlayouts = RetreatSetpiece "ResurrectionStone"
    self.contents.countprefabs.meteorspawner = 1
    self.contents.countprefabs.flint = 3
    self.contents.countprefabs.moon_altar_rock_idol = 1
    self.contents.countprefabs.rock2 = 5
    self.contents.countprefabs.rock_flintless = 9
    self.contents.distributeprefabs.rock_ice = nil
    self.contents.countprefabs.burntground_faded = nil
end)

FixRoom("CritterDen", function(self)
    self.required_prefabs = {"terrariumchest", "oceantreenut"}
    self.contents.countprefabs.flint = 1
    self.contents.countstaticlayouts = RetreatSetpiece "Terrarium_Forest_Spiders"
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
        DeepDeciduous = 1
    }
end)

FixRoom("DeepDeciduous", function(self)
    self.required_prefabs = {"resurrectionstone"}
    self.contents.countstaticlayouts = RetreatSetpiece "ResurrectionStone"
    self.random_node_exit_weight = 0
end)

FixRoom("MagicalDeciduous", function(self)
    self.required_prefabs = {"rock_moon_shell", "pigking"}
    self.random_node_entrance_weight = 0
    --	self.contents.countprefabs.pond = 1
    self.contents.countprefabs.pighouse = 4
    self.contents.countprefabs.rock_moon_shell = 1
    self.contents.countprefabs.deerspawningground = 1
    self.contents.countprefabs.statueglommer = 1
    self.contents.countprefabs.molehill = 1
    self.contents.countstaticlayouts = RetreatSetpiece "DefaultPigking"

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
    self.required_prefabs = {"moonbase", "moon_altar_rock_seed"}

    self.random_node_entrance_weight = 0
    --	self.contents.countprefabs.walrus_camp = 1
    self.contents.countprefabs.moon_altar_rock_seed = 1
    -- self.contents.countprefabs.rabbithouse = 4

    self.contents.countprefabs.berrybush = 1
    self.contents.countprefabs.grass = 1
    self.contents.countprefabs.sapling = 1
end)

FixRoom("WalrusHut_Grassy", function(self)
    self.contents.countstaticlayouts = RetreatSetpiece "Maxwell5"
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
        DeepForest = 1
    }
end)

FixRoom("MandrakeHome", function(self)
    self.required_prefabs = {"beequeenhive"}

    self.random_node_exit_weight = 0
    self.contents.countstaticlayouts = RetreatSetpiece "MooseNest"
    self.contents.countprefabs.beequeenhive = 1
    self.contents.countprefabs.mandrake_planted = 3

    --	self.contents.countprefabs.berrybush = 1
    self.contents.countprefabs.grass = 1
    self.contents.countprefabs.sapling = 1
    self.contents.countprefabs.beehive = 1
    self.contents.countprefabs.wasphive = 1
    self.contents.countprefabs.walrus_camp = 1
end)

FixRoom("BeefalowPlain", function(self)
    self.required_prefabs = {"beefalo", "sculpture_rook", "sculpture_bishop", "sculpture_knight"}

    --	self.random_node_entrance_weight = 0
    self.contents.countstaticlayouts = RetreatSetpiece "Sculptures_1"
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
    self.required_prefabs = {"junk_pile_big"}

    self.random_node_entrance_weight = 0
    self.contents.countstaticlayouts = RetreatSetpiece "junk_yard"
    self.contents.distributeprefabs.trees.prefabs = {"evergreen"}
    self.contents.countprefabs.spiderden_2 = 1
    self.contents.countprefabs.spiderden = 3
    self.contents.countprefabs.berrybush = 1
    self.contents.countprefabs.grass = 1
    self.contents.countprefabs.sapling = 4
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
        Badlands = 1,
        DragonflyArena = 1
    }
end)

FixRoom("Badlands", function(self)
    self.tags = {"sandstorm"}
    self.required_prefabs = {"resurrectionstone"}
    self.contents.countstaticlayouts = RetreatSetpiece "ResurrectionStone"
    self.random_node_exit_weight = 0
end)

FixRoom("LightningBluffOasis", function(self)
    self.tags = {"sandstorm"}
    self.random_node_exit_weight = 0
    self.LightningBluffAntlion = 0
    self.contents.countprefabs.lightninggoat = 2
    self.contents.countprefabs.oasis_cactus = 5
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
            lightninggoat = {{
                x = 0,
                y = 0
            }},
            tumbleweedspawner = {{
                x = 0,
                y = 0
            }},
            buzzardspawner = {{
                x = 0,
                y = 0
            }}
        }
    })
end)

FixRoom("DragonflyArena", function(self)
    self.tags = {"sandstorm"}
    self.random_node_entrance_weight = 0
end)

---------------------------------------------------
---------------------------------------------------

IncludeTask("Squeltch", function(self)
    self.make_loop = true
    self.locks = {LOCKS.TIER1}
    self.keys_given = {}
    self.room_choices = {
        Marsh = 1,
        SlightlyMermySwamp = 1

    }
end)

FixRoom("Marsh", function(self)
    self.random_node_exit_weight = 0
    self.contents.countprefabs.mermhouse = 1
    self.contents.countprefabs.marsh_bush = 2
    self.contents.countprefabs.marsh_tree = 2
    self.contents.countprefabs.pond_mos = 1
    self.contents.countprefabs.cave_entrance = 1
    self.contents.countprefabs.reeds = 5
    self.contents.countprefabs.tentacle = 2
end)

FixRoom("SlightlyMermySwamp", function(self)
    self.contents.countprefabs.mermhouse = 2
    self.contents.countprefabs.tentacle = 3
    self.contents.countprefabs.pond_mos = 1
    self.contents.countprefabs.reeds = 5
    self.contents.countprefabs.spiderden = 1
end)

---------------------------------------------------
---------------------------------------------------

-- require"map/ocean_gen_config".final_level_shallow = 0.45 + 0.05-- 0.45
-- require"map/ocean_gen_config".final_level_medium = 0.05 + 0.35-- 0.05
-- require"map/ocean_gen_config".final_level_grave = 0.3 + 0.05-- 0.3

RetreatSetpiece "Waterlogged3"
-- RetreatSetpiece"Waterlogged4"
table.insert(required_prefabs, "watertree_pillar")
ocean_prefill_setpieces.Waterlogged3 = {
    count = 1
}
-- ocean_prefill_setpieces.Waterlogged4 = {count = 1}

ocean_prefill_setpieces.BrinePool1 = {
    count = 1
}

ocean_prefill_setpieces.HermitcrabIsland = {
    count = 1
}

ocean_prefill_setpieces.www_crabking = {
    count = 1
}
MakeSetpiece("www_crabking", {
    layout = {
        crabking_spawner = {{
            x = 0,
            y = 0
        }}
    }
})

ocean_prefill_setpieces.www_rocky = {
    count = 1
}
MakeSetpiece("www_rocky", {
    layout = {
        ancienttree_gem = {{
            x = 0,
            y = 0
        }},
        rocky = {{
            x = 0,
            y = 0
        }}
    },
    ground_types = {WORLD_TILES.UNDERROCK},
    ground = {{0, 1, 0}, {1, 1, 1}, {0, 1, 0}}
})

ocean_prefill_setpieces.www_monkeyqueen = {
    count = 1
}
MakeSetpiece("www_monkeyqueen", {
    layout = {
        monkeyqueen = {{
            x = 0,
            y = 0
        }},
        monkeypillar = {{
            x = 0,
            y = 1.75
        }, {
            x = 0,
            y = -1.75
        }, {
            x = 1.75,
            y = 0
        }, {
            x = -1.75,
            y = 0
        }}
    },
    ground_types = {WORLD_TILES.MONKEY_GROUND},
    ground = {{0, 1, 1, 1, 0}, {1, 1, 1, 1, 1}, {1, 1, 1, 1, 1}, {1, 1, 1, 1, 1}, {0, 1, 1, 1, 0}}
})

ocean_prefill_setpieces.www_lonermerm = {
    count = 1
}
MakeSetpiece("www_lonermerm", {
    layout = {
        mermwatchtower = {{
            x = 0,
            y = 0
        }}
    },

    ground_types = {WORLD_TILES.WOODFLOOR},
    ground = {{1, 1}, {1, 1}}
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
        if (data.start_mask == nil) or (data.start_mask == PLACE_MASK.NORMAL) then
            data.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        end

        if (data.fill_mask == nil) or (data.fill_mask == PLACE_MASK.NORMAL) then
            data.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        end
    end
end)

---------------------------------------------------
---------------------------------------------------

IslandRoomTask {
    tags = {"lunacyarea", "moonhunt" --		"MushGnomeSpawnArea", 
    },
    value = WORLD_TILES.METEORCOAST_NOISE,
    required_prefabs = {"moon_fissure", "moon_altar_rock_glass"},
    task_init = function(self)
        table.insert(self.room_tags, "MushGnomeSpawnArea")
    end,
    -----------------------------------------------------
    contents = {
        countstaticlayouts = MakeSetpiece {
            layout = {
                moonspiderden = {{
                    x = 0,
                    y = 0
                }},
                mushgnome_spawner = {{
                    x = 0,
                    y = 0
                }},
                cavelightmoon = {{
                    x = 0,
                    y = 0
                } --					{x = 0, y = 1}, 
                --					{x = 0.75, y = -0.5}, 
                --					{x = -0.75, y = -0.5}
                },
                moon_fissure = {{
                    x = 0,
                    y = 1
                }, {
                    x = 0.75,
                    y = -0.5
                }, {
                    x = -0.75,
                    y = -0.5
                }}
            },

            ground_types = {WORLD_TILES.PEBBLEBEACH},
            ground = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}}
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
            flower_rose = 1
            --							flower_evil = 1, 
        }
    }
}

---------------------------------------------------
---------------------------------------------------

IslandRoomTask {
    tags = {},
    value = WORLD_TILES.ROCKY,
    contents = {
        countprefabs = {
            rock1 = 6,
            rock2 = 5,
            rock_flintless = 3,
            meteorspawner = 1,
            flint = 3,
            shadowmeteor = 1
        }
    }
}

---------------------------------------------------
---------------------------------------------------

---------------------------------------------------
-- CAVES
---------------------------------------------------

env.cave_tasks = {}
env.CAVE_NAME = NAME .. " - Cave"
AddTaskSet(CAVE_NAME, {
    location = "cave",
    required_prefabs = {"tentacle_pillar_atrium"},
    tasks = cave_tasks,
    set_pieces = {
        ["ResurrectionStone"] = {
            count = 2,
            tasks = {"MudLights", "RockyLand", "FungalNoiseForest", "RabbitTown", "CentipedeCaveTask"}
        },
        ["skeleton_notplayer"] = {
            count = 1,
            tasks = {"MudLights", "RockyLand", "FungalNoiseForest", "RabbitTown", "CentipedeCaveTask"}
        },
        ["TentaclePillarToAtrium"] = {
            count = 1,
            tasks = {"MudLights"}
        }
    }
})
AddLevel(LEVELTYPE.SURVIVAL, {
    id = CAVE_NAME,
    name = modinfo.name .. " - Cave",
    desc = modinfo.description .. " - Cave",
    version = 4,
    location = "cave",

    overrides = {
        world_size = "small",
        task_set = CAVE_NAME
    },
    background_node_range = {0, 1}
})

function env.IncludeCaveTask(name, func)
    table.insert(cave_tasks, name)
    AddTaskPreInit(name, function(self)
        self.background_room = "BGImpassable"

        --		self.cove_room_name = "Empty_Cove"
        --		self.cove_room_chance = 1
        if func then
            func(self)
        end
    end)
end

IncludeCaveTask("CaveExitTask1", function(self)
    self.make_loop = false
    self.locks = {}
    self.keys_given = {KEYS.CAVE, KEYS.TIER1}
    self.background_room = "BGSinkhole"
    self.room_bg = WORLD_TILES.SINKHOLE
    self.room_choices = {
        CaveExitRoom = 1
    }
end)

IncludeCaveTaskObj = function(name, obj)
    IncludeCaveTask(name, function(self)
        self.make_loop = obj.make_loop
        self.locks = obj.locks
        self.keys_given = obj.keys_given
        self.background_room = obj.background_room
        self.room_bg = obj.room_bg
        self.room_choices = obj.room_choices
        self.colour = obj.colour
        self.maze_tiles = obj.maze_tiles
        self.room_tags = obj.room_tags
        self.entrance_room = obj.entrance_room
        self.cove_room_chance = obj.cove_room_chance
        self.cove_room_max_edges = obj.cove_room_max_edges
        self.required_prefabs = obj.required_prefabs
    end)
end

IncludeCaveTaskObj("MudLights", {
    locks = {LOCKS.CAVE, LOCKS.TIER1},
    keys_given = {KEYS.CAVE, KEYS.TIER2},
    room_choices = {
        LightPlantField = 1,
        WormPlantField = 1
    },
    background_room = "WormPlantField",
    room_bg = WORLD_TILES.MUD,
    -- room_tags = {"Nightmare", "Atrium"},
    colour = {
        r = 0.7,
        g = 0.5,
        b = 0.0,
        a = 0.9
    }
})

-- Centipede Cave
IncludeCaveTaskObj("CentipedeCaveTask", {
    locks = {LOCKS.CAVE, LOCKS.TIER2},
    keys_given = {KEYS.CAVE, KEYS.TIER3, KEYS.CENTIPEDE},
    room_choices = {
        ["VentsRoom"] = 1,
        ["CentipedeNest"] = 1
    },
    -- entrance_room = "MilitaryEntrance",
    background_room = "BGVentsRoom", -- BGVentsRoom
    room_bg = WORLD_TILES.VENT,
    colour = {
        r = 0.8,
        g = 0.8,
        b = 0.8,
        a = 0.9
    },

    -- Trying out a large amount of coves to really make the generation interesting.
    cove_room_name = "Blank",
    cove_room_chance = 1,
    cove_room_max_edges = 50
})

IncludeCaveTaskObj("CentipedeCaveIslandTask", {
    locks = {LOCKS.CENTIPEDE},
    keys_given = {},
    room_tags = {},
    level_set_piece_blocker = true,
    room_choices = {
        ["RuinsIsland"] = 1,
        ["RuinsIsland_entrance"] = 1

        -- ["Empty_Cove"] = 2,
    },
    region_id = "ruins_island",
    background_room = "BGImpassableRock",
    room_bg = WORLD_TILES.TILES,
    colour = {
        r = 0.3,
        g = 0.3,
        b = 0.3,
        a = 0.9
    }
})

IncludeCaveTaskObj("ArchiveMaze", {
    locks = {LOCKS.TIER1},
    keys_given = {},
    room_tags = {"nocavein"},
    required_prefabs = {"archive_orchestrina_main", "archive_lockbox_dispencer", "archive_lockbox_dispencer",
                        "archive_lockbox_dispencer"},
    entrance_room = "ArchiveMazeEntrance",
    room_choices = {
        ["ArchiveMazeRooms"] = 2
    },
    room_bg = WORLD_TILES.ARCHIVE,
    --    maze_tiles = {rooms = {"archive_hallway"}, bosses = {"archive_hallway"}, keyroom = {"archive_keyroom"}, archive = {start={"archive_start"}, finish={"archive_end"}}, bridge_ground=WORLD_TILES.FAKE_GROUND},
    maze_tiles = {
        rooms = {"archive_hallway", "archive_hallway_two"},
        bosses = {"archive_hallway"},
        archive = {
            keyroom = {"archive_keyroom"}
        },
        special = {
            finish = {"archive_end"},
            start = {"archive_start"}
        },
        bridge_ground = WORLD_TILES.FAKE_GROUND
    },
    background_room = "ArchiveMazeRooms",
    cove_room_chance = 0,
    cove_room_max_edges = 0,
    make_loop = true,
    colour = {
        r = 1,
        g = 0,
        b = 0.0,
        a = 1
    }
})

IncludeCaveTaskObj("AtriumMaze", {
    locks = {LOCKS.TIER1, LOCKS.RUINS},
    keys_given = {},
    room_tags = {"Atrium", "Nightmare"},
    required_prefabs = {"atrium_gate"},
    entrance_room = "AtriumMazeEntrance",
    room_choices = {
        ["AtriumMazeRooms"] = 2
    },
    room_bg = WORLD_TILES.TILES,
    maze_tiles = {
        rooms = {"atrium_hallway", "atrium_hallway_two", "atrium_hallway_three"},
        bosses = {"atrium_hallway_three"},
        special = {
            start = {"atrium_start"},
            finish = {"atrium_end"}
        },
        bridge_ground = WORLD_TILES.FAKE_GROUND
    },
    background_room = "AtriumMazeRooms",
    make_loop = true,
    colour = {
        r = 0.6,
        g = 0.6,
        b = 0.0,
        a = 1
    }
})

IncludeCaveTaskObj("RockyLand", {
    locks = {LOCKS.CAVE, LOCKS.TIER1},
    keys_given = {KEYS.CAVE, KEYS.TIER2},
    room_choices = {
        SlurtleCanyon = 1
    },
    background_room = "BGRockyCaveRoom",
    room_bg = WORLD_TILES.CAVE,
    colour = {
        r = 0.5,
        g = 0.5,
        b = 0.5,
        a = 0.9
    }
})

IncludeCaveTask("ToadStoolTask1", function(self)
    self.locks = {LOCKS.CAVE, LOCKS.TIER2}
    self.keys_given = {}
    self.background_room = "Blank"
    self.room_bg = WORLD_TILES.MUD
    self.room_choices = {
        ToadstoolArenaMud = 1
    }
    self.colour = {
        r = 1.0,
        g = 0.0,
        b = 0.0,
        a = 0.9
    }
end)

IncludeCaveTaskObj("FungalNoiseForest", {
    locks = {LOCKS.CAVE, LOCKS.TIER1},
    keys_given = {KEYS.CAVE, KEYS.TIER2, KEYS.ENTRANCE_OUTER},
    room_choices = {
        FungusNoiseForest = 1
    },
    background_room = "FungusNoiseMeadow",
    room_bg = WORLD_TILES.FUNGUS,
    colour = {
        r = 0.0,
        g = 0.5,
        b = 1.0,
        a = 0.9
    }
})

IncludeCaveTaskObj("RabbitTown", {
    locks = {LOCKS.CAVE, LOCKS.TIER1},
    keys_given = {KEYS.CAVE, KEYS.RABBIT, KEYS.TIER2, KEYS.ENTRANCE_OUTER},
    room_choices = {
        ["RabbitTown"] = 1,
        ["RabbitArea"] = 1
    },
    background_room = "BGSinkhole",
    room_bg = WORLD_TILES.SINKHOLE,
    colour = {
        r = 2.0,
        g = 0.6,
        b = 0.0,
        a = 0.9
    }
})

IncludeCaveTaskObj("LichenLand", {
    locks = {LOCKS.TIER1},
    keys_given = {KEYS.TIER2, KEYS.RUINS},
    room_tags = {"Nightmare"},
    room_choices = {
        LichenLand = 1
    },
    room_bg = WORLD_TILES.MUD,
    background_room = "BGWilds",
    colour = {
        r = 0,
        g = 0,
        b = 0.0,
        a = 1
    }
})

IncludeCaveTaskObj("Sacred", {
    locks = {LOCKS.TIER2, LOCKS.RUINS},
    keys_given = {KEYS.TIER3, KEYS.RUINS, KEYS.SACRED},
    room_tags = {"Nightmare"},
    entrance_room = "BridgeEntrance",
    room_choices = {
        SacredBarracks = 1,
        Spiral = 1,
        BrokenAltar = 1
    },
    room_bg = WORLD_TILES.TILES,
    background_room = "Blank",
    colour = {
        r = 0.6,
        g = 0.6,
        b = 0.0,
        a = 1
    }
})

IncludeCaveTaskObj("TheLabyrinth", {
    locks = {LOCKS.TIER3, LOCKS.RUINS},
    keys_given = {KEYS.TIER4, KEYS.RUINS, KEYS.SACRED},
    room_tags = {"Nightmare"},
    entrance_room = "LabyrinthEntrance",
    room_choices = {
        -- Labyrinth = 1,
        RuinedGuarden = 1
    },
    room_bg = WORLD_TILES.IMPASSABLE,
    background_room = "Labyrinth",
    colour = {
        r = 0.4,
        g = 0.4,
        b = 0.0,
        a = 1
    }
})

IncludeCaveTaskObj("SacredAltar", {
    locks = {LOCKS.TIER3, LOCKS.RUINS},
    keys_given = {KEYS.TIER4, KEYS.RUINS, KEYS.SACRED},
    room_tags = {"Nightmare"},
    room_choices = {
        Altar = 1
    },
    room_bg = WORLD_TILES.TILES,
    entrance_room = "BridgeEntrance",
    background_room = "Blank",
    colour = {
        r = 0.6,
        g = 0.3,
        b = 0.0,
        a = 1
    }
})

-- function env.CaveTask(name, data)
--     local name = Task(name, data)

--     AddTaskPreInit(name, function(self)
--         -- INSULARITY
--         if self.region_id == nil then
--             self.region_id = name
--         end
--         self.type = NODE_TYPE.Room
--         self.cove_room_name = "Empty_Cove"
--         self.cove_room_chance = 1
--         self.cove_room_max_edges = 1
--     end)

--     return name
-- end

-- function env.CaveRoomTask(name, data)
--     if data == nil then
--         data = name
--         name = MakeName(data)
--     end

--     local name = CaveTask(name, {})

--     Room(name, data)
--     FixRoom(name, function(self)
--     end)

--     AddTaskPreInit(name, function(self)
--         self.room_choices = {
--             [name] = 1
--         }
--         if not self.room_tags then
--             self.room_tags = {}
--         end

--         if data.task_init then
--             print("task_init", self, name)
--             data.task_init(self)
--         end
--     end)

--     return name
-- end

-- CaveRoomTask {
--     tags = {"Nightmare", "Atrium"},
--     value = WORLD_TILES.TILES,
--     -----------------------------------------------------
--     contents = {
--         countstaticlayouts = MakeSetpiece {
--             layout = {
--                 ancient_altar = {{
--                     x = 0,
--                     y = 0
--                 }}
--             },

--             ground_types = {WORLD_TILES.TRIM, WORLD_TILES.BRICK},
--             ground = {{0, 2, 2, 2, 2, 0}, {2, 2, 1, 1, 2, 2}, {2, 1, 1, 1, 1, 2}, {2, 1, 1, 1, 1, 2},
--                       {2, 2, 1, 1, 2, 2}, {0, 2, 2, 2, 2, 0}}
--         },
--         -----------------------------------------------------
--         countprefabs = {
--             nightmarelight = 1,
--             fossil_stalker = 8,
--             ruins_cavein_obstacle = 8,
--             atrium_gate = 1
--         }
--     }
-- }

----------------------------------------------------------------------------------
--			*			*	POST DEVELOPMENT ADDITIONS	*			*			--
----------------------------------------------------------------------------------

AddLevelPreInit(NAME, function(self)
    --	self.overrides.no_joining_islands = false 
    getmetatable(WorldSim).__index.SeparateIslands = function()
        print("Nullifying SeparateIslands")
    end
end)

local hacker = require "tools/upvaluehacker"
local WORLDSETTINGS_GROUP = hacker.GetUpvalue(require"map/customize".GetWorldSettingsOptions, "WORLDSETTINGS_GROUP")

if WORLDSETTINGS_GROUP then
    for prefab, group in pairs {
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
        lightfliers = "animals"
    } do
        if WORLDSETTINGS_GROUP[group] and WORLDSETTINGS_GROUP[group].items and WORLDSETTINGS_GROUP[group].items[prefab] and
            WORLDSETTINGS_GROUP[group].items[prefab].world then
            table.insert(WORLDSETTINGS_GROUP[group].items[prefab].world, "forest")
        end
    end
end
