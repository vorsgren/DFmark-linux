-- delay for a time then call a lua script
-- eg "delay -time 1 months -command cleanowned"; to disable "delay -cancel cleanowned"
-- author vorsgren
-- based on the dfhack command repeat

local usage = [====[

delay
======
Waits a set amount of time and then calls a lua script. This can be used from
init files. Note that any time units other than ``frames`` are unsupported when
a world is not loaded (see ``dfhack.timeout()``).

Usage examples::

    delay -name jim -time delay -timeUnits units -command [ printArgs 3 1 2 ]
    delay -time 1 -timeUnits months -command [ multicmd cleanowned scattered x; clean all ] -name clean

The first example is abstract; the second will regularly remove all contaminants
and worn items from the game.

Arguments:

``-name``
    sets the name for the purposes of cancelling and making sure you
    don't schedule the same repeating event twice.  If not specified,
    it's set to the first argument after ``-command``.
``-time DELAY -timeUnits UNITS``
    DELAY is some positive integer, and UNITS is some valid time
    unit for ``dfhack.timeout`` (default "ticks").  Units can be
    in simulation-time "frames" (raw FPS) or "ticks" (only while
    unpaused), while "days", "months", and "years" are by in-world time.
``-command [ ... ]``
    ``...`` specifies the command to be run
``-cancel NAME``
    cancels the repetition with the name NAME

]====]

local repeatUtil = require 'repeat-util'
local utils = require 'utils'

local validArgs = utils.invert({
 'help',
 'cancel',
 'name',
 'time',
 'timeUnits',
 'command'
})

local args = utils.processArgs({...}, validArgs)

if args.help then
 print(usage)
 return
end

if args.cancel then
 repeatUtil.cancel(args.cancel)
 if args.name then
  repeatUtil.cancel(args.name)
 end
 return
end

local time = tonumber(args.time)

if not args.name then
 args.name = args.command[1]
end

if not args.timeUnits then
 args.timeUnits = 'ticks'
end

local callCommand = function()
 dfhack.run_command(table.unpack(args.command))
end

dfhack.timeout(time,args.timeUnits,callCommand)
