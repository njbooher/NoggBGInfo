local _,NoggBGInfo = ...

SLASH_NOGGBG1 = '/noggbg'
local function handler(message, editbox)

  local args = {string.split(" ", message, 2)}
  local command = args[1]:lower()

  if(command == "c") then
    NoggBGInfo.bgList(true)
  else
    NoggBGInfo.bgList()
  end
  
end
SlashCmdList["NOGGBG"] = handler

-- Class talent specs
local role = {
        DEATHKNIGHT = {
          Blood         = "Tank",
          Frost         = "Melee",
          Unholy        = "Melee"
        },
        DRUID = {
          Balance       = "Ranged",
          ["Feral Combat"]  = "Feral",
          Restoration   = "Healer"
        },
        HUNTER = {
          ["Beast Mastery"] = "Ranged",
          Marksmanship  = "Ranged",
          Survival      = "Ranged"
        },
        MAGE = {
          Arcane        = "Ranged",
          Fire          = "Ranged",
          Frost         = "Ranged"
        },
        PALADIN = {
          Holy          = "Healer",
          Protection    = "Tank",
          Retribution   = "Melee"
        },
        PRIEST = {
          Discipline    = "Healer",
          Holy          = "Healer",
          Shadow        = "Ranged"
        },
        ROGUE = {
          Assassination = "Melee",
          Combat        = "Melee",
          Subtlety      = "Melee"
        },
        SHAMAN = {
          Elemental     = "Ranged",
          Enhancement   = "Melee",
          Restoration   = "Healer"
        },
        WARLOCK = {
          Affliction    = "Ranged",
          Demonology    = "Ranged",
          Destruction   = "Ranged"
        },
        WARRIOR = {
          Arms          = "Melee",
          Fury          = "Melee",
          Protection    = "Tank"
        }
}

local bgForeign = {
  "Azralon",
  "Gallywix",
  "Goldrinn",
  "Nemesis",
  "Tol Barad",
  "Drakkari",
  "Quel'Thalas",
  "Ragnaros"
}
  
function NoggBGInfo.bgList(bgChat)

  -- Show scores for all players
  SetBattlefieldScoreFaction()
  
  -- Build list of players
  local totals = {
    Horde = {
      Melee  = 0,
      Ranged = 0,
      Healer = 0,
      Tank   = 0,
      Feral  = 0,
      Foreign = 0,
      none   = 0
    },
    Alliance = {
      Melee  = 0,
      Ranged = 0,
      Healer = 0,
      Tank   = 0,
      Feral  = 0,
      Foreign = 0,
      none   = 0
    }
  }

  
  local realmCounts = {
    Horde = {},
    Alliance = {},
  }

  for i = 1, GetNumBattlefieldScores() do
  
    local name, _, _, _, _, faction, _, _, classToken, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)
    local _, realm = string.split("-", name)
    
    local tableFaction = (faction == 0 and "Horde" or "Alliance")
    
    if tContains(bgForeign, realm) then
      totals[tableFaction]["Foreign"] = totals[tableFaction]["Foreign"] + 1
    end
  
    if realm then
      if realmCounts[tableFaction][realm] then
        realmCounts[tableFaction][realm] = realmCounts[tableFaction][realm] + 1
      else
        realmCounts[tableFaction][realm] = 1
      end
    end
    
    if talentSpec then
      totals[tableFaction][role[classToken][talentSpec]] = totals[tableFaction][role[classToken][talentSpec]] + 1
    else
      totals[tableFaction].none = totals[tableFaction].none + 1
    end
    
  end

  local premadeRealms = {
    Horde = {},
    Alliance = {},
  }
  
  local printHordePremade = false
  local printAlliancePremade = false
  
  for faction, factionRealmCounts in pairs(realmCounts) do
  
    local printPremade = false
    
    for k,v in pairs(factionRealmCounts) do
    
      if v > 3 then
        table.insert(premadeRealms[faction], k)
        printPremade = true
      end
    
    end
    
    printHordePremade = printHordePremade or (faction == "Horde" and printPremade)
    printAlliancePremade = printAlliancePremade or (faction == "Alliance" and printPremade)
    
  end
  
  local lowResil = {}
  
  EkInspect_Inspect_Perform(4, nil);
  EkInspect_Inspect_Perform(4, nil);
  
  for i, playerName in ipairs(EkInspect_SummaryList) do
  
    local playerTable = EkInspect_InspectList[playerName]
    if playerTable.total < 1000 then
      table.insert(lowResil, playerName)
    end
    
  end
  
  local hordeMessage = string.format("Horde: %i Feral Druids, %i Tanks, %i Healers, %i Ranged, %i Melee, %i ESL", totals.Horde.Feral, totals.Horde.Tank, totals.Horde.Healer, totals.Horde.Ranged, totals.Horde.Melee, totals.Horde.Foreign)
  local allyMessage = string.format("Alliance: %i Feral Druids, %i Tanks, %i Healers, %i Ranged, %i Melee, %i ESL", totals.Alliance.Feral, totals.Alliance.Tank, totals.Alliance.Healer, totals.Alliance.Ranged, totals.Alliance.Melee, totals.Alliance.Foreign)
  
  if bgChat then
    SendChatMessage(hordeMessage, "BATTLEGROUND")
    SendChatMessage(allyMessage, "BATTLEGROUND")
    
    if printAlliancePremade then
      SendChatMessage("Possible Alliance premade, 4 or more from " .. strjoin(", ", unpack(premadeRealms["Alliance"])), "BATTLEGROUND")
    end
    
    if #lowResil > 0 then
      SendChatMessage("Horde players with <1000 resil: " .. strjoin(", ", unpack(lowResil)), "BATTLEGROUND")
    end
    
  else
  
    print(hordeMessage)
    print(allyMessage)
    
    if printAlliancePremade then
      print("Possible Alliance premade, 4 or more from " .. strjoin(", ", unpack(premadeRealms["Alliance"])))
    end
    
    if printHordePremade then
      print("Possible Horde premade, 4 or more from " .. strjoin(", ", unpack(premadeRealms["Horde"])))
    end
    
    if #lowResil > 0 then
        print("Horde players with <1000 resil: " .. strjoin(", ", unpack(lowResil)))
    end
  
  end

end