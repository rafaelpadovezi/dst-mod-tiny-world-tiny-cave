local cave_tasks = {}
local CAVE_NAME = NAME .. " - Cave"

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

AddTaskSet(CAVE_NAME, {
    location = "cave",
    required_prefabs = {"tentacle_pillar_atrium"},
    tasks = cave_tasks,
    set_pieces = {
        ["ResurrectionStone"] = {
            count = 2,
            tasks = {"MudLights", "RockyLand", "FungalNoiseForest", "RabbitTown", "CentipedeCaveTask", "LichenLand"}
        },
        ["skeleton_notplayer"] = {
            count = 2,
            tasks = {"MudLights", "RockyLand", "FungalNoiseForest", "RabbitTown", "CentipedeCaveTask", "LichenLand"}
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
