----------------------------------------------------------------------------------------------------
-- SPEED (other than velocity
----------------------------------------------------------------------------------------------------
logif("===== SPEED =====")
local speed = {{
    properties = {
        ["_base"] = {"capture_speed", "crafting_speed", "mining_speed", "pumping_speed",
                     "crafting_machine_speed_multiplier", "inserter_speed_multiplier", "lab_research_speed_multiplier",
                     "researching_speed", "space_platform_dump_cooldown", "space_platform_manual_dump_cooldown",
                     "fuel_acceleration_multiplier", "fuel_top_speed_multiplier"}
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
    -- Belt specific 'speed'
    prototypes = {"lane-splitter", "linked-belt", "loader-1x1", "loader", "splitter", "transport-belt",
                  "underground-belt"},
    properties = {
        ["_base"] = {"speed"}
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
    -- Agri tower
    prototypes = {"agricultural-tower"},
    properties = {
        ["crane"] = {
            ["speed"] = {
                ["arm"] = {
                    ["_base"] = {"turn_rate", "extension_speed"}
                },
                ["grappler"] = {
                    ["_base"] = {"vertical_turn_rate", "horizontal_turn_rate", "extension_speed"}
                }
            }
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    -- Modules & module receivers
    prototypes = {"module", "assembling-machine", "rocket-silo", "furnace", "lab", "mining-drill"},
    properties = {
        ["effect"] = {
            ["_base"] = {"speed"}
        },
        ["effect_receiver"] = {
            ["base_effect"] = {
                ["_base"] = {"speed"}
            }
        }
    },
    data = {
        max_value = 327.669
    }
}, {
    prototypes = {"recipe"},
    properties = {
        ["_base"] = {"energy_required"}
    },
    data = {
        divide = true,
        min_value = 0.002,
        max_value = MAX_INT32
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

-- Crafting machines
-- Miners
-- Pumps
-- Agri towers
-- Labs
-- Construction/logistic robots
-- Vehicles
-- Turrets, artillery, guns
-- Recipes
-- Equipment items
-- Character

-- Belts
-- Inserters
-- Asteroid collectors
