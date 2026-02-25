local helper = require("helper")

-- Belts
local types = {"lane-splitter", "linked-belt", "loader-1x1", "loader", "splitter", "transport-belt", "underground-belt"}
for _, type in pairs(types) do
    for _, belt in pairs(data.raw["prototypes"][type] or {}) do
        -- belt.speed = belt.speed * 2
        helper.multiply(belt.speed)
    end
end

-- Inserters
for _, inserter in pairs(data.raw["prototypes"]["inserter"] or {}) do
    -- inserter.extension_speed = inserter.extension_speed * 2
    -- inserter.rotation_speed = inserter.rotation_speed * 2
        helper.multiply(inserter.extension_speed)
        helper.multiply(inserter.rotation_speed)
end

-- Asteroid collectors
for _, collector in pairs(data.raw["prototypes"]["asteroid-collector"] or {}) do
    -- if collector.arm_speed_base then collector.arm_speed_base = collector.arm_speed_base * 2 end
    helper.multiply(collector.arm_speed_base)
end

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