----------------------------------------------------------------------------------------------------
-- DEFINITION
----------------------------------------------------------------------------------------------------
MAX_INT8 = 127
MAX_UINT8 = 255
MAX_INT16 = 32767
MAX_UINT16 = 65535
MAX_INT32 = 2147483647 -- Float
MAX_UINT32 = 4294967295
MAX_DOUBLE = MAX_INT32
MAX_INT64 = 9223372036854775807 -- Double
MAX_UINT64 = 18446744073709551615
MAX_FLOAT = MAX_INT64
dolog = false -- Generic flag for logging

-- Data model (example)
local STRUCTURE = {{
    prototypes = {"prototype-1", "..."}, -- Optional, if empty then applying to all prototypes
    ignore_prototypes = {"prototype-2", "..."}, -- Optional, applied after determining prototypes scope
    properties = {
        ["_base"] = {"property-1", "..."}, -- Top level properties
        ["nested-lvl-1"] = { -- Nested tables
            ["_base"] = {"property-2", "..."},
            ["nested-lvl-2"] = {
                ["_array"] = {
                    ["_filter_field"] = "field", -- The field to filter on
                    ["_filter_values"] = {"value-1", "..."}, -- The values for which the multiplier should be applied to, takes priority over ignore_values
                    ["_ignore_values"] = {"value-2", "..."}, -- The values for which the multiplier should not be applied to
                    ["_base"] = {"property-3", "..."}
                }
            }
        }
    },
    data = {
        is_energy = false, -- Optional, defaults to false
        ignore = false, -- Optional, defaults to false
        multiplier = 2, -- Optional, defaults to 2
        divide = false, -- Optional, defaults to false
        round_down = false, -- Optional, defaults to false, applies only when 'divide' is true
        round_up = false, -- Optional, defaults to false, applies only when 'divide' is true
        min_value = 0, -- Optional, ignored if not passed
        max_value = MAX_INT16 -- Optional, defaults to INT16, applies only when 'divide' is false
    }
}}

-- Get all prototype types
all_prototypes = {}
for type, _ in pairs(data.raw) do
    table.insert(all_prototypes, type)
end
all_item_types = {"item", "ammo", "capsule", "gun", "item-with-entity-data", "item-with-label", "item-with-inventory",
                  "blueprint-book", "item-with-tags", "selection-tool", "blueprint", "copy-paste-tool",
                  "deconstruction-item", "spidertron-remote", "upgrade-item", "module", "rail-planner",
                  "space-platform-starter-pack", "tool", "armor", "repair-tool"}
never_stack_item_types = {"blueprint-book", "item-with-inventory", "selection-tool", "blueprint", "copy-paste-tool",
                          "deconstruction-item", "spidertron-remote", "upgrade-item", "armor"}
not_stackable_items = {}
-- for _, type in pairs(all_item_types) do
for type, _ in pairs(data.raw) do
    for name, item in pairs(data.raw[type] or {}) do
        for _, flag in pairs(item.flags or {}) do
            if flag == "not-stackable" or flag == "only-in-cursor" then
                table.insert(not_stackable_items, name)
            end
        end
    end
end
for _, type in pairs(never_stack_item_types) do
    for name, item in pairs(data.raw[type] or {}) do
        table.insert(not_stackable_items, name)
    end
end
----------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------------------------------------
logif = function(prop)
    if dolog then
        logif(prop)
    end
end

function flatten(arr)
    local res = {}
    for k, v in pairs(arr) do
        if type(v) == "table" then
            local flat = flatten(v)
            for _, f in pairs(flat) do
                table.insert(res, f)
            end
        else
            table.insert(res, v)
        end
    end
    return res
end

----------------------------------------------------------------------------------------------------
-- MULTIPLIER FUNCTIONS
----------------------------------------------------------------------------------------------------
-- Generic multiplier function
local multiply = function(prototype, prop, data, trace)
    -- Early exit if prop is not suitable
    -- type(prototype[prop]) ~= "number" or
    if not prototype or not prop or not prototype[prop] or prototype[prop] == 0 then
        return
    end

    local value = prototype[prop]
    local suffix
    local new_value
    if data.is_energy then
        -- Extract the value and the suffix
        value, suffix = string.match(value, "^(%d+%.?%d*)(%D+)$")
        value = tonumber(value)
    end

    -- Multiply or divide
    if data.divide then
        -- Calculate the new value
        new_value = value / data.multiplier

        -- Round up/down
        if data.round_down then
            new_value = math.floor(new_value)
        elseif data.round_up then
            new_value = math.ceil(new_value)
        end

        if data.min_value then
            new_value = math.max(new_value, data.min_value)
        end

        local trace2 = trace .. "\n ~~~> Dividing " .. serpent.line(value) .. " by " .. serpent.line(data.multiplier) ..
                           " to " .. new_value
        logif(trace2)
    else
        -- Ensure max value and new value is not lower than calculated value
        local max = data.max_value or MAX_INT16
        new_value = math.min(value * data.multiplier, max)
        new_value = math.max(value, new_value)

        local trace2 =
            trace .. "\n ~~~> Multiplying " .. serpent.line(value) .. " by " .. serpent.line(data.multiplier) .. " to " ..
                new_value
        logif(trace2)
    end

    -- Assign the new value
    if data.is_energy then
        prototype[prop] = new_value .. suffix
    else
        prototype[prop] = new_value
    end
end

-- Single entry loop
local multiply_loop_recursive
multiply_loop_recursive = function(prototype, properties, data, trace)
    if not prototype then
        return
    end
    -- Iterate over the properties
    for k, v in pairs(properties or {}) do
        -- Check if entry is a _base or table
        if k == "_base" then
            -- Apply the multiplier
            for _, prop in pairs(v) do
                local trace2 = trace .. "\n ==> Applying multiplier on property '" .. prop .. "'"
                multiply(prototype, prop, data, trace2)
            end
        elseif k == "_array" then
            -- Loop through each member of the array
            for _, entry in pairs(prototype) do
                -- Check if the entry matches the filter
                local filter_field = v["_filter_field"]
                local filter_values = v["_filter_values"]
                local ignore_values = v["_ignore_values"]
                local pass
                local trace2 = trace
                if filter_field then
                    trace2 = trace2 .. "\nFiltering on field: " .. serpent.line(filter_field) .. "=" ..
                                 serpent.line(entry[filter_field])
                    if filter_values ~= nil then
                        pass = false
                        for _, val in pairs(filter_values) do
                            if entry[filter_field] == val then
                                trace2 = trace2 .. "\nFound filtered value: " .. val
                                pass = true
                                break
                            end
                        end
                    else
                        pass = true
                        for _, val in pairs(ignore_values) do
                            if entry[filter_field] == val then
                                pass = false
                                break
                            end
                        end
                    end
                else
                    pass = true
                end

                -- Apply the multiplier
                if pass then
                    for _, prop in pairs(v["_base"]) do
                        trace2 = trace2 .. "\n ==> Applying multiplier on property '" .. prop .. "'"
                        multiply(entry, prop, data, trace2)
                    end
                end
            end
        else
            -- Dig deeper
            local trace2 = trace .. "\n -> Processing child '" .. k .. "'"
            multiply_loop_recursive(prototype[k], v, data, trace2)
        end
    end
end

-- Main function
multiply_loop = function(structure, multiplier)
    for _, entry in pairs(structure or {}) do
        -- Skip if ignore
        if entry.data.ignore then
            goto continue
        end
        -- Ensure prototypes
        local prototypes = entry.prototypes or all_prototypes

        for _, ignore in pairs(entry.ignore_prototypes or {}) do
            for i = #prototypes, 1, -1 do
                if prototypes[i] == ignore then
                    table.remove(prototypes, i)
                    break
                end
            end
        end

        -- Ensure multiplier
        entry.data.multiplier = entry.data.multiplier or multiplier or 2

        -- Go over all affected prototypes
        for _, prototype in pairs(prototypes) do
            for name, proto in pairs(data.raw[prototype] or {}) do
                -- Check if we are allowed to handle this item
                local pass = true
                for _, itm in pairs(entry.ignore_items or {}) do
                    if itm == name then
                        pass = false
                        break
                    end
                end

                -- Kick off recursive loop
                if pass then
                    local trace = "\nProcessing " .. proto.name
                    multiply_loop_recursive(proto, entry.properties, entry.data, trace)
                end
            end
        end

        ::continue::
    end
end

----------------------------------------------------------------------------------------------------
-- MULTIPLY
----------------------------------------------------------------------------------------------------
require("dff/production")
require("dff/productivity")
require("dff/speed")
require("dff/velocity")
require("dff/storage")
require("dff/stack")
require("dff/range")
require("dff/damage")
require("dff/health")

-- dt-production-multiplier=Production multiplier [1 .. 10]
-- dt-production-probability= ↳ Multiply recipe probability
-- dt-productivity-multiplier=Productivity multiplier [1.0 .. 10.0]
-- dt-crafting-speed-multiplier=Crafting speed multiplier [1.0 .. 10.0]
-- dt-transportation-speed-multiplier=Transportation speed multiplier [1.0 .. 10.0]
-- dt-velocity-multiplier=Velocity multiplier [1.0 .. 10.0]
-- dt-storage-multiplier=Storage multiplier [1 .. 10]
-- dt-stack-multiplier=Stack multiplier [1 .. 10]
-- dt-stack-item= ↳ Multiply item stack size
-- dt-stack-hand= ↳ Multiply hand stack size
-- dt-stack-belt= ↳ Multiply belt stack bonus
-- dt-range-multiplier=Range multiplier [1.0 .. 10.0]
-- dt-damage-multiplier=Damage multiplier [1.0 .. 10.0]
-- dt-health-multiplier=Health multiplier [1.0 .. 10.0]
-- dt-health-resistance= ↳ Multiply resistance

