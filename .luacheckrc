std = "lua51"
max_line_length = 120
codes = true

exclude_files = {
    "scripts/tools/upvaluehacker.lua",
}

ignore = {
    "212",
}

read_globals = {
    "GLOBAL",
    "modimport",
    "modinfo",
    "GetModConfigData",
    "unpack",

    "AddLevel",
    "AddLevelPreInit",
    "AddLevelPreInitAny",
    "AddTaskSet",
    "AddTaskSetPreInit",
    "AddTask",
    "AddTaskPreInit",
    "AddRoom",
    "AddRoomPreInit",
    "AddTile",
    "AddPrefabPostInit",
    "AddPlayerPostInit",
    "AddComponentPostInit",
    "AddSimPostInit",

    "KEYS",
    "LOCKS",
    "WORLD_TILES",
    "GROUND",
    "PLACE_MASK",
    "LAYOUT",
    "LAYOUT_POSITION",
    "LEVELTYPE",
    "NODE_TYPE",

    "TheNet",
    "TheWorld",
    "TheFrontEnd",
    "WorldSim",
}

globals = {
    "env",
    "TUNING",

    "NOTHING_FUNCTION",
    "print",
    "overwrite",
    "NAME",
    "MakeName",
    "Layouts",
    "RetreatSetpiece",
    "MakeSetpiece",
    "GetSetpiece",
    "Noise",
    "Room",
    "FixRoom",
    "Task",
    "IslandTask",
    "IslandRoomTask",
    "Level",
    "IncludeTask",
    "IncludeCaveTask",
    "IncludeCaveTaskObj",
}

files["modinfo.lua"] = {
    allow_defined_top = true,
    ignore = { "131" },
}
