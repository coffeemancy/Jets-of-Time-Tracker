print("Detected PopVersion: " .. PopVersion)

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

  print("Adding Components...")
  for _, v in pairs(components) do Tracker:AddLayouts(v) end

  -- Toggles extra items on when "Shoe Extra Items" is toggled on
  function toggleExtraItems(_code)
    if hasFlagEnabled("ToggleExtraItems") then
      Tracker:AddLayouts(components["items_grid_extras"])
    else
      Tracker:AddLayouts(components["items_grid"])
    end
  end

  components["items_grid_extras"] = "layouts/components/items_grid_extras.json"

  -- Setup toggles in UI from Settings
  ScriptHost:AddWatchForCode("ToggleExtraItems", "toggle_extra_items", toggleExtraItems)

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
  end

  print("Adding Layouts...")
  for _, v in pairs(layouts) do Tracker:AddLayouts(v) end

end

-- Configure tracker
print("Configurating tracker...")
Tracker:AddItems("items/items.json")
Tracker:AddMaps("maps/maps.json")
Tracker:AddLocations("locations/locations.json")
addComponents()
addTrackerLayouts()

if _VERSION == "Lua 5.3" then
  print("Setting up autotracking...")
  ScriptHost:LoadScript("scripts/autotracking.lua")
else
  print("Auto-tracker is unsupported by your tracker version")
end
