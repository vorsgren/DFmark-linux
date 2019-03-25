-- Shifts player control over to another unit in adventure mode.
-- author: Atomic Chicken
-- based on "assumecontrol.lua" by maxthyme, as well as the defunct advtools plugin "adv-bodyswap"
-- calls "modtools/create-unit" for nemesis and histfig creation

--@ module = true

local utils = require 'utils'
local validArgs = utils.invert({
'unit',
'help'
})
local args = utils.processArgs({...}, validArgs)

local usage = [====[

bodyswap
========
This script allows the player to take direct control of any unit present in
adventure mode whilst losing control of their current adventurer.

To specify the target unit, simply select it in the user interface,
such as by opening the unit's status screen or viewing its description,
and enter "bodyswap" in the DFHack console.

Alternatively, the target unit can be specified by its unit id as shown below.

Arguments::

    -unit id
        replace "id" with the unit id of your target
        example:
            bodyswap -unit 42

]====]

if args.help then
 print(usage)
 return
end

if not dfhack.world.isAdventureMode() then
  qerror("This script can only be used in adventure mode!")
end

function setNewAdvNemFlags(nem)
  nem.flags.ACTIVE_ADVENTURER = true
  nem.flags.RETIRED_ADVENTURER = false
  nem.flags.ADVENTURER = true
end
function setOldAdvNemFlags(nem)
  nem.flags.ACTIVE_ADVENTURER = false
  nem.flags.RETIRED_ADVENTURER = true
end

function clearNemesisFromLinkedSites(nem)
-- this is a workaround for a bug which tends to cause duplication of the unit entry in df.global.world.units.active when the site to which a historical figure is linked is reloaded with the unit present
-- appears to fix the problem without causing any noticeable issues
  if not nem.figure then
    return
  end
  for _,link in ipairs(nem.figure.site_links) do
    local site = df.world_site.find(link.site)
    for i = #site.unk_1.nemesis-1,0,-1 do
      if site.unk_1.nemesis[i] == nem.id then
        site.unk_1.nemesis:erase(i)
      end
    end
  end
end

function createNemesis(unit)
  local nemesis = reqscript('modtools/create-unit').createNemesis(unit,unit.civ_id)
  nemesis.figure.flags.never_cull = true
  return nemesis
end

function swapAdvUnit(newUnit)

  if not newUnit then
    qerror('Target unit not specified!')
  end

  local oldNem = df.nemesis_record.find(df.global.ui_advmode.player_id)
  local oldUnit = oldNem.unit
  if newUnit == oldUnit then
    return
  end

  local activeUnits = df.global.world.units.active
  local oldUnitIndex
  if activeUnits[0] == oldUnit then
    oldUnitIndex = 0
  else -- unlikely; this is just in case
    for i,u in ipairs(activeUnits) do
      if u == oldUnit then
        oldUnitIndex = i
        break
      end
    end
  end
  local newUnitIndex
  for i,u in ipairs(activeUnits) do
    if u == newUnit then
      newUnitIndex = i
      break
    end
  end

  if not newUnitIndex then
    qerror("Target unit index not found!")
  end

  local newNem = dfhack.units.getNemesis(newUnit) or createNemesis(newUnit)
  if not newNem then
    qerror("Failed to obtain target nemesis!")
  end

  setOldAdvNemFlags(oldNem)
  setNewAdvNemFlags(newNem)
  clearNemesisFromLinkedSites(newNem)
  df.global.ui_advmode.player_id = newNem.id
  activeUnits[newUnitIndex] = oldUnit
  activeUnits[oldUnitIndex] = newUnit
  oldUnit.idle_area:assign(oldUnit.pos)
end

if not dfhack_flags.module then
  local unit = args.unit and df.unit.find(tonumber(args.unit)) or dfhack.gui.getSelectedUnit()
  if not unit then
    print("Enter the following if you require assistance: bodyswap -help")
    if args.unit then
      qerror("Invalid unit id: "..args.unit)
    else
      qerror("Target unit not specified!")
    end
  end
  swapAdvUnit(unit)
end
