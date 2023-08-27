ScriptHost:LoadScript("scripts/logic.lua")

--
-- Adds components used by tracker for items, bosses, flags, etc.
--
function addComponents()

  -- relative component paths
  -- NOTE: PopTracker will prefix components automatically with variant name
  -- and prefer those, but if they don't exist, will fall back to
  -- using paths relative to pack root directory
  local components = {}
  components["items_grid"] = "layouts/components/items_grid.json"
  components["bosses_grid"] = "layouts/components/bosses_grid.json"
  components["flags_grid"] = "layouts/components/flags_grid.json"
  components["extra_flags_grid"] = "layouts/components/extra_flags_grid.json"

  for _, v in pairs(components) do Tracker:AddLayouts(v) end

end

--
-- Adds main tracker and broadcast layouts based on mode and variant.
--
function addTrackerLayouts()

  local layouts = {}
  layouts["tracker"] = "layouts/tracker.json"
  layouts["broadcast"] = "layouts/broadcast.json"
  layouts["settings_popup"] = "layouts/settings_popup.json"

  if itemsOnlyTracking() then
    layouts["tracker"] = "items_only/layouts/tracker.json"
  elseif string.find(Tracker.ActiveVariantUID, "lost_world_items") then
    layouts["tracker"] = "lost_world_items/layouts/tracker.json"
    layouts["broadcast"] = "lost_world_items/layouts/broadcast.json"
  elseif lostWorldsMode() then
    layouts["tracker"] = "lost_worlds/layouts/tracker.json"
    layouts["broadcast"] = "lost_worlds/layouts/broadcast.json"
  elseif vanillaRandoMode() then
    layouts["tracker"] = "vanilla_rando/layouts/tracker.json"
    layouts["broadcast"] = "vanilla_rando/layouts/broadcast.json"
  end

  for _, v in pairs(layouts) do Tracker:AddLayouts(v) end

end

-- Configure tracker
Tracker:AddItems("items/items.json")
Tracker:AddMaps("maps/maps.json")
Tracker:AddLocations("locations/locations.json")
addComponents()
addTrackerLayouts()

if _VERSION == "Lua 5.3" then
  ScriptHost:LoadScript("scripts/autotracking.lua")
else
    print("Auto-tracker is unsupported by your tracker version")
end
