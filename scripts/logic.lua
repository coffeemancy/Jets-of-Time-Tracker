function canAccessSealed()
  local pendant = Tracker:FindObjectForCode("pendant").Active
  local earlyPendant = Tracker:ProviderCountForCode("earlypendant") > 0
  local blackTyrano = Tracker:FindObjectForCode("blacktyranoboss").Active
  local dragonTank = Tracker:FindObjectForCode("dragontankboss").Active
  local magus = Tracker:FindObjectForCode("magusboss").Active
  local locMode = string.find(Tracker.ActiveVariantUID, "legacy_of_cyrus")
  local lwMode = string.find(Tracker.ActiveVariantUID, "lost_worlds")

  return ((dragonTank or (locMode and pendant)) and earlyPendant) or (pendant and (magus or blackTyrano or lwMode))
end

function canFly()
  local epochfail = Tracker:ProviderCountForCode("epochfail") > 0
  local fixedepoch = Tracker:FindObjectForCode("fixedepoch").Active

  return (not epochfail) or fixedepoch
end

function canAccessFactory()
  if canFly() then
    return true
  end

  local johnnyRace = Tracker:ProviderCountForCode("Flag_JohnnyRace_on") > 0
  local hasBikekey = Tracker:FindObjectForCode("bikekey").Active
  return (not johnnyRace) or hasBikekey
end

function useLegacyEpochFail()
  local epochfail = Tracker:ProviderCountForCode("epochfail") > 0
  local unlockedSkyways = Tracker:ProviderCountForCode("unlockedskyways") > 0
  return epochfail and not unlockedSkyways
end

function useVanillaSunKeep()
  local sunKeepSpot = Tracker:ProviderCountForCode("Flag_ExtraSunKeep_on") > 0
  return not sunKeepSpot
end
