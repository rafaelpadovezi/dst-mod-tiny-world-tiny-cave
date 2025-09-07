# Tiny, Tiny World II - Mod Documentation

## Overview

**Mod Name:** Tiny, Tiny World II  
**Author:** Willow  
**Version:** 1.1  
**Compatible Version:** 0.7  

This mod creates an extremely small world for a single shard in Don't Starve Together. The world is designed to be resource-scarce, particularly with rocks being the limiting factor since earthquakes and meteors are absent. Players must farm moleworms, seek sea stacks, sharks, and Antlion, and search the Junk Pile for rocks.

## File Structure

```
/mod/
├── mod.manifest          # Binary manifest file
├── modinfo.lua          # Mod information and configuration
├── modmain.lua          # Main mod initialization (client/server)
├── modworldgenmain.lua  # World generation configuration
└── scripts/
    └── tools/
        └── upvaluehacker.lua  # Utility for function manipulation
```

## Core Functions and Systems

### 1. World Generation Functions (`modworldgenmain.lua`)

#### Universal Functions

**`env.overwrite(tabula, name, ante, post, replace_this_with_nil)`**
```lua
overwrite(inst.components.trader, "onaccept", nil, function(inst, giver, item)
    -- Custom behavior after original function
end)
```
- **Purpose**: Wraps existing functions with custom pre/post behavior
- **Parameters**: 
  - `tabula` (table) - Object containing the function
  - `name` (string) - Function name to wrap
  - `ante` (function, optional) - Function to run before original
  - `post` (function, optional) - Function to run after original
  - `replace_this_with_nil` - Value to replace with nil in results
- **Usage**: Used extensively to modify game behavior without completely replacing functions

**`env.MakeName(identifier, initiation_function)`**
```lua
local unique_name = MakeName("my_identifier")
```
- **Purpose**: Generate unique names for mod elements
- **Parameters**: 
  - `identifier` (string) - Base identifier
  - `initiation_function` (function, optional) - Called when name is first created
- **Returns**: Unique name string combining mod name and index
- **Usage**: Ensures no naming conflicts with other mods

#### Room and Task Creation

**`env.Room(name, data)`**
```lua
Room("MyCustomRoom", {
    colour = {r = 1, g = 0, b = 0, a = 1},
    tags = {"special", "custom"}
})
```
- **Purpose**: Create custom world generation rooms
- **Parameters**: 
  - `name` (string) - Room name
  - `data` (table) - Room configuration
- **Returns**: 1 (success indicator)
- **Usage**: Define areas with specific characteristics and spawns

**`env.FixRoom(name, func)`**
```lua
FixRoom("Graveyard", function(self)
    self.contents.countprefabs.molehill = 3
    self.contents.countstaticlayouts.Charlie1 = 1
end)
```
- **Purpose**: Modify existing room configurations
- **Parameters**: 
  - `name` (string) - Room name to modify
  - `func` (function) - Modification function receiving room data
- **Usage**: Customize vanilla rooms for the tiny world

**`env.Task(name, data)`**
```lua
Task("MyTask", {
    room_choices = {
        MyRoom = 1,
        AnotherRoom = 1
    }
})
```
- **Purpose**: Create world generation tasks
- **Parameters**: 
  - `name` (string) - Task name
  - `data` (table) - Task configuration
- **Returns**: Task name
- **Usage**: Define how rooms connect and generate

**`env.IslandTask(name, data)` / `env.IslandRoomTask(name, data)`**
```lua
IslandRoomTask{
    tags = {"lunacyarea", "moonhunt"},
    value = WORLD_TILES.METEORCOAST_NOISE,
    required_prefabs = {"moon_fissure"}
}
```
- **Purpose**: Create isolated island areas
- **Usage**: Generate disconnected areas accessible only by boat/walking

#### Setpiece Manipulation

**`env.RetreatSetpiece(name, data)`**
```lua
RetreatSetpiece("Charlie1")
RetreatSetpiece("Charlie2", {layout_position = LAYOUT_POSITION.RANDOM})
```
- **Purpose**: Modify existing setpiece placement rules
- **Parameters**: 
  - `name` (string) - Setpiece name
  - `data` (table, optional) - Override data
- **Usage**: Ensure setpieces can spawn in the constrained tiny world

**`env.MakeSetpiece(name, data)`**
```lua
MakeSetpiece("www_crabking", {
    layout = {
        crabking_spawner = {{x = 0, y = 0}}
    }
})
```
- **Purpose**: Create custom setpieces
- **Returns**: Setpiece reference table
- **Usage**: Define specific entity arrangements

**`env.GetSetpiece(name, data)`**
```lua
GetSetpiece("existing_layout", {
    layout_position = LAYOUT_POSITION.CENTER
})
```
- **Purpose**: Import and modify existing static layouts
- **Usage**: Reuse game's built-in layouts with modifications

#### Level Configuration

**`env.Level(data)`**
```lua
Level({
    id = "TINY_WORLD",
    name = "Tiny World",
    location = "forest",
    overrides = {
        world_size = "small",
        task_set = "TINY_WORLD"
    }
})
```
- **Purpose**: Define complete world configurations
- **Parameters**: `data` (table) - Level configuration
- **Usage**: Create selectable world presets

#### Utility Functions

**`env.Noise(func)`**
```lua
local custom_tile = Noise(function(x, y, z)
    return math.sin(x * 0.1) * math.cos(y * 0.1)
end)
```
- **Purpose**: Create custom noise-based terrain tiles
- **Parameters**: `func` (function) - Noise generation function
- **Returns**: World tile ID
- **Usage**: Generate procedural terrain patterns

**`env.IncludeTask(name, func)`**
```lua
IncludeTask("Dig that rock", function(self)
    self.make_loop = true
    self.room_choices = {Rocky = 1}
end)
```
- **Purpose**: Add tasks to the world generation and configure them
- **Usage**: Include custom or modified tasks in world generation

### 2. Main Mod Functions (`modmain.lua`)

#### Prefab Post-Initialization

**`AddPrefabPostInit(prefab_name, function)`**
```lua
AddPrefabPostInit("antlion", function(inst)
    overwrite(inst.components.trader, "onaccept", nil, function(inst, giver, item)
        -- Custom trading behavior
    end)
end)
```
- **Purpose**: Modify existing game entities after they're created
- **Usage**: Add components, change behaviors, or modify existing functionality

**`AddPlayerPostInit(function)`**
```lua
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function(inst)
        -- Custom player initialization
    end)
end)
```
- **Purpose**: Modify player entities when they spawn
- **Usage**: Add custom player behaviors, reveal map areas, or set up debugging

#### Component System Integration

The mod adds several components to the forest world:
- `nightmareclock` - Nightmare cycle management
- `grottowaterfallsoundcontroller` - Audio management
- `toadstoolspawner` - Toadstool boss spawning
- `grottowarmanager` - Grotto worm management
- `shadowparasitemanager` - Shadow creature spawning
- `daywalkerspawner` - Daywalker enemy spawning
- `archivemanager` - Archive content management
- `miasmamanager` - Miasma effect management
- `shadowthrallmanager` - Shadow thrall spawning
- `ruinsshadelingspawner` - Ruins enemy spawning
- `shadowthrall_mimics` - Mimic enemy management

### 3. Upvalue Hacker Utility (`scripts/tools/upvaluehacker.lua`)

**`UpvalueHacker.GetUpvalue(fn, ...)`**
```lua
local WORLDSETTINGS_GROUP = hacker.GetUpvalue(
    require"map/customize".GetWorldSettingsOptions, 
    "WORLDSETTINGS_GROUP"
)
```
- **Purpose**: Access internal variables within functions
- **Parameters**: 
  - `fn` (function) - Function to inspect
  - `...` - Chain of upvalue names to traverse
- **Returns**: Value, index, and scope function
- **Usage**: Access and modify internal game data structures

**`UpvalueHacker.SetUpvalue(start_fn, new_fn, ...)`**
```lua
UpvalueHacker.SetUpvalue(some_function, new_function, "upvalue_name")
```
- **Purpose**: Replace internal function variables
- **Usage**: Inject custom functionality into existing game systems

## Key Mod Mechanics

### Resource Scarcity System

The mod creates resource scarcity by:

1. **Rock Generation**: Limited rock spawns force players to seek alternative sources
2. **Antlion Trading**: Modified to give rocks instead of other rewards
3. **Ocean Resources**: Specific spawners for sea stacks and ocean resources
4. **Underground Access**: Fossil stalker behavior enables cave/Atrium transitions

### World Layout

The tiny world consists of several interconnected tasks:

1. **"Dig that rock"** - Starting area with basic resources and cave access
2. **"Forest hunters"** - Pig King, Moonbase, and Walrus areas  
3. **"For a nice walk"** - Bee Queen, Beefalo, and Spider areas
4. **"Lightning Bluff"** - Antlion, Dragonfly, and desert content

### Island Content

Three special island rooms provide end-game content:

1. **Lunar Island** - Moon-themed content with lunar rifts and special resources
2. **Marsh Island** - Toadstool boss area with marsh biome
3. **Atrium Island** - Ancient Fuelweaver content with ruins theme

### Ocean Integration

Custom ocean setpieces include:
- Crab King spawner
- Monkey Queen area
- Rocky island with Ancient Tree
- Hermit Crab island
- Merm Watchtower

## Configuration and Customization

### World Settings Integration

The mod integrates several cave/ruins settings into the forest world:
- Rift frequency and enablement
- Boss spawning (Toadstool, Daywalker)
- Resource regrowth settings
- Monster spawning options
- Animal population settings

### Debug Features

For the mod author (specific User ID), the mod includes:
- Full map reveal on day 0
- Topology ID display for world generation debugging

## Technical Implementation Notes

### Client-Server Architecture

```lua
if not TheNet:GetIsMasterSimulation() then return end 
```
Most gameplay modifications are server-side only to ensure proper multiplayer synchronization.

### Network Components

```lua
inst.entity:AddNetwork()
-- Client-side setup
if not TheWorld.ismastersim then
    return inst
end
-- Server-side setup
```
Proper network entity handling ensures client-server consistency.

### Safety Checks

The mod includes extensive validation:
- Component existence checks before modification
- Tag verification before adding/removing
- Network simulation checks for server-only code

This documentation covers the major systems and functions used in the Tiny, Tiny World II mod. The mod demonstrates advanced Don't Starve Together modding techniques including world generation customization, component system integration, and runtime function modification.