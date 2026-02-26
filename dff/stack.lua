
----------------------------------------------------------------------------------------------------
-- STACK
----------------------------------------------------------------------------------------------------
log("===== STACK =====")
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
    prototypes = {"inserter"},
    properties = {
        ["_base"] = {"hand_size"}
    },
    data = {
        ignore = not settings.startup["dt-stack-hand"].value,
        max_value = MAX_INT32 -- Double
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
    prototypes = all_item_types,
    ignore_prototypes = not_stackable_items,
    properties = {
        ["_base"] = {"stack_size"}
    },
    data = {
        ignore = ignore = not settings.startup["dt-stack-item"].value,
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"inserter-stack-size-bonus", "bulk-inserter-capacity-bonus", "worker-robot-storage"},
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


-- dt-stack-item= ↳ Multiply item stack size
-- dt-stack-hand= ↳ Multiply hand stack size
-- dt-stack-belt= ↳ Multiply belt stack bonus

-- Technology

-- To include
-- Inserter hand size
-- Worker robot carry size 