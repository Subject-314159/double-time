----------------------------------------------------------------------------------------------------
-- STACK
----------------------------------------------------------------------------------------------------
logif("===== STACK =====")
local ignore_items = {}
local max_stack_size = MAX_INT32 -- Double
if mods["space-exploration"] then
    ignore_items = {"rocket-fuel", "iron-ore", "iron-plate", "copper-ore", "copper-plate", "stone", "stone-brick",
                    "low-density-structure", "se-beryllium-ore", "se-beryllium-plate", "se-holmium-ore",
                    "se-holmium-plate", "se-iridium-ore", "se-iridium-plate"}
    max_stack_size = 200
end
local stack = {{
    prototypes = {"inserter", "loader", "loader-1x1", "utility-constants"},
    properties = {
        ["_base"] = {"max_belt_stack_size", "stack_size_bonus"}
    },
    data = {
        ignore = not settings.startup["dt-stack-hand"].value,
        max_value = MAX_UINT8
    }
}, {
    prototypes = {"construction-robot", "logistic-robot"},
    properties = {
        ["_base"] = {"max_payload_size"}
    },
    data = {
        ignore = not settings.startup["dt-stack-hand"].value,
        max_value = MAX_INT32
    }
}, {
    ignore_items = flatten({not_stackable_items, ignore_items}),
    properties = {
        ["_base"] = {"stack_size"}
    },
    data = {
        ignore = not settings.startup["dt-stack-item"].value,
        max_value = max_stack_size
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"inserter-stack-size-bonus", "bulk-inserter-capacity-bonus",
                                      "worker-robot-storage"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        ignore = not settings.startup["dt-stack-hand"].value,
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"belt-stack-size-bonus"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        ignore = not settings.startup["dt-stack-belt"].value,
        max_value = MAX_INT32 -- Double
    }
}}
multiply_loop(stack, settings.startup["dt-stack-multiplier"].value)

-- To include
-- Worker robot carry size 

-- Do not include:
-- Inserter hand size
