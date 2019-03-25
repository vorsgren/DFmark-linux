-- Creates a unit.  Beta; use at own risk.

-- Originally created by warmist
-- Significant contributions over time by Boltgun, Dirst, Expwnent, lethosor, mifki, Putnam and Atomic Chicken.

-- version 0.6
-- This is a beta version. Use at your own risk.

-- Modifications from 0.55:
--   sets baby/child profession and mood for creatures of the appropriate age where relevant
--   properly assigns civ_id to historical_figure to eliminate a number of hostility issues
--   removes the arena-generated string of numbers from the first name of units
--   added 'quantity' arg for spawning multiple creatures simultaneously
--   creature caste is now randomly selected if left unspecified

--[[
  TODO
    confirm body size is computed appropriately for different ages / life stages
    incarnate pre-existing historical figures
    some sort of invasion helper script
      set invasion_id, etc
    announcement for fake natural birth if appropriate
    option to attach to an existing wild animal population
    option to attach to a map feature
]]

--@ module = true

local usage = [====[

modtools/create-unit
====================
Creates a unit.  Usage::

    -race raceName
        specify the race of the unit to be created
        examples:
            DWARF
            HUMAN
    -caste casteName
        specify the caste of the unit to be created
        if not specified, the caste is randomly selected
        examples:
            MALE
            FEMALE
    -domesticate
        tames the unit if it lacks the CAN_LEARN and CAN_SPEAK tokens
    -civId id
        Make the created unit a member of the specified civ
        (or none if id = -1).  If id is \\LOCAL, make it a member of the
        civ associated with the fort; otherwise id must be an integer
    -groupId id
        Make the created unit a member of the specified group
        (or none if id = -1).  If id is \\LOCAL, make it a member of the
        group associated with the fort; otherwise id must be an integer
    -setUnitToFort
        Sets the groupId and civId to the local fort
        Can be used instead of -civId \\LOCAL and -groupId \\LOCAL
    -name entityRawName
        set the unit's name to be a random name appropriate for the
        given entity
        examples:
            MOUNTAIN
            EVIL
    -nick nickname
        set the unit's nickname directly
    -location [ x y z ]
        create the unit at the specified coordinates
    -age howOld
        set the birth date of the unit by current age
        chosen randomly if not specified
    -quantity howMany
        replace "howMany" with the number of creatures you want to create
        defaults to 1 if not specified
    -flagSet [ flag1 flag2 ... ]
        set the specified unit flags in the new unit to true
        flags may be selected from df.unit_flags1, df.unit_flags2,
        or df.unit_flags3
    -flagClear [ flag1 flag2 ... ]
        set the specified unit flags in the new unit to false
        flags may be selected from df.unit_flags1, df.unit_flags2,
        or df.unit_flags3

]====]

--[[
if dfhack.gui.getCurViewscreen()._type ~= df.viewscreen_dwarfmodest or df.global.ui.main.mode ~= df.ui_sidebar_mode.LookAround then
  print 'activate loo[k] mode'
  return
end
--]]

local utils=require 'utils'

function createUnit(...)
  local old_gametype = df.global.gametype
  local old_mode = df.global.ui.main.mode
  local old_popups = {}
  for _, popup in pairs(df.global.world.status.popups) do
    table.insert(old_popups, popup)
  end
  df.global.world.status.popups:resize(0)

  local ok, ret = dfhack.pcall(createUnitInner, ...)

  df.global.gametype = old_gametype
  df.global.ui.main.mode = old_mode
  for _, popup in pairs(old_popups) do
    df.global.world.status.popups:insert('#', popup)
  end

  if not ok then
    error(ret)
  end

  return ret
end

function createUnitInner(race_id, caste_id, location, entityRawName)
  local view_x = df.global.window_x
  local view_y = df.global.window_y
  local view_z = df.global.window_z

  local curViewscreen = dfhack.gui.getCurViewscreen()
  local dwarfmodeScreen = df.viewscreen_dwarfmodest:new()
  curViewscreen.child = dwarfmodeScreen
  dwarfmodeScreen.parent = curViewscreen
  df.global.ui.main.mode = df.ui_sidebar_mode.LookAround

  local gui = require 'gui'

  if not dfhack.world.isArena() then
    -- This is already populated in arena mode, so don't clear it then (#994)
    df.global.world.arena_spawn.race:resize(0)
    df.global.world.arena_spawn.race:insert(0,race_id)

    df.global.world.arena_spawn.caste:resize(0)
    df.global.world.arena_spawn.caste:insert(0,caste_id)

    df.global.world.arena_spawn.creature_cnt:resize(0)
    df.global.world.arena_spawn.creature_cnt:insert(0,0)
  end

  df.global.gametype = df.game_type.DWARF_ARENA
  gui.simulateInput(dwarfmodeScreen, 'D_LOOK_ARENA_CREATURE')

  -- move cursor to location instead of moving unit later, corrects issue of missing mapdata when moving the created unit.
  if location then
    df.global.cursor.x = tonumber(location[1])
    df.global.cursor.y = tonumber(location[2])
    df.global.cursor.z = tonumber(location[3])
  end

  local spawnScreen = dfhack.gui.getCurViewscreen()
  if dfhack.world.isArena() then
    -- Just modify the current screen in arena mode (#994)
    spawnScreen.race:insert(0, race_id)
    spawnScreen.caste:insert(0, caste_id)
  end
  gui.simulateInput(spawnScreen, 'SELECT')

  curViewscreen.child = nil
  dwarfmodeScreen:delete()

  local id = df.global.unit_next_id-1

  df.global.window_x = view_x
  df.global.window_y = view_y
  df.global.window_z = view_z

  local unit = df.unit.find(id)
  if entityRawName and tostring(entityRawName) then
    nameUnit(id, entityRawName)
  else
    unit.name.first_name = '' -- removes the string of numbers produced by the arena spawning process
    unit.name.has_name = false
    if unit.status.current_soul then
      unit.status.current_soul.name.has_name = false
    end
  end

  return id
end

--u.population_id = df.historical_entity.find(df.global.ui.civ_id).populations[0]

-- Picking a caste or gender at random
function getRandomCasteId(race)
  local casteMax = #race.caste - 1

  if casteMax > 0 then
    return math.random(0, casteMax)
  end

  return 0
end

local function  allocateNewChunk(hist_entity)
  hist_entity.save_file_id=df.global.unit_chunk_next_id
  df.global.unit_chunk_next_id=df.global.unit_chunk_next_id+1
  hist_entity.next_member_idx=0
  print("allocating chunk:",hist_entity.save_file_id)
end

local function allocateIds(nemesis_record,hist_entity)
  if hist_entity.next_member_idx==100 then
    allocateNewChunk(hist_entity)
  end
  nemesis_record.save_file_id=hist_entity.save_file_id
  nemesis_record.member_idx=hist_entity.next_member_idx
  hist_entity.next_member_idx=hist_entity.next_member_idx+1
end

function createFigure(trgunit,he,he_group)
  local hf = df.historical_figure:new()
  hf.id = df.global.hist_figure_next_id
  hf.race = trgunit.race
  hf.caste = trgunit.caste
  hf.profession = trgunit.profession
  hf.sex = trgunit.sex
  df.global.hist_figure_next_id=df.global.hist_figure_next_id+1
  hf.appeared_year = df.global.cur_year

  hf.born_year = trgunit.birth_year
  hf.born_seconds = trgunit.birth_time
  hf.curse_year = trgunit.curse_year
  hf.curse_seconds = trgunit.curse_time
  hf.birth_year_bias = trgunit.birth_year_bias
  hf.birth_time_bias = trgunit.birth_time_bias
  hf.old_year = trgunit.old_year
  hf.old_seconds = trgunit.old_time
  hf.died_year = -1
  hf.died_seconds = -1
  hf.name:assign(trgunit.name)
  hf.civ_id = trgunit.civ_id
  hf.population_id = trgunit.population_id
  hf.breed_id = -1
  hf.unit_id = trgunit.id
  hf.unit_id2 = trgunit.id

  df.global.world.history.figures:insert("#",hf)

  hf.info = df.historical_figure_info:new()
  hf.info.unk_14 = df.historical_figure_info.T_unk_14:new() -- hf state?
  --unk_14.region_id = -1; unk_14.beast_id = -1; unk_14.unk_14 = 0
  hf.info.unk_14.unk_18 = -1; hf.info.unk_14.unk_1c = -1
  -- set values that seem related to state and do event
  --change_state(hf, dfg.ui.site_id, region_pos)


  --lets skip skills for now
  --local skills = df.historical_figure_info.T_skills:new() -- skills snap shot
  -- ...
  -- note that innate skills are automaticaly set by DF
  hf.info.skills = {new=true}

  if he then
    he.histfig_ids:insert('#', hf.id)
    he.hist_figures:insert('#', hf)
    hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=trgunit.civ_id,link_strength=100})

    --add entity event
    local hf_event_id = df.global.hist_event_next_id
    df.global.hist_event_next_id = df.global.hist_event_next_id+1
    df.global.world.history.events:insert("#",{new=df.history_event_add_hf_entity_linkst,year=trgunit.birth_year,
    seconds=trgunit.birth_time,id=hf_event_id,civ=hf.civ_id,histfig=hf.id,link_type=0})
  end

  if he_group and he_group ~= he then
    he_group.histfig_ids:insert('#', hf.id)
    he_group.hist_figures:insert('#', hf)
    hf.entity_links:insert("#",{new=df.histfig_entity_link_memberst,entity_id=he_group.id,link_strength=100})
  end

  trgunit.flags1.important_historical_figure = true
  trgunit.flags2.important_historical_figure = true
  trgunit.hist_figure_id = hf.id
  trgunit.hist_figure_id2 = hf.id

  return hf
end

function createNemesis(trgunit,civ_id,group_id)
  local id=df.global.nemesis_next_id
  local nem=df.nemesis_record:new()

  nem.id=id
  nem.unit_id=trgunit.id
  nem.unit=trgunit
  nem.flags:resize(4)
  --not sure about these flags...
  -- [[
  nem.flags[4]=true
  nem.flags[5]=true
  nem.flags[6]=true
  nem.flags[7]=true
  nem.flags[8]=true
  nem.flags[9]=true
  --]]
  --[[for k=4,8 do
      nem.flags[k]=true
  end]]
  nem.unk10=-1
  nem.unk11=-1
  nem.unk12=-1
  df.global.world.nemesis.all:insert("#",nem)
  df.global.nemesis_next_id=id+1
  trgunit.general_refs:insert("#",{new=df.general_ref_is_nemesisst,nemesis_id=id})

  nem.save_file_id=-1

  if civ_id ~= -1 then
    local he=df.historical_entity.find(civ_id)
    he.nemesis_ids:insert("#",id)
    he.nemesis:insert("#",nem)
    allocateIds(nem,he)
  end
  local he_group
  if group_id and group_id ~= -1 then
      he_group=df.historical_entity.find(group_id)
  end
  if he_group then
      he_group.nemesis_ids:insert("#",id)
      he_group.nemesis:insert("#",nem)
  end
  nem.figure = trgunit.hist_figure_id ~= -1 and df.historical_figure.find(trgunit.hist_figure_id) or createFigure(trgunit,he,he_group) -- the histfig check is there just in case this function is called by another script to create nemesis data for a historical figure which somehow lacks it
  return nem
end

function createUnitInCiv(race_id, caste_id, civ_id, group_id, location, entityRawName)
  local uid = createUnit(race_id, caste_id, location, entityRawName)
  local unit = df.unit.find(uid)
  if ( civ_id ) then
    unit.civ_id = civ_id
    createNemesis(unit, civ_id, group_id)
  end
  return uid
end

function domesticate(uid, group_id)
  local u = df.unit.find(uid)
  group_id = group_id or df.global.ui.group_id
  -- If a friendly animal, make it domesticated.  From Boltgun & Dirst
  local caste=df.creature_raw.find(u.race).caste[u.caste]
  if not(caste.flags.CAN_SPEAK and caste.flags.CAN_LEARN) then
    -- Fix friendly animals (from Boltgun)
    u.flags2.resident = false;
    u.flags3.body_temp_in_range = true;
    u.population_id = -1
    u.status.current_soul.id = u.id

    u.animal.population.region_x = -1
    u.animal.population.region_y = -1
    u.animal.population.unk_28 = -1
    u.animal.population.population_idx = -1
    u.animal.population.depth = -1

    -- And make them tame (from Dirst)
    u.flags1.tame = true
    u.training_level = 7
  end
end

function wild(uid)
  if dfhack.world.isArena() then return end
  local u = df.unit.find(uid)
  local caste=df.creature_raw.find(u.race).caste[u.caste]
  -- x = df.global.world.world_data.active_site[0].pos.x
  -- y = df.global.world.world_data.active_site[0].pos.y
  -- region = df.global.map.map_blocks[df.global.map.x_count_block*x+y]
  if not(caste.flags.CAN_SPEAK and caste.flags.CAN_LEARN) then
    if #df.global.world.world_data.active_site > 0 then -- empty in adventure mode
      u.animal.population.region_x = df.global.world.world_data.active_site[0].pos.x
      u.animal.population.region_y = df.global.world.world_data.active_site[0].pos.y
    end
    u.animal.population.unk_28 = -1
    u.animal.population.population_idx = -1  -- Eventually want to make a real population
    u.animal.population.depth = -1  -- Eventually this should be a parameter
    u.animal.leave_countdown = 99999  -- Eventually this should be a parameter
    u.flags2.roaming_wilderness_population_source = true
    u.flags2.roaming_wilderness_population_source_not_a_map_feature = true
    -- region = df.global.world.map.map_blocks[df.global.world.map.x_count_block*x+y]
  end
end

function nameUnit(id, entityRawName)
  --pick a random appropriate name
  --choose three random words in the appropriate things
  local unit = df.unit.find(id)
  local entity_raw
  if entityRawName then
    for k,v in ipairs(df.global.world.raws.entities) do
      if v.code == entityRawName then
        entity_raw = v
        break
      end
    end
  end

  if not entity_raw then
    qerror('Entity raw not found: '..entityRawName)
  end

  local translation = entity_raw.translation
  local translationIndex
  for k,v in ipairs(df.global.world.raws.language.translations) do
    if v.name == translation then
      translationIndex = k
      break
    end
  end
  --translation = df.language_translation.find(translation)
  local language_word_table = entity_raw.symbols.symbols1[0] --educated guess
  function randomWord()
    local index = math.random(0, #language_word_table.words[0] - 1)
    return index
  end
  local firstName = randomWord()
  local lastName1 = randomWord()
  local lastName2 = randomWord()
  local name = unit.status.current_soul.name
  name.words[0] = language_word_table.words[0][lastName1]
  name.parts_of_speech[0] = language_word_table.parts[0][lastName1]
  name.words[1] = language_word_table.words[0][lastName2]
  name.parts_of_speech[1] = language_word_table.parts[0][lastName2]
  local language = nil
  for _, lang in pairs(df.global.world.raws.language.translations) do
    if lang.name == entity_raw.translation then
      language = lang
    end
  end
  if language then
    name.first_name = language.words[firstName].value
  else
    name.first_name = df.language_word.find(language_word_table.words[0][firstName]).forms[language_word_table.parts[0][firstName]]
  end
  name.has_name = true
  name.language = translationIndex
  unit.name:assign(name)
  if unit.hist_figure_id ~= -1 then
    local histfig = df.historical_figure.find(unit.hist_figure_id)
    histfig.name:assign(name)
  end
end

function setAgeProfession(unit)
-- checks for [BABY] and [CHILD] tokens and turns the unit into a baby/child if its age is appropriate
-- (AtomicChicken)
  local age = dfhack.units.getAge(unit,true)
  local cr = df.creature_raw.find(unit.race).caste[unit.caste]
  if cr.flags.BABY == true and age < cr.misc.baby_age then
    unit.profession = df.profession['BABY']
    --unit.profession2 = df.profession['BABY']
    unit.mood = df.mood_type['Baby']
  elseif cr.flags.CHILD == true and age < cr.misc.child_age then
    unit.profession = df.profession['CHILD']
    --unit.profession2 = df.profession['CHILD']
  else
    return
  end
  local hf = df.historical_figure.find(unit.hist_figure_id)
  if hf then
    hf.profession = unit.profession
  end
end

validArgs = utils.invert({
  'help',
  'race',
  'caste',
  'domesticate',
  'civId',
  'groupId',
  'flagSet',
  'flagClear',
  'name',
  'nick',
  'location',
  'age',
  'setUnitToFort', -- added by amostubal to get past an issue with \\LOCAL
  'quantity'
})

if moduleMode then
  return
end

local args = utils.processArgs({...}, validArgs)
if args.help then
  print(usage)
  return
end

local race
local raceIndex
local casteIndex

if not args.race then
  qerror('Specify a race for the new unit.')
end

--find race
for i,v in ipairs(df.global.world.raws.creatures.all) do
  if v.creature_id == args.race then
    raceIndex = i
    race = v
    break
  end
end

if not race then
  qerror('Invalid race: '..args.race)
end

if args.caste then -- if args.caste is omitted, casteIndex is randomly selected within the spawn loop below
  for i,v in ipairs(race.caste) do
    if v.caste_id == args.caste then
      casteIndex = i
      break
    end
  end

  if not casteIndex then
    qerror('Invalid caste: '..args.caste)
  end
end

local age
if args.age then
  age = tonumber(args.age)
  if not age and not age == 0 then
    qerror('Invalid age: ' .. args.age)
  end
end

local civ_id
if args.civId == '\\LOCAL' then
  civ_id = df.global.ui.civ_id
elseif args.civId and tonumber(args.civId) then
  civ_id = tonumber(args.civId)
end

local group_id
if args.groupId == '\\LOCAL' then
  group_id = df.global.ui.group_id
elseif args.groupId and tonumber(args.groupId) then
  group_id = tonumber(args.groupId)
end

--eliminates the need for the "\\LOCAL" all together which is buggy in how it is to be used...
if args.setUnitToFort then
  civ_id = df.global.ui.civ_id
  group_id = df.global.ui.group_id
end

local spawnNumber = 1
if args.quantity then
  spawnNumber = tonumber(args.quantity)
  if not spawnNumber or spawnNumber < 1 then
    qerror('Invalid spawn quantity: '..args.quantity)
  end
end

for n = 1,spawnNumber do

  if not args.caste then -- randomly select caste each time
    casteIndex = getRandomCasteId(race)
  end

  local unitId
  if civ_id == -1 then
    unitId = createUnit(raceIndex, casteIndex, args.location, args.name)
  else
    unitId = createUnitInCiv(raceIndex, casteIndex, civ_id, group_id, args.location, args.name)
  end

  if args.domesticate then
    domesticate(unitId, group_id)
  else
    wild(unitId)
  end

  local u = df.unit.find(unitId)
  u.counters.soldier_mood_countdown = -1
  u.counters.death_cause = -1
  u.enemy.unk_450 = -1
  u.enemy.unk_454 = -1
  u.enemy.army_controller_id = -1

--these flags are an educated guess of how to get the game to compute sizes correctly: use -flagSet and -flagClear arguments to override or supplement
  u.flags2.calculated_nerves = false
  u.flags2.calculated_bodyparts = false
  u.flags3.body_part_relsize_computed = false
  u.flags3.size_modifier_computed = false
  u.flags3.compute_health = true
  u.flags3.weight_computed = false

  if age or age == 0 then
    if age == 0 then
      u.birth_time = df.global.cur_year_tick
    end
    local u = df.unit.find(unitId)
    local oldYearDelta = u.old_year - u.birth_year
    u.birth_year = df.global.cur_year - age
    if u.old_year ~= -1 then
      u.old_year = u.birth_year + oldYearDelta
    end
    if u.flags1.important_historical_figure == true and u.flags2.important_historical_figure == true then
      local hf = df.historical_figure.find(u.hist_figure_id)
      hf.born_year = u.birth_year
      hf.born_seconds = u.birth_time
      hf.old_year = u.old_year
      hf.old_seconds = u.old_time
    end
  end
  setAgeProfession(u)

  if args.flagSet or args.flagClear then
    local u = df.unit.find(unitId)
    local flagsToSet = {}
    local flagsToClear = {}
    for _,v in ipairs(args.flagSet or {}) do
      flagsToSet[v] = true
    end
    for _,v in ipairs(args.flagClear or {}) do
      flagsToClear[v] = true
    end
    for _,k in ipairs(df.unit_flags1) do
      if flagsToSet[k] then
        u.flags1[k] = true;
      elseif flagsToClear[k] then
        u.flags1[k] = false;
      end
    end
    for _,k in ipairs(df.unit_flags2) do
      if flagsToSet[k] then
        u.flags2[k] = true;
      elseif flagsToClear[k] then
        u.flags2[k] = false;
      end
    end
    for _,k in ipairs(df.unit_flags3) do
      if flagsToSet[k] then
        u.flags3[k] = true;
      elseif flagsToClear[k] then
        u.flags3[k] = false;
      end
    end
  end

  if args.nick and type(args.nick) == 'string' then
    dfhack.units.setNickname(df.unit.find(unitId), args.nick)
  end
end
