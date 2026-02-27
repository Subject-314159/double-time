----------------------------------------------------------------------------------------------------
-- RANGE
----------------------------------------------------------------------------------------------------
logif("===== RANGE =====")
local range = {{
    properties = {
        ["_base"] = {"manual_range_modifier", "radar_range", "resource_searching_radius"}
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    properties = {
        ["_base"] = {"radar_range"}
    },
    data = {
        max_value = MAX_UINT32
    }
}, {
    properties = { -- Rail support
        ["_base"] = {"support_range"}
    },
    data = {
        max_value = 500
    }
}, {
    properties = { -- Beacon/E-pole
        ["_base"] = {"supply_area_distance", "maximum_wire_distance"}
    },
    data = {
        max_value = 64
    }
}, {
    prototypes = {"roboport", "roboport-equipment"},
    properties = { -- Beacon/E-pole
        ["_base"] = {"logistics_radius", "construction_radius", "logistics_connection_distance"}
    },
    data = {
        max_value = MAX_FLOAT
    }
}, {
    prototypes = {"underground-belt"},
    properties = {
        ["_base"] = {"max_distance"}
    },
    data = {
        max_value = MAX_UINT8
    }
}, {
    properties = {
        ["_base"] = {"wire_max_distance", "circuit_wire_max_distance", "item_pickup_distance", "loot_pickup_distance"}
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    prototypes = {"character"},
    properties = {
        ["_base"] = {"build_distance", "drop_item_distance", "reach_distance"}
    },
    data = {
        max_value = MAX_UINT32
    }
}, {
    prototypes = {"character"},
    properties = {
        ["_base"] = {"reach_resource_distance", "item_pickup_distance", "loot_pickup_distance", "tool_attack_distance"}
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    prototypes = {"asteroid-collector"},
    properties = {
        ["_base"] = {"collection_radius"}
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    prototypes = {"agricultural-tower"},
    properties = {
        ["_base"] = {"radius"}
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    prototypes = {"utility-constants"},
    properties = {
        ["_base"] = {"default_pipeline_extent"}
    },
    data = {
        max_value = MAX_DOUBLE
    }
}, {
    properties = {
        ["fluid_box"] = {
            ["_base"] = {"default_pipeline_extent"}
        }
    },
    data = {
        max_value = MAX_UINT32
    }
}, {
    properties = {
        ["fluid_box"] = {
            ["pipe_connections"] = {
                ["_array"] = {
                    ["_filter_field"] = "connection_type",
                    ["_filter_values"] = {"underground"},
                    ["_base"] = {"max_underground_distance"}
                }
            }
        }
    },
    data = {
        max_value = MAX_UINT8
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"character-build-distance", "character-item-drop-distance",
                                      "character-reach-distance", "character-resource-reach-distance",
                                      "character-item-pickup-distance", "character-loot-pickup-distance",
                                      "artillery-range"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}}
multiply_loop(range, settings.startup["dt-range-multiplier"].value)

-- TODO: Lightning attractor range
