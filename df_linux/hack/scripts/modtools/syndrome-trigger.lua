-- triggers scripts when a syndrome is applied
--author expwnent
local usage = [====[

modtools/syndrome-trigger
=========================
Triggers dfhack commands when syndromes are applied to units.

Arguments::

    -clear
        clear all triggers
    -syndrome name
        specify the name of a syndrome
    -command [ commandStrs ]
        specify the command to be executed after infection
        args
            \\SYNDROME_ID
            \\UNIT_ID
            \\LOCATION
            \\anything -> \anything
            anything -> anything

]====]
local eventful = require 'plugins.eventful'
local utils = require 'utils'

onInfection = onInfection or {} --as:{_type:table,_array:{_type:table,_array:{_type:table,command:__arg}}}

eventful.enableEvent(eventful.eventType.UNLOAD,1)
eventful.onUnload.syndromeTrigger = function()
 onInfection = {}
end

eventful.enableEvent(eventful.eventType.SYNDROME,5) --requires iterating through every unit, so not cheap, but not slow either

local function processTrigger(args)
 local command = {} --as:string[]
 for i,arg in ipairs(args.command) do --as:string
  if arg == '\\SYNDROME_ID' then
   table.insert(command, '' .. args.syndrome.id)
  elseif arg == '\\UNIT_ID' then
   table.insert(command, '' .. args.unit.id)
  elseif arg == '\\LOCATION' then
   table.insert(command, '' .. args.unit.pos.x)
   table.insert(command, '' .. args.unit.pos.y)
   table.insert(command, '' .. args.unit.pos.z)
  elseif string.sub(arg,1,1) == '\\' then
   table.insert(command, string.sub(arg,2))
  else
   table.insert(command, arg)
  end
 end
 dfhack.run_command(table.unpack(command))
end

eventful.onSyndrome.syndromeTrigger = function(unitId, syndromeIndex)
 local unit = df.unit.find(unitId)
 local unit_syndrome = unit.syndromes.active[syndromeIndex]
 local syn_id = unit_syndrome['type']
 if not onInfection[syn_id] then
  return
 end
 local syndrome = df.syndrome.find(syn_id)
 for _,args in ipairs(onInfection[syn_id] or {}) do
  processTrigger({
    unit = unit,
    unit_syndrome = unit_syndrome,
    syndrome = syndrome,
    command = args.command
  })
 end
end

------------------------------
--argument processing

local validArgs = utils.invert({
 'clear',
 'help',
 'command',
 'syndrome',
 'synclass',
 'unit'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.clear then
 onInfection = {}
end

if not args.command then
 return
end

if not args.syndrome
and not args.synclass then
 error 'Select a syndrome.'
end

function processSyndrome(syndrome)
 onInfection[syndrome] = onInfection[syndrome] or {}
 table.insert(onInfection[syndrome], args)
end

local syndrome
for _,syn in ipairs(df.global.world.raws.syndromes.all) do
 if args.syndrome then
  if syn.syn_name == args.syndrome then
   if syndrome then
    error ('Multiple syndromes with same name: ' .. syn.syn_name)
   end
   syndrome = syn.id
   processSyndrome(syn.id)
  end
 elseif args.synclass then
  for _,synclass in ipairs(syn.syn_class) do
   if synclass.value == args.synclass then
    syndrome = syn.id
    processSyndrome(syn.id)
   end
  end
 end
end

if not syndrome then
 if args.syndrome then
  error ('Invalid syndrome name: '..args.syndrome..'')
 elseif args.synclass then
  error ('Invalid syndrome class: '..args.synclass..'')
 end
end
