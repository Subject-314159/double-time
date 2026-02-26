----------------------------------------------------------------------------------------------------
-- DEFINITION
----------------------------------------------------------------------------------------------------
MAX_INT16 = 32767
MAX_UINT16 = 65535
MAX_INT32 = 2147483647 -- Float
MAX_UINT32 = 4294967295
MAX_INT64 = 9223372036854775807 -- Double
MAX_UINT64 = 18446744073709551615

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
                    ["_filter_values"] = {"value-2", "..."}, -- The values for which the multiplier should be applied to, takes priority over ignore_values
                    ["_ignore_values"] = {"value-2", "..."}, -- The values for which the multiplier should not be applied to
                    ["_base"] = {"property-3", "..."}
                }
            }
        }
    },
    data = {
        ignore = false, -- Optional, defaults to false
        multiplier = 2, -- Optional, defaults to 2
        divide = false, -- Optional, defaults to false
        round_down = false, -- Optional, defaults to false, applies only when 'divide' is true
        round_up = false, -- Optional, defaults to false, applies only when 'divide' is true
        max_value = MAX_INT16 -- Optional, defaults to INT16, applies only when 'divide' is false
    }
}}

-- Get all prototype types
local all_prototypes = {}
for type, _ in pairs(data.raw) do
    table.insert(all_prototypes, type)
end

----------------------------------------------------------------------------------------------------
-- MULTIPLIER FUNCTIONS
----------------------------------------------------------------------------------------------------

-- Generic multiplier function
local multiply = function(prototype, prop, data)
    -- Early exit if prop is not suitable
    if not prototype or not prop or not prototype[prop] or type(prototype[prop]) ~= "number" or prototype[prop] == 0 then
        return
    end

    -- Multiply or divide
    if data.divide then
        -- Calculate the new value
        local new_value = prototype[prop] / data.multiplier

        -- Round up/down
        if data.round_down then
            new_value = math.floor(new_value)
        elseif data.round_up then
            new_value = math.ceil(new_value)
        end

        -- Assign the new value
        log(" ~~~> Dividing " .. serpent.line(prototype[prop]) .. " by " .. serpent.line(data.multiplier) .. " to " ..
                new_value)
        prototype[prop] = new_value
    else
        -- Ensure max value
        local max = data.max_value or MAX_INT16
        local new_value = math.min(prototype[prop] * data.multiplier, max)

        -- Assign the new value, ensuring new value is not lower than calculated value
        log(
            " ~~~> Multiplying " .. serpent.line(prototype[prop]) .. " by " .. serpent.line(data.multiplier) .. " to " ..
                new_value)
        prototype[prop] = math.max(prototype[prop], new_value)
    end
end

-- Single entry loop
local multiply_loop_recursive
multiply_loop_recursive = function(prototype, properties, data)
    if not prototype then
        return
    end
    -- Iterate over the properties
    for k, v in pairs(properties or {}) do
        -- Check if entry is a _base or table
        if k == "_base" then
            -- Apply the multiplier
            for _, prop in pairs(v) do
                log(" ==> Applying multiplier on property '" .. prop .. "'")
                multiply(prototype, prop, data)
            end
        elseif k == "_array" then
            -- Loop through each member of the array
            for _, entry in pairs(prototype) do
                -- Check if the entry matches the filter
                local filter_field = k["_filter_field"]
                local filter_values = k["_filter_values"]
                local ignore_values = k["_ignore_values"]
                local pass
                if filter_field then
                    if filter_values then
                        pass = false
                        for _, val in pairs(filter_values) do
                            if entry[filter_field] == val then
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
                        log(" ==> Applying multiplier on property '" .. prop .. "'")
                        multiply(entry, prop, data)
                    end
                end
            end
        else
            -- Dig deeper
            log(" -> Processing child '" .. k .. "'")
            multiply_loop_recursive(prototype[k], v, data)
        end
    end
end

-- Main function
multiply_loop = function(structure, multiplier)
    for _, entry in pairs(structure or {}) do
        -- Skip if ignore
        if entry.data.ignore then goto continue end
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
            for _, proto in pairs(data.raw[prototype]) do
                -- Kick off recursive loop
                log("Processing " .. proto.name)
                multiply_loop_recursive(proto, entry.properties, entry.data)
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

dt-production-multiplier=Production multiplier [1 .. 10]
dt-production-probability= ↳ Multiply recipe probability
dt-productivity-multiplier=Productivity multiplier [1.0 .. 10.0]
dt-crafting-speed-multiplier=Crafting speed multiplier [1.0 .. 10.0]
dt-transportation-speed-multiplier=Transportation speed multiplier [1.0 .. 10.0]
dt-velocity-multiplier=Velocity multiplier [1.0 .. 10.0]
dt-storage-multiplier=Storage multiplier [1 .. 10]
dt-stack-multiplier=Stack multiplier [1 .. 10]
dt-stack-item= ↳ Multiply item stack size
dt-stack-hand= ↳ Multiply hand stack size
dt-stack-belt= ↳ Multiply belt stack bonus
dt-range-multiplier=Range multiplier [1.0 .. 10.0]
dt-damage-multiplier=Damage multiplier [1.0 .. 10.0]
dt-health-multiplier=Health multiplier [1.0 .. 10.0]
dt-health-resistance= ↳ Multiply resistance

