Tracker:AddItems("items/items.json")
Tracker:AddMaps("maps/maps.json")
ScriptHost:LoadScript("scripts/logic.lua")

local items_grid_component = "layouts/components/items_grid.json"
local bosses_grid_component = "layouts/components/bosses_grid.json"
local flags_grid_component = "layouts/components/flags_grid.json"
local extra_flags_grid_component = "layouts/components/extra_flags_grid.json"
local tracker_layout = "layouts/tracker.json"
local broadcast_layout = "layouts/broadcast.json"

if legacyOfCyrusMode() then
  items_grid_component = "legacy_of_cyrus/layouts/components/items_grid.json"
  bosses_grid_component = "legacy_of_cyrus/layouts/components/bosses_grid.json"
elseif lostWorldsMode() then
  items_grid_component = "lost_worlds/layouts/components/items_grid.json"
  bosses_grid_component = "lost_worlds/layouts/components/bosses_grid.json"
  flags_grid_component = "lost_worlds/layouts/components/flags_grid.json"
elseif vanillaRandoMode() then
  items_grid_component = "vanilla_rando/layouts/components/items_grid.json"
end

if string.find(Tracker.ActiveVariantUID, "items_only") then
  tracker_layout = "items_only/layouts/tracker.json"
elseif lostWorldsMode() then
  tracker_layout = "lost_worlds/layouts/tracker.json"
end

Tracker:AddLocations("locations/locations.json")
Tracker:AddLayouts(items_grid_component)
Tracker:AddLayouts(bosses_grid_component)
Tracker:AddLayouts(flags_grid_component)
Tracker:AddLayouts(extra_flags_grid_component)
Tracker:AddLayouts(tracker_layout)
Tracker:AddLayouts(broadcast_layout)

if _VERSION == "Lua 5.3" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
else
    print("Auto-tracker is unsupported by your tracker version")
end
