----------------------------------------------------------------------------------------------------
-- VELOCITY
----------------------------------------------------------------------------------------------------
logif("===== VELOCITY =====")
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
