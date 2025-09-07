# Unknown/Undocumented Functions Reference

This document covers functions found in the Tiny, Tiny World II mod that are not covered in the main docs.md reference file. These functions are either mod-specific utilities or advanced DST functions not commonly documented.

## World Generation Functions

### Layout and Mask Functions

**`PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED`**
```lua
data.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
data.fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
```
- **Purpose**: Placement mask that allows setpieces to spawn on normally restricted terrain
- **Usage**: Used to ensure setpieces can spawn in the constrained tiny world
- **Values**: Bitmask constant for world generation placement rules

**`LAYOUT_POSITION.CENTER` / `LAYOUT_POSITION.RANDOM`**
```lua
Layouts.Charlie2.layout_position = LAYOUT_POSITION.RANDOM
```
- **Purpose**: Controls where setpieces are positioned within their assigned areas
- **Values**: 
  - `CENTER` - Place at room center
  - `RANDOM` - Place at random valid location
- **Usage**: Fine-tune setpiece placement for better world generation

### Room Configuration Functions

**`AddTaskSet(name, data)`**
```lua
AddTaskSet(NAME, {
    location = "forest", 
    required_prefabs = required_prefabs, 
    tasks = tasks, 
    ocean_prefill_setpieces = ocean_prefill_setpieces
})
```
- **Purpose**: Register a complete set of world generation tasks
- **Parameters**: 
  - `name` (string) - Task set identifier
  - `data` (table) - Task set configuration including tasks, prefabs, and ocean content
- **Usage**: Create cohesive world generation rule sets

**`AddRoomPreInit(name, function)`**
```lua
AddRoomPreInit("Clearing", function(self)
    self.value = WORLD_TILES.IMPASSABLE
    self.contents = {}
end)
```
- **Purpose**: Modify existing room definitions before world generation
- **Parameters**: 
  - `name` (string) - Room name to modify
  - `function` - Modification function receiving room data
- **Usage**: Customize vanilla rooms without completely replacing them

**`AddTaskPreInit(name, function)`**
```lua
AddTaskPreInit(name, function(self)
    self.region_id = name
    self.type = NODE_TYPE.SeparatedRoom
end)
```
- **Purpose**: Modify task definitions before world generation
- **Usage**: Customize how tasks behave and connect to other areas

### Ocean Generation Functions

**`ocean_prefill_setpieces`**
```lua
ocean_prefill_setpieces.HermitcrabIsland = {count = 1}
ocean_prefill_setpieces.www_crabking = {count = 1}
```
- **Purpose**: Table defining which setpieces spawn in ocean areas
- **Structure**: `{[setpiece_name] = {count = number}}`
- **Usage**: Guarantee specific ocean content spawns

### Level Management Functions

**`AddLevelPreInit(name, function)`**
```lua
AddLevelPreInit(NAME, function(self)
    getmetatable(WorldSim).__index.SeparateIslands = function() 
        print("Nullifying SeparateIslands")
    end 
end)
```
- **Purpose**: Modify level behavior before world generation begins
- **Usage**: Override world generation behaviors like island separation

**`AddLevelPreInitAny(function)`**
```lua
AddLevelPreInitAny(function(self)
    for name, data in pairs(Layouts) do 
        if data.start_mask == PLACE_MASK.NORMAL then 
            data.start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED
        end 
    end
end)
```
- **Purpose**: Apply modifications to all levels
- **Usage**: Global changes to world generation behavior

## Terrain and Tile Functions

**`AddTile(name, type)`**
```lua
AddTile(name, "NOISE")
```
- **Purpose**: Register a new world tile type
- **Parameters**: 
  - `name` (string) - Tile name
  - `type` (string) - Tile type ("NOISE" for procedural tiles)
- **Usage**: Create custom terrain types with procedural generation

**`WORLD_TILES` Constants**
```lua
WORLD_TILES.METEORCOAST_NOISE
WORLD_TILES.MONKEY_GROUND  
WORLD_TILES.WOODFLOOR
WORLD_TILES.UNDERROCK
WORLD_TILES.PEBBLEBEACH
```
- **Purpose**: Pre-defined terrain tile types for world generation
- **Usage**: Specify ground types for setpieces and rooms

## Component Integration Functions

**`inst.entity:AddAnimState()` / `inst.entity:AddTransform()` / `inst.entity:AddNetwork()`**
```lua
inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()
```
- **Purpose**: Add core engine components to entities
- **Usage**: Required for entity rendering, positioning, and network synchronization
- **Note**: These are engine-level components, different from game components

## Advanced Utility Functions

**`require"noisetilefunctions"`**
```lua
require"noisetilefunctions"[WORLD_TILES[name]] = func
```
- **Purpose**: Register noise generation functions for custom tiles
- **Usage**: Define how procedural terrain tiles are generated

**`require"map/static_layout".Get(path, data)`**
```lua
require"map/static_layout".Get("map/static_layouts/" .. name, TreatSetpiece(data))
```
- **Purpose**: Load existing static layout files with modifications
- **Parameters**: 
  - `path` (string) - Path to layout file
  - `data` (table) - Override data
- **Returns**: Layout definition
- **Usage**: Import and customize existing game layouts

**`debug.getupvalue(fn, index)` / `debug.setupvalue(fn, index, value)`**
```lua
local name, value = debug.getupvalue(fn, i)
debug.setupvalue(scope_fn, _fn_i, new_fn)
```
- **Purpose**: Access and modify function upvalues (closure variables)
- **Usage**: Advanced technique to modify internal game behavior
- **Warning**: This is a low-level Lua debugging feature

## Node and Connection Types

**`NODE_TYPE.SeparatedRoom`**
```lua
self.type = NODE_TYPE.SeparatedRoom
```
- **Purpose**: Specifies that a task creates disconnected areas
- **Usage**: Creates islands or isolated areas accessible only by specific means

## Tag Categories for World Generation

**Room Tags for Generation Control:**
- `"ForceDisconnected"` - Prevents road connections
- `"RoadPoison"` - Blocks road generation through area
- `"lunacyarea"` - Lunar biome characteristics
- `"moonhunt"` - Moon-specific spawning rules
- `"MushGnomeSpawnArea"` - Allows mushroom gnome spawning
- `"Nightmare"` - Nightmare/ruins theme
- `"Atrium"` - Ancient/Atrium theme
- `"sandstorm"` - Desert biome characteristics

## Advanced Pattern: Metatable Manipulation

**`getmetatable(WorldSim).__index.SeparateIslands`**
```lua
getmetatable(WorldSim).__index.SeparateIslands = function() 
    print("Nullifying SeparateIslands")
end 
```
- **Purpose**: Override built-in world generation methods
- **Usage**: Completely replace engine behavior
- **Warning**: Very advanced technique that can break compatibility

## Lock and Key System

**`LOCKS.TIER1` / `KEYS.TIER1`**
```lua
self.locks = {LOCKS.TIER1}
self.keys_given = {KEYS.TIER1}
```
- **Purpose**: World generation progression system
- **Usage**: Control which areas are accessible based on keys obtained from other areas
- **Note**: Creates logical progression through the world

## Additional Functions Found in Small World Mods

### Language and Localization Functions

**`locale` global variable**
```lua
local L = locale ~= "zh" and locale ~= "zhr"
```
- **Purpose**: Global variable containing current game language code
- **Usage**: Conditional localization based on language
- **Values**: "zh" (Chinese Simplified), "zhr" (Chinese Traditional), "en" (English), etc.

**`STRINGS.UI.CUSTOMIZATIONSCREEN` tables**
```lua
name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.MINIWORLD
desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.MINIWORLD
```
- **Purpose**: Localized strings for custom world presets
- **Usage**: Display names and descriptions in world generation UI
- **Structure**: Nested table hierarchy for UI string organization

### World Generation Preset Functions

**`AddLevel(type, data)`**
```lua
AddLevel(LEVELTYPE.SURVIVAL, {
    id = "MINIWORLD",
    name = "Custom World Name",
    location = "forest",
    version = 4,
    overrides = { task_set = "custom_set" }
})
```
- **Purpose**: Register a complete world generation preset
- **Parameters**: 
  - `type` - Usually `LEVELTYPE.SURVIVAL`
  - `data` - Complete level configuration including tasks, overrides, setpieces
- **Usage**: Create selectable world presets in the game UI

**`required_setpieces` and `numrandom_set_pieces`**
```lua
required_setpieces = {"Sculptures_1", "Maxwell5"},
numrandom_set_pieces = 0,
random_set_pieces = {},
```
- **Purpose**: Control which setpieces always spawn vs. random selection
- **Usage**: Guarantee specific structures appear while controlling randomization

**`valid_start_tasks`**
```lua
valid_start_tasks = {"Make a pick"},
```
- **Purpose**: Defines which tasks can be player spawn locations
- **Usage**: Control where players can start in custom worlds

### Advanced Mod Detection and Compatibility

**`GLOBAL.KnownModIndex:IsModEnabled(workshop_id)`**
```lua
if GLOBAL.KnownModIndex:IsModEnabled("workshop-1392778117") then
    -- Prism mod compatibility code
end
```
- **Purpose**: Detect if specific Steam Workshop mods are active
- **Parameters**: `workshop_id` - Steam Workshop ID as string (with "workshop-" prefix)
- **Returns**: Boolean indicating if mod is enabled
- **Usage**: Conditional compatibility code based on other mods

### Component Manipulation Functions

**`overwrite(table, method_name, pre_function, post_function, nil_replacement)`**
```lua
overwrite(inst.components.trader, "onaccept", nil, function(inst, giver, item)
    -- Custom behavior after original function
end)
```
- **Purpose**: Custom function for wrapping/replacing object methods
- **Parameters**: 
  - `table` - Object containing the method
  - `method_name` - Name of method to wrap
  - `pre_function` - Function to run before original (or nil)
  - `post_function` - Function to run after original (or nil)
  - `nil_replacement` - Value to treat as nil in returns
- **Usage**: Modify existing game behavior without completely replacing functions

### Entity Prefab Initialization

**`AddPrefabPostInit(prefab_name, function)`**
```lua
AddPrefabPostInit("forest_network", function(inst)
    inst:AddComponent"nightmareclock"
end)
```
- **Purpose**: Add functionality to existing game entities after they're created
- **Parameters**: 
  - `prefab_name` - Name of the prefab to modify
  - `function` - Modification function receiving the instance
- **Usage**: Add components or modify behavior of existing game objects

**`AddPlayerPostInit(function)`**
```lua
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function(inst)
        -- Player-specific initialization
    end)
end)
```
- **Purpose**: Add functionality to all player entities
- **Usage**: Apply modifications to every player character

### Network and Multiplayer Functions

**`TheNet:GetIsMasterSimulation()`**
```lua
if not TheNet:GetIsMasterSimulation() then return end
```
- **Purpose**: Check if current code is running on the server/host
- **Returns**: Boolean - true if running on master sim, false on client
- **Usage**: Prevent client-side execution of server-only code

**`TheNet:IsDedicated()`**
```lua
if (not TheNet:IsDedicated()) and (#TheNet:GetClientTable() <= 1) then
```
- **Purpose**: Check if running on dedicated server
- **Returns**: Boolean - true if dedicated server, false if listen server/client
- **Usage**: Different behavior for dedicated vs. listen servers

**`TheNet:GetClientTable()`**
```lua
#TheNet:GetClientTable() <= 1
```
- **Purpose**: Get list of connected clients
- **Returns**: Table of client data
- **Usage**: Check number of connected players

### World State and Game Information

**`TheWorld.state.cycles`**
```lua
if TheWorld.state.cycles == 0
```
- **Purpose**: Access to world's day/cycle counter
- **Usage**: Execute code only on specific days (like day 1)

**`inst.userid`**
```lua
if inst.userid == "KU_Wj_Y4dDN"
```
- **Purpose**: Unique identifier for specific players
- **Usage**: Player-specific functionality (like developer/tester features)

### Map and Exploration Functions

**`inst.player_classified.MapExplorer:RevealArea(x, 0, z)`**
```lua
inst.player_classified.MapExplorer:RevealArea(x, 0, y)
```
- **Purpose**: Reveal map areas for a specific player
- **Parameters**: x, y, z coordinates
- **Usage**: Debug/cheat functionality to reveal map sections

**`TheWorld.Map:GetTopologyIDAtPoint(position)`**
```lua
inst.components.talker:Say(
    TheWorld.Map:GetTopologyIDAtPoint(
        inst.Transform:GetWorldPosition()))
```
- **Purpose**: Get the topology/room ID at a specific world position
- **Returns**: String identifier of the room/area type
- **Usage**: Debug information about world generation structure

### Task and Periodic Execution

**`inst:DoTaskInTime(delay, function)`**
```lua
inst:DoTaskInTime(0, function(inst)
    -- Execute after delay
end)
```
- **Purpose**: Schedule function execution after a delay
- **Parameters**: 
  - `delay` - Time in seconds (0 = next frame)
  - `function` - Function to execute
- **Usage**: Deferred initialization or delayed actions

**`inst:DoPeriodicTask(interval, function)`**
```lua
inst:DoPeriodicTask(2, function(inst)
    inst.components.talker:Say("Debug message")
end)
```
- **Purpose**: Execute function repeatedly at intervals
- **Parameters**: 
  - `interval` - Time between executions in seconds
  - `function` - Function to execute repeatedly
- **Usage**: Continuous monitoring or periodic updates

### World Tag System

**`TheWorld:AddTag(tag)` / `TheWorld:RemoveTag(tag)` / `TheWorld:HasTag(tag)`**
```lua
TheWorld:AddTag"cave"
TheWorld:RemoveTag"cave"
if TheWorld:HasTag"forest" then
```
- **Purpose**: World-level tagging system for global state management
- **Usage**: Control global world behaviors and characteristics
- **Note**: Tags affect various game systems and spawning rules

### Advanced Configuration Access

**`GetModConfigData(option_name)`**
```lua
env[data.name] = GetModConfigData(data.name)
```
- **Purpose**: Access mod configuration options set by user
- **Parameters**: `option_name` - Name of configuration option
- **Returns**: User-selected value for the option
- **Usage**: Make mod behavior configurable through mod settings

These functions represent advanced Don't Starve Together modding techniques and world generation systems. Many are undocumented in official sources and require experimentation or reverse engineering to understand fully.