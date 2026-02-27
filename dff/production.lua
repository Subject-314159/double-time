----------------------------------------------------------------------------------------------------
-- PRODUCTION (other than productivity)
----------------------------------------------------------------------------------------------------
logif("===== PRODUCTION =====")
local production = {{
    prototypes = {"recipe"},
    properties = {
        ["results"] = {
            ["_array"] = {
                ["_filter_field"] = "name",
                ["_ignore_values"] = not_stackable_items,
                ["_base"] = {"amount", "amount_min", "amount_max"}
            }
        }
    },
    data = {
        max_value = MAX_INT16
    }
}, {
    prototypes = {"recipe"},
    properties = {
        ["results"] = {
            ["_array"] = {
                ["_filter_field"] = "name",
                ["_ignore_values"] = not_stackable_items,
                ["_base"] = {"probability"}
            }
        }
    },
    data = {
        ignore = not settings.startup["dt-production-probability"].value,
        max_value = 1 -- Should be between 0 and 1
    }
}, {
    prototypes = {"recipe"},
    properties = {
        ["results"] = {
            ["_array"] = {
                ["_filter_field"] = "name",
                ["_ignore_values"] = not_stackable_items,
                ["_base"] = {"percent_spoiled"}
            }
        }
    },
    data = {
        divide = true,
        max_value = 1 -- Should be between 0 and 1
    }
}, {
    prototypes = {"generator"},
    properties = {
        ["_base"] = {"max_power_output"},
        ["energy_source"] = {
            ["_base"] = {"buffer_capacity", "input_flow_limit", "output_flow_limit"}
        }
    },
    data = {
        is_energy = true,
        max_value = MAX_UINT64
    }
}, {
    properties = {
        ["_base"] = {"effectivity"},
        ["energy_source"] = {
            ["_base"] = {"effectivity"}
        }
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    prototypes = {"solar-panel"},
    properties = {
        ["_base"] = {"production"}
    },
    data = {
        is_energy = true,
        max_value = MAX_DOUBLE
    }
}, {
    properties = {
        ["_base"] = {"energy_usage"}
    },
    data = {
        is_energy = true,
        divide = true,
        round_up = true,
        max_value = MAX_DOUBLE
    }
}, {
    properties = {
        ["_base"] = {"fuel_value"}
    },
    data = {
        is_energy = true,
        max_value = MAX_DOUBLE
    }
}}
multiply_loop(production, settings.startup["dt-production-multiplier"].value)

-- local production = {{
--     properties = {"amount", "amount_min", "amount_max"},
--     data = {
--         multiplier = settings.startup["dt-production-multiplier"].value,
--         max_value = MAX_INT16
--     }
-- }, {
--     properties = {"probability"},
--     data = {
--         multiplier = settings.startup["dt-production-multiplier"].value,
--         max_value = 1 -- Should be between 0 and 1
--     }
-- }, {
--     properties = {"percent_spoiled"},
--     data = {
--         multiplier = settings.startup["dt-production-multiplier"].value,
--         divide = true,
--         max_value = 1 -- Should be between 0 and 1
--     }
-- }}
-- for _, recipe in pairs(data.raw["recipe"]) do
--     logif("Processing " .. recipe.name)
--     for _, result in pairs(recipe.results or {}) do
--         logif(" --> Processing result " .. result.name)
--         -- Check if the item is allowed (i.e. stackable)
--         local allowed = true
--         if result.type == "item" then
--             local types = {"ammo", "capsule", "gun", "item-with-entity-data", "item-with-label", "item-with-inventory",
--                            "blueprint-book", "item-with-tags", "selection-tool", "blueprint", "copy-paste-tool",
--                            "deconstruction-item", "spidertron-remote", "upgrade-item", "module", "rail-planner",
--                            "space-platform-starter-pack", "tool", "armor", "repair-tool"}
--             for _, type in pairs(types) do
--                 if data.raw[type] then
--                     local item = data.raw[type][result.name]
--                     if item then
--                         for _, flag in pairs(item.flags or {}) do
--                             if flag == "not-stackable" then
--                                 allowed = false
--                             end
--                         end
--                     end
--                 end
--             end
--         end

--         -- Apply
--         if allowed then
--             for _, entry in pairs(production) do
--                 for _, v in pairs(entry.properties) do
--                     logif(" ==> Applying " .. v)
--                     multiply(result, v, entry.data)
--                 end
--             end
--         end
--     end
-- end
