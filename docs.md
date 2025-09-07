# Don't Starve Together - Essential Functions Reference for Mod Developers

This document provides a comprehensive reference of the most important functions in Don't Starve Together that mod developers need to understand to create effective mods.

## Table of Contents

1. [Core Entity System](#core-entity-system)
2. [Component System](#component-system) 
3. [Prefab Creation](#prefab-creation)
4. [Action System](#action-system)
5. [State Management](#state-management)
6. [Utility Functions](#utility-functions)
7. [Event System](#event-system)
8. [Persistence System](#persistence-system)
9. [Common Patterns](#common-patterns)

---

## Core Entity System

### Entity Management Functions (`entityscript.lua`)

#### Component Management

**`inst:AddComponent(name)`**
```lua
-- Add functionality to an entity
local health_comp = inst:AddComponent("health")
health_comp:SetMaxHealth(100)
```
- **Purpose**: Adds a component to an entity, giving it new functionality
- **Parameters**: `name` (string) - Component name
- **Returns**: The component instance
- **Usage**: Essential for giving entities capabilities like health, inventory, combat, etc.

**`inst:RemoveComponent(name)`**
```lua
-- Remove component from entity
inst:RemoveComponent("combat") -- Makes entity non-combative
```
- **Purpose**: Removes a component and its functionality from an entity
- **Parameters**: `name` (string) - Component name to remove
- **Usage**: Dynamically disable functionality

#### Tag System

**`inst:AddTag(tag)` / `inst:RemoveTag(tag)`**
```lua
inst:AddTag("structure")     -- Mark as a structure
inst:AddTag("flammable")     -- Can catch fire
inst:RemoveTag("player")     -- Remove player tag
```
- **Purpose**: Add or remove categorical tags from entities
- **Parameters**: `tag` (string) - Tag name
- **Usage**: Essential for entity identification, AI behavior, and system filtering

**`inst:HasTag(tag)`**
```lua
if inst:HasTag("player") then
    -- This is a player entity
end
```
- **Purpose**: Check if entity has a specific tag
- **Parameters**: `tag` (string) - Tag to check for
- **Returns**: `true` if tag exists, `false` otherwise
- **Usage**: Core for conditional logic and entity filtering

#### Event System

**`inst:ListenForEvent(event, fn, source)`**
```lua
inst:ListenForEvent("onhitother", function(inst, data)
    print("Hit something!", data.target)
end)

-- Listen to events from another entity
inst:ListenForEvent("death", OnPetDeath, pet)
```
- **Purpose**: Register event listeners for entity communication
- **Parameters**: 
  - `event` (string) - Event name to listen for
  - `fn` (function) - Callback function
  - `source` (entity, optional) - Entity to listen to (default: self)
- **Usage**: React to game events, essential for entity interactions

**`inst:PushEvent(event, data)`**
```lua
inst:PushEvent("attacked", {attacker = attacker, damage = 25})
```
- **Purpose**: Fire events to notify listeners
- **Parameters**: 
  - `event` (string) - Event name
  - `data` (table, optional) - Event data
- **Usage**: Trigger behaviors and communicate between systems

#### Task Scheduling

**`inst:DoTaskInTime(time, fn, ...)`**
```lua
-- Explode after 3 seconds
inst:DoTaskInTime(3, function()
    inst:Remove()
    -- Spawn explosion effect
end)
```
- **Purpose**: Schedule a function to run after a delay
- **Parameters**: 
  - `time` (number) - Delay in seconds
  - `fn` (function) - Function to execute
  - `...` - Additional arguments passed to function
- **Returns**: Task handle (can be cancelled)

**`inst:DoPeriodicTask(time, fn, initialdelay, ...)`**
```lua
-- Regenerate health every 5 seconds
inst:DoPeriodicTask(5, function()
    if inst.components.health then
        inst.components.health:DoDelta(1)
    end
end, 5) -- Start after 5 seconds
```
- **Purpose**: Schedule a function to run repeatedly
- **Parameters**: 
  - `time` (number) - Interval in seconds
  - `fn` (function) - Function to execute
  - `initialdelay` (number, optional) - Delay before first execution
  - `...` - Additional arguments
- **Returns**: Task handle

#### Position and Validation

**`inst:GetPosition()`**
```lua
local pos = inst:GetPosition()
print("Entity at:", pos.x, pos.y, pos.z)
```
- **Purpose**: Get entity's world position
- **Returns**: Point object with x, y, z coordinates
- **Usage**: Essential for distance calculations and positioning

**`inst:IsValid()`**
```lua
if inst:IsValid() then
    -- Safe to operate on entity
    inst:DoSomething()
end
```
- **Purpose**: Check if entity still exists in the world
- **Returns**: `true` if valid, `false` if removed
- **Usage**: Prevent operations on deleted entities

---

## Component System

Components are modular pieces of functionality that can be attached to entities. Here are the most commonly used components in modding:

### Health Component

**`health:SetMaxHealth(amount)`**
```lua
inst.components.health:SetMaxHealth(150)
```
- **Purpose**: Set maximum health value
- **Parameters**: `amount` (number) - Maximum health

**`health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)`**
```lua
-- Heal 25 health
inst.components.health:DoDelta(25)

-- Deal 50 damage
inst.components.health:DoDelta(-50, nil, "fire")
```
- **Purpose**: Change current health (damage or healing)
- **Parameters**: 
  - `amount` (number) - Health change (negative for damage)
  - `cause` (string, optional) - Damage/heal cause
- **Usage**: Core health manipulation function

**`health:GetPercent()`**
```lua
local health_percent = inst.components.health:GetPercent()
if health_percent < 0.5 then
    -- Below half health
end
```
- **Purpose**: Get health as percentage (0.0 to 1.0)
- **Returns**: Number between 0 and 1

### Inventory Component

**`inventory:GiveItem(item, slot)`**
```lua
local item = SpawnPrefab("log")
inst.components.inventory:GiveItem(item)
```
- **Purpose**: Add item to inventory
- **Parameters**: 
  - `item` (entity) - Item to add
  - `slot` (number, optional) - Specific slot
- **Returns**: `true` if successful

**`inventory:GetItemInSlot(slot)`**
```lua
local item = inst.components.inventory:GetItemInSlot(1)
if item and item.prefab == "axe" then
    -- Player has axe in slot 1
end
```
- **Purpose**: Get item from specific inventory slot
- **Parameters**: `slot` (number) - Slot number (1-based)
- **Returns**: Item entity or nil

### Combat Component

**`combat:SetTarget(target)`**
```lua
inst.components.combat:SetTarget(player)
```
- **Purpose**: Set combat target for AI
- **Parameters**: `target` (entity) - Entity to target
- **Usage**: Essential for hostile mob AI

**`combat:DoAttack(target_override)`**
```lua
inst.components.combat:DoAttack() -- Attack current target
```
- **Purpose**: Perform an attack
- **Usage**: Trigger attack behavior

---

## Prefab Creation

Prefabs are templates for creating entities. Understanding this system is crucial for adding new content.

### Basic Prefab Structure

```lua
local assets = {
    Asset("ANIM", "anim/myitem.zip"),
    Asset("ATLAS", "images/inventoryimages/myitem.xml"),
    Asset("IMAGE", "images/inventoryimages/myitem.tex"),
}

local function fn()
    local inst = CreateEntity()
    
    -- Engine components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    -- Rendering
    inst.AnimState:SetBank("myitem")
    inst.AnimState:SetBuild("myitem")
    inst.AnimState:PlayAnimation("idle")
    
    -- Tags
    inst:AddTag("item")
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    -- Server-side components
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "myitem"
    
    return inst
end

return Prefab("myitem", fn, assets)
```

### Key Prefab Functions

**`CreateEntity()`**
```lua
local inst = CreateEntity() -- Create base entity
```
- **Purpose**: Create the foundation entity object
- **Returns**: Raw entity ready for configuration
- **Usage**: Always the first step in prefab creation

**`Prefab(name, fn, assets, deps)`**
```lua
return Prefab("mymod_item", fn, assets, prefabdeps)
```
- **Purpose**: Register a prefab with the game
- **Parameters**: 
  - `name` (string) - Prefab name
  - `fn` (function) - Creation function
  - `assets` (table) - Required assets
  - `deps` (table, optional) - Dependencies
- **Usage**: Makes prefab available via SpawnPrefab()

---

## Action System

Actions define interactions between entities (e.g., player chopping tree, feeding animal).

### Action Creation

```lua
local MYACTION = Action({
    priority = 2,
    distance = 2,
})

MYACTION.id = "MYACTION"
MYACTION.str = "Feed"

MYACTION.fn = function(act)
    local target = act.target
    local doer = act.doer
    
    -- Perform the action
    if target.components.eater then
        target.components.eater:Eat(act.invobject)
        return true
    end
    
    return false
end

AddAction(MYACTION)
```

### Action Properties

- **`priority`**: Higher values preferred when multiple actions available
- **`distance`**: Maximum range for action
- **`fn`**: Function that executes the action
- **`strfn`**: Function that returns action description text

---

## State Management

Stategraphs control entity behavior through states and transitions.

### State Definition

```lua
State{
    name = "idle",
    tags = {"idle", "canrotate"},
    
    onenter = function(inst)
        inst.Physics:Stop()
        inst.AnimState:PlayAnimation("idle_loop", true)
    end,
    
    events = {
        EventHandler("attacked", function(inst, data)
            inst.sg:GoToState("hit", data)
        end),
    },
    
    timeline = {
        TimeEvent(10*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("sound/effect")
        end),
    },
}
```

### State Functions

**`inst.sg:GoToState(state, data)`**
```lua
inst.sg:GoToState("attack", {target = enemy})
```
- **Purpose**: Transition to a new state
- **Parameters**: 
  - `state` (string) - State name
  - `data` (table, optional) - Data passed to state

---

## Utility Functions

### Entity Spawning and Finding

**`SpawnPrefab(name, skin, skin_id)`**
```lua
local item = SpawnPrefab("log")
local tree = SpawnPrefab("evergreen")
tree.Transform:SetPosition(x, 0, z)
```
- **Purpose**: Create entity from prefab
- **Parameters**: `name` (string) - Prefab name
- **Returns**: Created entity
- **Usage**: Core function for creating any game entity

**`FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)`**
```lua
-- Find nearest tree within 20 units
local tree = FindEntity(inst, 20, nil, {"tree"}, {"burnt"})
```
- **Purpose**: Find first entity matching criteria
- **Parameters**: 
  - `inst` (entity) - Search center
  - `radius` (number) - Search radius
  - `fn` (function, optional) - Custom filter function
  - `musttags` (table, optional) - Required tags
  - `canttags` (table, optional) - Excluded tags
- **Returns**: First matching entity or nil

**`FindClosestPlayer(x, y, z, isalive)`**
```lua
local player, distance = FindClosestPlayer(inst:GetPosition():Get())
if player and distance < 10 then
    -- Player is nearby
end
```
- **Purpose**: Find nearest player to a position
- **Returns**: Player entity and distance, or nil

---

## Event System

### Common Events

- **"death"**: Entity died
- **"attacked"**: Entity was attacked
- **"onhitother"**: Entity hit something
- **"equip"**: Item was equipped
- **"unequip"**: Item was unequipped
- **"oneat"**: Character ate something
- **"locomote"**: Character moved

### Event Data Patterns

Events typically include relevant data:
```lua
-- Attack event data
{
    attacker = attacking_entity,
    damage = damage_amount,
    weapon = weapon_used,
}

-- Death event data  
{
    cause = "fire", -- or other cause
    afflicter = causing_entity,
}
```

---

## Persistence System

Don't Starve Together provides several mechanisms for persisting data that survives world shutdowns and restarts. Understanding these systems is crucial for creating mods that maintain state properly.

### Global Persistence Functions (`mainfunctions.lua`)

**`SavePersistentString(name, data, encode, callback)`**
```lua
-- Save mod data globally (survives all shutdowns)
local mydata = json.encode({score = 100, unlocked = true})
SavePersistentString("mymod_data", mydata, false, function()
    print("Data saved successfully!")
end)
```
- **Purpose**: Save data that persists across all game sessions and world shutdowns
- **Parameters**: 
  - `name` (string) - Unique filename for your data
  - `data` (string) - Data to save (use json.encode for complex data)
  - `encode` (boolean) - Whether to encode the data (usually false for mods)
  - `callback` (function, optional) - Called when save completes
- **Usage**: Global mod settings, progression data, cross-world statistics

**`TheSim:GetPersistentString(name, callback)`**
```lua
-- Load mod data from persistent storage
TheSim:GetPersistentString("mymod_data", function(load_success, data)
    if load_success and data ~= nil then
        local decoded = json.decode(data)
        print("Loaded score:", decoded.score)
    else
        print("No saved data found or load failed")
    end
end)
```
- **Purpose**: Load previously saved persistent data
- **Parameters**: 
  - `name` (string) - Filename to load from
  - `callback` (function) - Called with (success, data) when load completes
- **Usage**: Load global mod settings and progression data

**`ErasePersistentString(name, callback)`**
```lua
-- Remove persistent data file
ErasePersistentString("mymod_data", function()
    print("Data erased successfully!")
end)
```
- **Purpose**: Delete persistent data file
- **Usage**: Reset mod data or clean up old files

### Entity/Component Persistence

**Component Save/Load Pattern**
```lua
-- In your custom component
function MyComponent:OnSave()
    return {
        important_value = self.important_value,
        counter = self.counter,
        unlocked_features = self.unlocked_features,
    }
end

function MyComponent:OnLoad(data)
    if data then
        self.important_value = data.important_value or default_value
        self.counter = data.counter or 0
        self.unlocked_features = data.unlocked_features or {}
    end
end
```
- **Purpose**: Save/load component data as part of entity/world saves
- **Usage**: Entity-specific data that should persist with the world

**Entity Save/Load Pattern**
```lua
-- In prefab file
local function OnSave(inst, data)
    data.my_custom_value = inst.my_custom_value
end

local function OnLoad(inst, data)
    if data and data.my_custom_value then
        inst.my_custom_value = data.my_custom_value
    end
end

-- In prefab creation function
inst.OnSave = OnSave
inst.OnLoad = OnLoad
```
- **Purpose**: Save/load custom entity data
- **Usage**: Entity-specific values that aren't in components

### Mod-Specific Persistent Data Examples

**Player Progression Tracking**
```lua
-- Save player achievements or progression
local function SavePlayerProgress(player, achievement)
    local save_name = "mymod_progress_" .. player.userid
    TheSim:GetPersistentString(save_name, function(success, data)
        local progress = success and json.decode(data) or {}
        progress[achievement] = true
        progress.last_updated = os.time()
        
        SavePersistentString(save_name, json.encode(progress), false)
    end)
end
```

**Global Server Statistics**
```lua
-- Track server-wide statistics
local function UpdateServerStats(stat_name, value)
    TheSim:GetPersistentString("mymod_server_stats", function(success, data)
        local stats = success and json.decode(data) or {}
        stats[stat_name] = (stats[stat_name] or 0) + value
        
        SavePersistentString("mymod_server_stats", json.encode(stats), false)
    end)
end
```

**Configuration Persistence**
```lua
-- Save mod configuration settings
local function SaveModConfig(config)
    local config_data = {
        difficulty = config.difficulty,
        enabled_features = config.enabled_features,
        custom_values = config.custom_values,
        version = "1.2.0" -- for upgrade compatibility
    }
    
    SavePersistentString("mymod_config", json.encode(config_data), false)
end

local function LoadModConfig(callback)
    TheSim:GetPersistentString("mymod_config", function(success, data)
        local config = {}
        if success and data then
            local loaded = json.decode(data)
            -- Handle version upgrades here if needed
            config = loaded
        else
            -- Set defaults
            config = {
                difficulty = "normal",
                enabled_features = {},
                custom_values = {}
            }
        end
        callback(config)
    end)
end
```

### Important Persistence Guidelines

1. **File Naming**: Use unique prefixes for your mod to avoid conflicts
   ```lua
   -- Good: "myawesomemod_settings", "myawesomemod_playerdata"
   -- Bad: "settings", "data"
   ```

2. **Data Format**: Always use JSON for complex data structures
   ```lua
   -- Encode before saving
   local data = json.encode({key = "value", number = 123})
   SavePersistentString("file", data, false)
   
   -- Decode after loading
   local decoded = json.decode(data)
   ```

3. **Error Handling**: Always check if loading was successful
   ```lua
   TheSim:GetPersistentString("myfile", function(success, data)
       if success and data ~= nil then
           -- Data loaded successfully
           local parsed = json.decode(data)
       else
           -- Use defaults or handle error
           print("Failed to load data, using defaults")
       end
   end)
   ```

4. **Callback Pattern**: All persistence functions are asynchronous
   ```lua
   -- DON'T do this - data won't be loaded yet
   TheSim:GetPersistentString("file", load_callback)
   UseData() -- Data not available yet!
   
   -- DO this - use data in callback
   TheSim:GetPersistentString("file", function(success, data)
       if success then
           UseData(data) -- Data available here
       end
   end)
   ```

5. **Persistence Scope**:
   - `SavePersistentString/GetPersistentString`: Global, survives all shutdowns
   - Component `OnSave/OnLoad`: World-specific, saved with world file
   - Entity `OnSave/OnLoad`: Entity-specific, saved with world file

---

## Common Patterns

### 1. Component Initialization Pattern
```lua
if not TheWorld.ismastersim then
    return inst  -- Client-side only setup
end

-- Server-side component setup
inst:AddComponent("health")
inst.components.health:SetMaxHealth(100)
```

### 2. Safe Component Access
```lua
if inst.components.health then
    inst.components.health:DoDelta(-10)
end
```

### 3. Tag-Based Logic
```lua
local function CanEatTarget(inst, target)
    return target:HasTag("edible") and not target:HasTag("burnt")
end
```

### 4. Event-Driven Interactions
```lua
inst:ListenForEvent("onhitother", function(inst, data)
    if data.target:HasTag("tree") then
        -- Special behavior when hitting trees
    end
end)
```

### 5. Delayed Actions
```lua
inst:DoTaskInTime(2, function()
    -- Do something after 2 seconds
    inst:PushEvent("delayed_effect")
end)
```

---

## File Structure Reference

- **`components/`**: Modular functionality (health, inventory, etc.)
- **`prefabs/`**: Entity templates (items, creatures, structures)  
- **`stategraphs/`**: Behavior state machines
- **`actions.lua`**: Player/entity interaction definitions
- **`recipes.lua`**: Crafting recipes
- **`tuning.lua`**: Game balance constants
- **`strings.lua`**: Text and UI strings

This reference provides the foundation for understanding Don't Starve Together's architecture and creating effective mods. Each system builds upon these core functions to create the game's complex behaviors.