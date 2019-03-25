-- Lets constructions reconsider the build location.

-- Partial work-around for http://www.bay12games.com/dwarves/mantisbt/view.php?id=5991
--[====[

fix/build-location
==================
Fixes construction jobs that are stuck trying to build a wall while standing
on the same exact tile (:bug:`5991`), designates the tile restricted traffic to
hopefully avoid jamming it again, and unsuspends them.

]====]
local utils = require('utils')

local count = 0

for link,job in utils.listpairs(df.global.world.jobs.list) do
    local job = link.item
    local place = dfhack.job.getHolder(job)

    if job.job_type == df.job_type.ConstructBuilding
    and place and place:isImpassableAtCreation()
    and job.item_category[0]
    then
        local cpos = utils.getBuildingCenter(place)

        if same_xyz(cpos, job.pos) then
            -- Reset the flag
            job.item_category[0] = false
            job.flags.suspend = false

            -- Mark the tile restricted traffic
            local dsgn,occ = dfhack.maps.getTileFlags(cpos)
            dsgn.traffic = df.tile_traffic.Restricted

            count = count + 1
        end
    end
end

print('Found and unstuck '..count..' construct building jobs.')

if count > 0 then
    df.global.process_jobs = true
end
