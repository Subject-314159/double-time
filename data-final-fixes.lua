----------------------------------------------------------------------------------------------------
-- DEFINITION
----------------------------------------------------------------------------------------------------
local MAX_INT16 = 32767
local MAX_UINT16 = 65535
local MAX_INT32 = 2147483647 -- Float
local MAX_UINT32 = 4294967295
local MAX_INT64 = 9223372036854775807 -- Double
local MAX_UINT64 = 18446744073709551615

local STRUCTURE = {{
    prototypes = {"prototype-1", "..."}, -- Optional, if empty then applying to all prototypes
    ignore_prototypes = {"prototype-2", "..."}, -- Optional, applied after determining prototypes scope
    properties = {
        ["_base"] = {"property-1", "..."}, -- Top level properties
        ["nested-lvl-1"] = { -- Recursive tables
            ["_base"] = {"property-2", "..."},
            ["nested-lvl-2"] = {"property-3", "..."}
        }
    },
    data = {
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
-- GENERIC FUNCTIONS
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
                local pass = false
                if filter_field then
                    for _, val in pairs(filter_values) do
                        if entry[filter_field] == val then
                            pass = true
                            break
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
local multiply_loop = function(structure, multiplier)
    for _, entry in pairs(structure or {}) do
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
                -- for _, property in pairs(data.properties) do
                --     local prop = find_property_recursive(prototype, property)
                --     multiply(prop, data)
                -- end
            end
        end
    end
end

-- if settings.startup["dt-double-speed"] then require("data/double-speed") end
-- if settings.startup["dt-double-production"] then require("data/double-production") end
-- if settings.startup["dt-double-productivity"] then require("data/double-productivity") end
-- if settings.startup["dt-double-range"] then require("data/double-range") end
-- if settings.startup["dt-double-storage"] then require("data/double-storage") end
-- if settings.startup["dt-double-damage"] then require("data/double-damage") end
-- if settings.startup["dt-double-health"] then require("data/double-health") end

----------------------------------------------------------------------------------------------------
-- SPEED (other than velocity
----------------------------------------------------------------------------------------------------
log("===== SPEED =====")
local speed = {{
    properties = {
        ["_base"] = { -- Capture bot
        "capture_speed", -- Crafting
        "crafting_speed", -- Mining/pumping
        "mining_speed", "pumping_speed", -- Quality bonus
        "crafting_machine_speed_multiplier", "inserter_speed_multiplier", "lab_research_speed_multiplier",

        -- Researching
        "researching_speed", -- Space platform
        "space_platform_dump_cooldown", "space_platform_manual_dump_cooldown"}
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    properties = {
        ["_base"] = { -- Repairing
        "repair_speed_modifier", "platform_repair_speed_modifier"}
    },
    data = {
        max_value = MAX_INT64 -- Float
    }
}, {
    -- Inserter specific
    prototypes = {"inserter"},
    properties = {
        ["_base"] = {"rotation_speed", "extension_speed"}
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    -- Repair tool specific 'speed'
    prototypes = {"repair-tool"},
    properties = {
        ["_base"] = {"speed"}
    },
    data = {
        max_value = MAX_INT64 -- Float
    }
}, {
    prototypes = {"recipe"},
    properties = {
        ["_base"] = {"energy_required"}
    },
    data = {
        divide = true,
        max_value = MAX_INT32
    }

}, {
    prototypes = {"module"},
    properties = {
        ["effect"] = {
            ["_base"] = {"speed"}
        }
    },
    data = {
        max_value = 327.67
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"laboratory-speed", "gun-speed", "character-crafting-speed",
                                      "character-mining-speed"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}}
multiply_loop(speed, settings.startup["dt-speed-multiplier"].value)

----------------------------------------------------------------------------------------------------
-- VELOCITY
----------------------------------------------------------------------------------------------------
log("===== VELOCITY =====")
local velocity = {{
    ignore_prototypes = {"sound"},
    properties = {
        ["_base"] = { -- Generic
        "max_speed", -- Ignore 'sound'
        -- Fuel item
        "fuel_acceleration_multiplier", "fuel_acceleration_multiplier_quality_bonus", "fuel_top_speed_multiplier",
        "fuel_top_speed_multiplier_quality_bonus", -- Turret
        "turret_rotation_speed", -- Car is actually float but who cares
        -- Projectile/fluid stream
        "acceleration", "particle_vertical_acceleration", -- Robots
        "robot_vertical_acceleration", -- Car
        "initial_movement_speed", "torso_rotation_speed", -- Train
        "train-pushed_by_player_max_acceleration", -- Spider leg
        "movement_acceleration", -- Space platform
        "space_platform_relative_speed_factor", -- Gate
        "opening_speed"}
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"capture-robot", "combat-robot", "construction-robot", "logistic-robot", "projectile", "turret"},
    properties = {
        ["_base"] = { -- Flying robot
        "speed_multiplier_when_out_of_energy", -- Projectile
        "turn_speed", -- Turret
        "rotation_speed", "rotation_speed_secondary", "cannon_parking_speed", "default_speed", -- Asteroid collector
        "arm_speed_base", "arm_speed_quality_scaling", "unpowered_arm_speed_scale"}
    },
    data = {
        max_value = MAX_INT64 -- Float
    }
}, {
    -- Flying robot specific 'speed'
    prototypes = {"capture-robot", "combat-robot", "construction-robot", "logistic-robot"},
    properties = {
        ["_base"] = {"speed"}
    },
    data = {
        max_value = MAX_INT64 -- Float
    }
}, {
    -- Car specific 'rotation_speed'
    prototypes = {"car"},
    properties = {
        ["_base"] = {"rotation_speed"}
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    -- Turret specific 'rotation_speed'
    prototypes = {"turret"},
    properties = {
        ["_base"] = {"rotation_speed"}
    },
    data = {
        max_value = MAX_INT64 -- Float
    }
}, {
    -- Hard code limit to x5 multiplier for character movement and rocket silo
    prototypes = {"tile", "character", "rocket-silo"},
    properties = {
        ["_base"] = { -- Tile
        "walking_speed_modifier", -- Character
        "running_speed", -- Rocket silo
        "rising_speed", "engine_starting_speed", "flying_speed", "flying_acceleration"}
    },
    data = {
        multiplier = math.min(settings.startup["dt-velocity-multiplier"].value, 5),
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"worker-robot-speed", "character-running-speed", "train-braking-force-bonus",
                                      "worker-robot-battery"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}}
multiply_loop(velocity, settings.startup["dt-velocity-multiplier"].value)

----------------------------------------------------------------------------------------------------
-- PRODUCTION (other than productivity)
----------------------------------------------------------------------------------------------------
log("===== PRODUCTION =====")
-- local production = {{
--     prototypes = {"recipe"},
--     properties = {
--         ["results"] = {
--             ["_array"] = {
--                 ["_base"] = {"amount", "amount_min", "amount_max"}
--             }
--         }
--     },
--     data = {
--         max_value = MAX_INT16
--     }
-- }, {
--     prototypes = {"recipe"},
--     properties = {
--         ["results"] = {
--             ["_array"] = {
--                 ["_base"] = {"probability"}
--             }
--         }
--     },
--     data = {
--         max_value = 1 -- Should be between 0 and 1
--     }
-- }, {
--     prototypes = {"recipe"},
--     properties = {
--         ["results"] = {
--             ["_array"] = {
--                 ["_base"] = {"percent_spoiled"}
--             }
--         }
--     },
--     data = {
--         divide = true,
--         max_value = 1 -- Should be between 0 and 1
--     }
-- }}
-- multiply_loop(production, settings.startup["dt-production-multiplier"].value)

local production = {{
    properties = {"amount", "amount_min", "amount_max"},
    data = {
        multiplier = settings.startup["dt-production-multiplier"].value,
        max_value = MAX_INT16
    }
}, {
    properties = {"probability"},
    data = {
        multiplier = settings.startup["dt-production-multiplier"].value,
        max_value = 1 -- Should be between 0 and 1
    }
}, {
    properties = {"percent_spoiled"},
    data = {
        multiplier = settings.startup["dt-production-multiplier"].value,
        divide = true,
        max_value = 1 -- Should be between 0 and 1
    }
}}
for _, recipe in pairs(data.raw["recipe"]) do
    log("Processing " .. recipe.name)
    for _, result in pairs(recipe.results or {}) do
        log(" --> Processing result " .. result.name)
        -- Check if the item is allowed (i.e. stackable)
        local allowed = true
        if result.type == "item" then
            local types = {"ammo", "capsule", "gun", "item-with-entity-data", "item-with-label", "item-with-inventory",
                           "blueprint-book", "item-with-tags", "selection-tool", "blueprint", "copy-paste-tool",
                           "deconstruction-item", "spidertron-remote", "upgrade-item", "module", "rail-planner",
                           "space-platform-starter-pack", "tool", "armor", "repair-tool"}
            for _, type in pairs(types) do
                if data.raw[type] then
                    local item = data.raw[type][result.name]
                    if item then
                        for _, flag in pairs(item.flags or {}) do
                            if flag == "not-stackable" then
                                allowed = false
                            end
                        end
                    end
                end
            end
        end

        -- Apply
        if allowed then
            for _, entry in pairs(production) do
                for _, v in pairs(entry.properties) do
                    log(" ==> Applying " .. v)
                    multiply(result, v, entry.data)
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- PRODUCTIVITY
----------------------------------------------------------------------------------------------------
log("===== PRODUCTIVITY =====")
local productivity = {{
    prototypes = {"recipe"},
    properties = {
        ["results"] = {
            ["_array"] = {
                ["_base"] = {"ignored_by_productivity"}
            }
        }
    },
    data = {
        divide = true,
        round_down = true,
        max_value = MAX_UINT16
    }
}, {
    prototypes = {"recipe"},
    properties = {
        ["_base"] = {"maximum_productivity"}
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"recipe"},
    properties = {
        ["results"] = {
            ["_array"] = {
                ["_base"] = {"extra_count_fraction"}
            }
        }
    },
    data = {
        max_value = MAX_INT64 -- Float
    }
}, {
    prototypes = {"module", "technology"},
    properties = {
        ["effect"] = {
            ["_base"] = {"productivity"}
        },
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"change-recipe-productivity"},
                ["_base"] = {"change"}
            }
        }
    },
    data = {
        max_value = 327.67
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"laboratory-productivity", "mining-drill-productivity-bonus",
                                      "beacon-distribution"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}}
multiply_loop(productivity, settings.startup["dt-productivity-multiplier"].value)

----------------------------------------------------------------------------------------------------
-- RANGE
----------------------------------------------------------------------------------------------------
-- Technology
-- character-build-distance
-- character-item-drop-distance
-- character-reach-distance
-- character-resource-reach-distance
-- character-item-pickup-distance
-- character-loot-pickup-distance
-- artillery-range
----------------------------------------------------------------------------------------------------
-- STORAGE
----------------------------------------------------------------------------------------------------
-- Technology
-- inserter-stack-size-bonus
-- bulk-inserter-capacity-bonus
-- character-logistic-trash-slots
-- worker-robot-storage
-- character-inventory-slots-bonus
-- cargo-landing-pad-count
-- belt-stack-size-bonus

----------------------------------------------------------------------------------------------------
-- DAMAGE
----------------------------------------------------------------------------------------------------
-- Technology
-- turret-attack
-- ammo-damage
----------------------------------------------------------------------------------------------------
-- HEALTH
----------------------------------------------------------------------------------------------------
-- Technology
-- character-health-bonus
