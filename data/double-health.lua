local helper = require("helper")

-- Health
for _, prototype in pairs(data.raw["prototypes"]) do
    for _, type in pairs (prototype) do
        if type.max_health then type.max_health = type.max_health * 2 end
    end
end

-- Spoil ticks
for _, item in pairs(data.raw["prototypes"]["item"]) do
    if item.spoil_ticks then item.spoil_ticks = item.spoil_ticks * 2 end
end

-- Durability
for _, tool in pairs(data.raw["prototypes"]["tool"]) do
    if tool.durability then tool.durability = tool.durability * 2 end
end
for _, quality in pairs(data.raw["prototypes"]["quality"] or {}) do
    if quality.tool_durability_multiplier then quality.tool_durability_multiplier = quality.tool_durability_multiplier * 2 end
end