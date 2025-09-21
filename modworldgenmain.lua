----------------------------------------------------------------------------------
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
--			*			*		MAP STRUCTURE			*			*			--
----------------------------------------------------------------------------------

modimport("scripts/forest")

modimport("scripts/caves")

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
