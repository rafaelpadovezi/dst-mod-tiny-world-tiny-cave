local required_prefabs = {}
local ocean_prefill_setpieces = {}
local tasks = {}

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
        -- specialevent = "none",

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
        -- regrowth = "veryslow",
        --		twiggytrees_regrowth = "never", 

        -- OCEAN ITEMS
        --		ocean_bullkelp = "rare", 
        --		ocean_otterdens = "rare", 
        ocean_wobsterden = "often",

        -- ALWAYS
        hounds = "always",
        krampus = "always",
        liefs = "always",
        pirateraids = "rare"
        -- squid = "always"
    }
})

---------------------------------------------------
---------------------------------------------------

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

-- RetreatSetpiece "Charlie1"
-- RetreatSetpiece "Charlie2"
-- Layouts.Charlie2.layout_position = LAYOUT_POSITION.RANDOM

FixRoom("Graveyard", function(self)
    self.contents.countstaticlayouts = {
        -- Charlie1 = 1,
        -- Charlie2 = 1
    }
    self.contents.countprefabs.molehill = 3
    self.contents.countprefabs.gravestone = 10
    --	self.contents.countprefabs.cave_entrance = 1
    --	self.contents.countprefabs.wormhole_MARKER = 1
end)

FixRoom("Rocky", function(self)
    self.required_prefabs = {"resurrectionstone", "moon_altar_rock_idol"}
    self.contents.countstaticlayouts = RetreatSetpiece "ResurrectionStone"
    self.contents.countprefabs.meteorspawner = null
    self.contents.countprefabs.flint = 5
    self.contents.countprefabs.moon_altar_rock_idol = 1
    self.contents.countprefabs.rock2 = 7
    self.contents.countprefabs.rock_flintless = 9
    self.contents.distributeprefabs.rock_ice = nil
    self.contents.countprefabs.burntground_faded = nil
end)

FixRoom("CritterDen", function(self)
    self.contents.countprefabs.flint = 1
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
        DeepForest = 1,
        Forest = 1
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

    self.contents.countprefabs.grass = 25
    self.contents.countprefabs.sapling = 1
    self.contents.countprefabs.rabbithole = 4
    self.contents.countprefabs.berrybush = 1
end)

FixRoom("DeepForest", function(self)
    self.tags = {}
    self.random_node_entrance_weight = 0
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
            rock1 = 8,
            rock2 = 8,
            rock_flintless = 5,
            meteorspawner = 1,
            flint = 5
        }
    }
}

---------------------------------------------------
---------------------------------------------------
