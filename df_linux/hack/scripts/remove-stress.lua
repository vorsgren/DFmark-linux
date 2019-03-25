-- Sets stress to negative one million
--By Putnam; http://www.bay12forums.com/smf/index.php?topic=139553.msg5820486#msg5820486
--@module = true
local help = [====[

remove-stress
=============
Sets stress to -1,000,000; the normal range is 0 to 500,000 with very stable or
very stressed dwarves taking on negative or greater values respectively.
Applies to the selected unit, or use ``remove-stress -all`` to apply to all units.

]====]

local utils = require 'utils'

function removeStress(unit)
    if unit.counters.soldier_mood > df.unit.T_counters.T_soldier_mood.Enraged then
        -- Tantrum, Depressed, or Oblivious
        unit.counters.soldier_mood = df.unit.T_counters.T_soldier_mood.None
    end
    if unit.status.current_soul then
        unit.status.current_soul.personality.stress_level = -1000000
    end
end

local validArgs = utils.invert({
    'help',
    'all'
})

function main(...)
    local args = utils.processArgs({...}, validArgs)

    if args.help then
        print(help)
        return
    end

    if args.all then
        for k,v in ipairs(df.global.world.units.active) do
            removeStress(v)
        end
    else
        local unit = dfhack.gui.getSelectedUnit()
        if unit then
            removeStress(unit)
        else
            error 'Invalid usage: No unit selected and -all argument not given.'
        end
    end
end

if not dfhack_flags.module then
    main(...)
end
