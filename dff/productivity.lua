----------------------------------------------------------------------------------------------------
-- PRODUCTIVITY
----------------------------------------------------------------------------------------------------
logif("===== PRODUCTIVITY =====")
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
}, { -- Modules & module receivers
    prototypes = {"module", "assembling-machine", "rocket-silo", "furnace", "lab", "mining-drill"},
    properties = {
        ["effect"] = {
            ["_base"] = {"productivity"}
        },
        ["effect_receiver"] = {
            ["base_effect"] = {
                ["_base"] = {"productivity"}
            }
        }
    },
    data = {
        max_value = 327.669
    }
}, { -- Labs
    prototypes = {"lab"},
    properties = {
        ["_base"] = {"science_pack_drain_rate_percent"}
    },
    data = {
        divide = true,
        round_up = true,
        max_value = 100
    }
}, { -- Technology recipe productivity
    prototypes = {"technology"},
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
        max_value = 327.669
    }
}, { -- Technology (non recipe productivity)
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
