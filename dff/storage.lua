----------------------------------------------------------------------------------------------------
-- STORAGE
----------------------------------------------------------------------------------------------------
log("===== STORAGE =====")
local storage = {{
    ignore_prototypes = {"blueprint-book"}
    properties = {
        ["_base"] = {"inventory_size", "inventory_size_bonus", "inventory_size_multiplier", "inventory_size_quality_increase",
                        "arm_inventory_size", "arm_inventory_size_quality_increase", "input_inventory_size", "output_inventory_size", "result_inventory_size"}
    },
    data = {
        max_value = MAX_UINT16
    }
}, {
    properties = {
        ["_base"] = {"gun_inventory_size", "guns_inventory_size"}
    },
    data = {
        ignore = not settings.startup["dt-storage-guns"].value,
        max_value = 15
    }
}, {
    properties = {
        ["burner"] = {["_base"] = "fuel_inventory_size", "burnt_inventory_size"},
        ["energy_source"] = {["_base"] = "fuel_inventory_size", "burnt_inventory_size"}
    },
    data = {
        max_value = MAX_UINT16
    }
}, {
    properties = {
        ["_base"] = {"trash_inventory_size", "logistic_trash_inventory_size"}
    },
    data = {
        ignore = not settings.startup["dt-storage-trash"].value,
        max_value = MAX_UINT16
    }
}, {
    properties = {
        ["_base"] = {"capacity"}
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"storage-tank"}
    properties = {
        ["fluid_box"] = {
            ["_base"] = {"volume"}
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"character-inventory-slots-bonus", "cargo-landing-pad-count"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        max_value = MAX_INT32 -- Double
    }
}, {
    prototypes = {"technology"},
    properties = {
        ["effects"] = {
            ["_array"] = {
                ["_filter_field"] = "type",
                ["_filter_values"] = {"character-logistic-trash-slots"},
                ["_base"] = {"modifier"}
            }
        }
    },
    data = {
        ignore = not settings.startup["dt-storage-trash"].value,
        max_value = MAX_INT32 -- Double
    }
}}
multiply_loop(storage, settings.startup["dt-storage-multiplier"].value)


-- To include
-- Chests
-- Storage tanks
-- TBD: Fluid boxes?
-- TBD: Crating machine buffers?
-- Asteroid collector
-- Equipment items
-- Character

