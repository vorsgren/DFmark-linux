-- Export everything from legends mode
--[====[

exportlegends
=============
Controls legends mode to export data - especially useful to set-and-forget large
worlds, or when you want a map of every site when there are several hundred.

The 'info' option exports more data than is possible in vanilla, to a
:file:`region-date-legends_plus.xml` file developed to extend
:forums:`World Viewer <128932>` and other legends utilities.

Options:

:info:   Exports the world/gen info, the legends XML, and a custom XML with more information
:custom: Exports a custom XML with more information
:sites:  Exports all available site maps
:maps:   Exports all seventeen detailed maps
:all:    Equivalent to calling all of the above, in that order

]====]

--luacheck-flags: strictsubtype

local gui = require 'gui'
local script = require 'gui.script'
local args = {...}
local vs = dfhack.gui.getCurViewscreen()

local MAPS = {
    "Standard biome+site map",
    "Elevations including lake and ocean floors",
    "Elevations respecting water level",
    "Biome",
    "Hydrosphere",
    "Temperature",
    "Rainfall",
    "Drainage",
    "Savagery",
    "Volcanism",
    "Current vegetation",
    "Evil",
    "Salinity",
    "Structures/fields/roads/etc.",
    "Trade",
    "Nobility and Holdings",
    "Diplomacy",
}

function getItemSubTypeName(itemType, subType)
    if (dfhack.items.getSubtypeCount(itemType)) <= 0 then
        return tostring(-1)
    end
    local subtypename = dfhack.items.getSubtypeDef(itemType, subType)
    if (subtypename == nil) then
        return tostring(-1)
    else
        return tostring(subtypename.name):lower()
    end
end

function table:contains(element)
    for _, value in pairs(self) do
        if value == element then
            return true
        end
    end
    return false
end

function table:containskey(key)
    for value, _ in pairs(self) do
        if value == key then
            return true
        end
    end
    return false
end

--luacheck: skip
function progress_ipairs(vector, desc, interval)
    desc = desc or 'item'
    interval = interval or 10000
    local cb = ipairs(vector)
    return function(vector, k, ...)
        if k and k > 0 and k % interval == 0 then
            print(('        %s %i/%i (%0.f%%)'):format(desc, k, #vector, k * 100 / #vector))
        end
        return cb(vector, k)
    end, vector, nil
end

-- wrapper that returns "unknown N" for df.enum_type[BAD_VALUE],
-- instead of returning nil or causing an error
local df_enums = {} --as:df
setmetatable(df_enums, {
    __index = function(self, enum)
        if not df[enum] or df[enum]._kind ~= 'enum-type' then
            error('invalid enum: ' .. enum)
        end
        local t = {}
        setmetatable(t, {
            __index = function(self, k)
                return df[enum][k] or 'unknown ' .. k
            end
        })
        return t
    end,
    __newindex = function() error('read-only') end
})

--create an extra legends xml with extra data, by Mason11987 for World Viewer
function export_more_legends_xml()
    local month = dfhack.world.ReadCurrentMonth() + 1 --days and months are 1-indexed
    local day = dfhack.world.ReadCurrentDay()
    local year_str = string.format('%0'..math.max(5, string.len(''..df.global.cur_year))..'d', df.global.cur_year)
    local date_str = year_str..string.format('-%02d-%02d', month, day)

    local filename = df.global.world.cur_savegame.save_dir.."-"..date_str.."-legends_plus.xml"
    local file = io.open(filename, 'w')
    if not file then qerror("could not open file: " .. filename) end

    file:write("<?xml version=\"1.0\" encoding='UTF-8'?>\n")
    file:write("<df_world>\n")
    file:write("<name>"..dfhack.df2utf(dfhack.TranslateName(df.global.world.world_data.name)).."</name>\n")
    file:write("<altname>"..dfhack.df2utf(dfhack.TranslateName(df.global.world.world_data.name,1)).."</altname>\n")

    file:write("<landmasses>\n")
    for landmassK, landmassV in progress_ipairs(df.global.world.world_data.landmasses, 'landmass') do
        file:write("\t<landmass>\n")
        file:write("\t\t<id>"..landmassV.index.."</id>\n")
        file:write("\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(landmassV.name,1)).."</name>\n")
        file:write("\t\t<coord_1>"..landmassV.min_x..","..landmassV.min_y.."</coord_1>\n")
        file:write("\t\t<coord_2>"..landmassV.max_x..","..landmassV.max_y.."</coord_2>\n")
        file:write("\t</landmass>\n")
    end
    file:write("</landmasses>\n")

    file:write("<mountain_peaks>\n")
    for mountainK, mountainV in progress_ipairs(df.global.world.world_data.mountain_peaks, 'mountain') do
        file:write("\t<mountain_peak>\n")
        file:write("\t\t<id>"..mountainK.."</id>\n")
        file:write("\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(mountainV.name,1)).."</name>\n")
        file:write("\t\t<coords>"..mountainV.pos.x..","..mountainV.pos.y.."</coords>\n")
        file:write("\t\t<height>"..mountainV.height.."</height>\n")
        file:write("\t</mountain_peak>\n")
    end
    file:write("</mountain_peaks>\n")

    file:write("<regions>\n")
    for regionK, regionV in progress_ipairs(df.global.world.world_data.regions, 'region') do
        file:write("\t<region>\n")
        file:write("\t\t<id>"..regionV.index.."</id>\n")
        file:write("\t\t<coords>")
            for xK, xVal in ipairs(regionV.region_coords.x) do
                file:write(xVal..","..regionV.region_coords.y[xK].."|")
            end
        file:write("</coords>\n")
        file:write("\t</region>\n")
    end
    file:write("</regions>\n")

    file:write("<underground_regions>\n")
    for regionK, regionV in progress_ipairs(df.global.world.world_data.underground_regions, 'underground region') do
        file:write("\t<underground_region>\n")
        file:write("\t\t<id>"..regionV.index.."</id>\n")
        file:write("\t\t<coords>")
            for xK, xVal in ipairs(regionV.region_coords.x) do
                file:write(xVal..","..regionV.region_coords.y[xK].."|")
            end
        file:write("</coords>\n")
        file:write("\t</underground_region>\n")
    end
    file:write("</underground_regions>\n")

    file:write("<sites>\n")
    for siteK, siteV in progress_ipairs(df.global.world.world_data.sites, 'site') do
        file:write("\t<site>\n")
        for k,v in pairs(siteV) do
            if (k == "id" or k == "civ_id" or k == "cur_owner_id") then
                file:write("\t\t<"..k..">"..tostring(v).."</"..k..">\n")
            elseif (k == "buildings") then
                if (#siteV.buildings > 0) then
                    file:write("\t\t<structures>\n")
                    for buildingK, buildingV in ipairs(siteV.buildings) do
                        file:write("\t\t\t<structure>\n")
                        file:write("\t\t\t\t<id>"..buildingV.id.."</id>\n")
                        file:write("\t\t\t\t<type>"..df_enums.abstract_building_type[buildingV:getType()]:lower().."</type>\n")
                        if table.containskey(buildingV,"name") then
                            file:write("\t\t\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(buildingV.name, 1)).."</name>\n")
                            file:write("\t\t\t\t<name2>"..dfhack.df2utf(dfhack.TranslateName(buildingV.name)).."</name2>\n")
                        end
                        if df.abstract_building_templest:is_instance(buildingV) then
                            file:write("\t\t\t\t<deity>"..buildingV.deity.."</deity>\n")
                            file:write("\t\t\t\t<religion>"..buildingV.religion.."</religion>\n")
                        end
                        if df.abstract_building_dungeonst:is_instance(buildingV) then
                            file:write("\t\t\t\t<dungeon_type>"..buildingV.dungeon_type.."</dungeon_type>\n")
                        end
                        for inhabitabntK,inhabitabntV in pairs(buildingV.inhabitants) do
                            file:write("\t\t\t\t<inhabitant>"..inhabitabntV.histfig_id.."</inhabitant>\n")
                        end
                        file:write("\t\t\t</structure>\n")
                    end
                    file:write("\t\t</structures>\n")
                end
            end
        end
        file:write("\t</site>\n")
    end
    file:write("</sites>\n")

    file:write("<world_constructions>\n")
    for wcK, wcV in progress_ipairs(df.global.world.world_data.constructions.list, 'construction') do
        file:write("\t<world_construction>\n")
        file:write("\t\t<id>"..wcV.id.."</id>\n")
        file:write("\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(wcV.name,1)).."</name>\n")
        file:write("\t\t<type>"..(df_enums.world_construction_type[wcV:getType()]):lower().."</type>\n")
        file:write("\t\t<coords>")
        for xK, xVal in ipairs(wcV.square_pos.x) do
            file:write(xVal..","..wcV.square_pos.y[xK].."|")
        end
        file:write("</coords>\n")
        file:write("\t</world_construction>\n")
    end
    file:write("</world_constructions>\n")

    file:write("<artifacts>\n")
    for artifactK, artifactV in progress_ipairs(df.global.world.artifacts.all, 'artifact') do
        file:write("\t<artifact>\n")
        file:write("\t\t<id>"..artifactV.id.."</id>\n")
        local item = artifactV.item
        if df.item_constructed:is_instance(item) then
            file:write("\t\t<item_type>"..tostring(df_enums.item_type[item:getType()]):lower().."</item_type>\n")
            if (item:getSubtype() ~= -1) then --luacheck: skip
                file:write("\t\t<item_subtype>"..item.subtype.name.."</item_subtype>\n")
            end
            for improvementK,impovementV in pairs(item.improvements) do
                if df.itemimprovement_writingst:is_instance(impovementV) then
                    for writingk,writingV in pairs(impovementV.contents) do
                        file:write("\t\t<writing>"..writingV.."</writing>\n")
                    end
                elseif df.itemimprovement_pagesst:is_instance(impovementV) then
                    file:write("\t\t<page_count>"..impovementV.count.."</page_count>\n")
                    for writingk,writingV in pairs(impovementV.contents) do
                        file:write("\t\t<writing>"..writingV.."</writing>\n")
                    end
                end
            end
        end
        if (table.containskey(item,"description")) then
            file:write("\t\t<item_description>"..dfhack.df2utf(item.description:lower()).."</item_description>\n")
        end
        if item:getMaterial() ~= -1 then
            file:write("\t\t<mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(item:getMaterial(), item:getMaterialIndex())).."</mat>\n")
        end
        file:write("\t</artifact>\n")
    end
    file:write("</artifacts>\n")

    file:write("<historical_figures>\n")
    for hfK, hfV in progress_ipairs(df.global.world.history.figures, 'historical figure') do
        file:write("\t<historical_figure>\n")
        file:write("\t\t<id>"..hfV.id.."</id>\n")
        file:write("\t\t<sex>"..hfV.sex.."</sex>\n")
        if hfV.race >= 0 then file:write("\t\t<race>"..df.global.world.raws.creatures.all[hfV.race].name[0].."</race>\n") end
        file:write("\t</historical_figure>\n")
    end
    file:write("</historical_figures>\n")

    file:write("<entity_populations>\n")
    for entityPopK, entityPopV in progress_ipairs(df.global.world.entity_populations, 'entity population') do
        file:write("\t<entity_population>\n")
        file:write("\t\t<id>"..entityPopV.id.."</id>\n")
        for raceK, raceV in ipairs(entityPopV.races) do
            local raceName = (df.global.world.raws.creatures.all[raceV].creature_id):lower()
            file:write("\t\t<race>"..raceName..":"..entityPopV.counts[raceK].."</race>\n")
        end
        file:write("\t\t<civ_id>"..entityPopV.civ_id.."</civ_id>\n")
        file:write("\t</entity_population>\n")
    end
    file:write("</entity_populations>\n")

    file:write("<entities>\n")
    for entityK, entityV in progress_ipairs(df.global.world.entities.all, 'entity') do
        file:write("\t<entity>\n")
        file:write("\t\t<id>"..entityV.id.."</id>\n")
        if entityV.race >= 0 then
            file:write("\t\t<race>"..(df.global.world.raws.creatures.all[entityV.race].creature_id):lower().."</race>\n")
        end
        file:write("\t\t<type>"..(df_enums.historical_entity_type[entityV.type]):lower().."</type>\n")
        if entityV.type == df.historical_entity_type.Religion then -- Get worshipped figure
            if (entityV.unknown1b ~= nil and entityV.unknown1b.worship ~= nil) then
                for k,v in pairs(entityV.unknown1b.worship) do
                    file:write("\t\t<worship_id>"..v.."</worship_id>\n")
                end
            end
        end
        for id, link in pairs(entityV.entity_links) do
            file:write("\t\t<entity_link>\n")
                for k, v in pairs(link) do
                    if (k == "type") then
                        file:write("\t\t\t<"..k..">"..tostring(df_enums.entity_entity_link_type[v]).."</"..k..">\n")
                    else
                        file:write("\t\t\t<"..k..">"..v.."</"..k..">\n")
                    end
                end
            file:write("\t\t</entity_link>\n")
        end
        for positionK,positionV in pairs(entityV.positions.own) do
            file:write("\t\t<entity_position>\n")
            file:write("\t\t\t<id>"..positionV.id.."</id>\n")
            if positionV.name[0]          ~= "" then file:write("\t\t\t<name>"..positionV.name[0].."</name>\n") end
            if positionV.name_male[0]     ~= "" then file:write("\t\t\t<name_male>"..positionV.name_male[0].."</name_male>\n") end
            if positionV.name_female[0]   ~= "" then file:write("\t\t\t<name_female>"..positionV.name_female[0].."</name_female>\n") end
            if positionV.spouse[0]        ~= "" then file:write("\t\t\t<spouse>"..positionV.spouse[0].."</spouse>\n") end
            if positionV.spouse_male[0]   ~= "" then file:write("\t\t\t<spouse_male>"..positionV.spouse_male[0].."</spouse_male>\n") end
            if positionV.spouse_female[0] ~= "" then file:write("\t\t\t<spouse_female>"..positionV.spouse_female[0].."</spouse_female>\n") end
            file:write("\t\t</entity_position>\n")
        end
        for assignmentK,assignmentV in pairs(entityV.positions.assignments) do
            file:write("\t\t<entity_position_assignment>\n")
            for k, v in pairs(assignmentV) do
                if (k == "id" or k == "histfig" or k == "position_id" or k == "squad_id") then
                    file:write("\t\t\t<"..k..">"..v.."</"..k..">\n")
                end
            end
            file:write("\t\t</entity_position_assignment>\n")
        end
        for idx,id in pairs(entityV.histfig_ids) do
            file:write("\t\t<histfig_id>"..id.."</histfig_id>\n")
        end
        for id, link in ipairs(entityV.children) do
            file:write("\t\t<child>"..link.."</child>\n")
        end

        file:write("\t\t<claims>")
        for xK, xVal in ipairs(entityV.claims.border.x) do
            file:write(xVal..","..entityV.claims.border.y[xK].."|")
        end
        file:write("\t\t</claims>\n")

        if (table.containskey(entityV,"occasion_info") and entityV.occasion_info ~= nil) then
            for occasionK, occasionV in pairs(entityV.occasion_info.occasions) do
                file:write("\t\t<occasion>\n")
                file:write("\t\t\t<id>"..occasionV.id.."</id>\n")
                file:write("\t\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(occasionV.name,1)).."</name>\n")
                file:write("\t\t\t<event>"..occasionV.event.."</event>\n")
                for scheduleK, scheduleV in pairs(occasionV.schedule) do
                    file:write("\t\t\t<schedule>\n")
                    file:write("\t\t\t\t<id>"..scheduleK.."</id>\n")
                    file:write("\t\t\t\t<type>"..df_enums.occasion_schedule_type[scheduleV.type]:lower().."</type>\n")
                    if(scheduleV.type == df.occasion_schedule_type.THROWING_COMPETITION) then
                        file:write("\t\t\t\t<item_type>"..df_enums.item_type[scheduleV.reference]:lower().."</item_type>\n")
                        file:write("\t\t\t\t<item_subtype>"..getItemSubTypeName(scheduleV.reference,scheduleV.reference2).."</item_subtype>\n")
                    else
                        file:write("\t\t\t\t<reference>"..scheduleV.reference.."</reference>\n")
                        file:write("\t\t\t\t<reference2>"..scheduleV.reference2.."</reference2>\n")
                    end
                    for featureK, featureV in pairs(scheduleV.features) do
                        file:write("\t\t\t\t<feature>\n")
                        if(df_enums.occasion_schedule_feature[featureV.feature] ~= nil) then
                            file:write("\t\t\t\t\t<type>"..df_enums.occasion_schedule_feature[featureV.feature]:lower().."</type>\n")
                        else
                            file:write("\t\t\t\t\t<type>"..featureV.feature.."</type>\n")
                        end
                        file:write("\t\t\t\t\t<reference>"..featureV.reference.."</reference>\n")
                        file:write("\t\t\t\t</feature>\n")
                    end
                    file:write("\t\t\t</schedule>\n")
                end
                file:write("\t\t</occasion>\n")
            end
        end
        file:write("\t</entity>\n")
    end
    file:write("</entities>\n")

    file:write("<historical_events>\n")
    for ID, event in progress_ipairs(df.global.world.history.events, 'event') do
        if df.history_event_add_hf_entity_linkst:is_instance(event)
              or df.history_event_add_hf_site_linkst:is_instance(event)
              or df.history_event_add_hf_hf_linkst:is_instance(event)
              or df.history_event_add_hf_entity_linkst:is_instance(event)
              or df.history_event_topicagreement_concludedst:is_instance(event)
              or df.history_event_topicagreement_rejectedst:is_instance(event)
              or df.history_event_topicagreement_madest:is_instance(event)
              or df.history_event_body_abusedst:is_instance(event)
              or df.history_event_change_creature_typest:is_instance(event)
              or df.history_event_change_hf_jobst:is_instance(event)
              or df.history_event_change_hf_statest:is_instance(event)
              or df.history_event_created_buildingst:is_instance(event)
              or df.history_event_creature_devouredst:is_instance(event)
              or df.history_event_hf_does_interactionst:is_instance(event)
              or df.history_event_hf_learns_secretst:is_instance(event)
              or df.history_event_hist_figure_new_petst:is_instance(event)
              or df.history_event_hist_figure_reach_summitst:is_instance(event)
              or df.history_event_item_stolenst:is_instance(event)
              or df.history_event_remove_hf_entity_linkst:is_instance(event)
              or df.history_event_remove_hf_site_linkst:is_instance(event)
              or df.history_event_replaced_buildingst:is_instance(event)
              or df.history_event_masterpiece_created_arch_designst:is_instance(event)
              or df.history_event_masterpiece_created_dye_itemst:is_instance(event)
              or df.history_event_masterpiece_created_arch_constructst:is_instance(event)
              or df.history_event_masterpiece_created_itemst:is_instance(event)
              or df.history_event_masterpiece_created_item_improvementst:is_instance(event)
              or df.history_event_masterpiece_created_foodst:is_instance(event)
              or df.history_event_masterpiece_created_engravingst:is_instance(event)
              or df.history_event_masterpiece_lostst:is_instance(event)
              or df.history_event_entity_actionst:is_instance(event)
              or df.history_event_hf_act_on_buildingst:is_instance(event)
              or df.history_event_artifact_createdst:is_instance(event)
              or df.history_event_assume_identityst:is_instance(event)
              or df.history_event_create_entity_positionst:is_instance(event)
              or df.history_event_diplomat_lostst:is_instance(event)
              or df.history_event_merchantst:is_instance(event)
              or df.history_event_war_peace_acceptedst:is_instance(event)
              or df.history_event_war_peace_rejectedst:is_instance(event)
              or df.history_event_hist_figure_woundedst:is_instance(event)
              or df.history_event_hist_figure_diedst:is_instance(event)
                then
            file:write("\t<historical_event>\n")
            file:write("\t\t<id>"..event.id.."</id>\n")
            file:write("\t\t<type>"..tostring(df_enums.history_event_type[event:getType()]):lower().."</type>\n")
            for k,v in pairs(event) do
                if k == "year" or k == "seconds" or k == "flags" or k == "id"
                    or (k == "region" and not df.history_event_hf_does_interactionst:is_instance(event))
                    or k == "region_pos" or k == "layer" or k == "feature_layer" or k == "subregion"
                    or k == "anon_1" or k == "anon_2" or k == "flags2" or k == "unk1" then

                elseif df.history_event_add_hf_entity_linkst:is_instance(event) and k == "link_type" then
                    file:write("\t\t<"..k..">"..df_enums.histfig_entity_link_type[v]:lower().."</"..k..">\n")
                elseif df.history_event_add_hf_entity_linkst:is_instance(event) and k == "position_id" then
                    local entity = df.historical_entity.find(event.civ)
                    if (entity ~= nil and event.civ > -1 and v > -1) then
                        for entitypositionsK, entityPositionsV in ipairs(entity.positions.own) do
                            if entityPositionsV.id == v then
                                file:write("\t\t<position>"..tostring(entityPositionsV.name[0]):lower().."</position>\n")
                                break
                            end
                        end
                    else
                        file:write("\t\t<position>-1</position>\n")
                    end
                elseif df.history_event_create_entity_positionst:is_instance(event) and k == "position" then
                    local entity = df.historical_entity.find(event.site_civ)
                    if (entity ~= nil and v > -1) then
                        for entitypositionsK, entityPositionsV in ipairs(entity.positions.own) do
                            if entityPositionsV.id == v then
                                file:write("\t\t<position>"..tostring(entityPositionsV.name[0]):lower().."</position>\n")
                                break
                            end
                        end
                    else
                        file:write("\t\t<position>-1</position>\n")
                    end
                elseif df.history_event_remove_hf_entity_linkst:is_instance(event) and k == "link_type" then
                    file:write("\t\t<"..k..">"..df_enums.histfig_entity_link_type[v]:lower().."</"..k..">\n")
                elseif df.history_event_remove_hf_entity_linkst:is_instance(event) and k == "position_id" then
                    local entity = df.historical_entity.find(event.civ)
                    if (entity ~= nil and event.civ > -1 and v > -1) then
                        for entitypositionsK, entityPositionsV in ipairs(entity.positions.own) do
                            if entityPositionsV.id == v then
                                file:write("\t\t<position>"..tostring(entityPositionsV.name[0]):lower().."</position>\n")
                                break
                            end
                        end
                    else
                        file:write("\t\t<position>-1</position>\n")
                    end
                elseif df.history_event_add_hf_hf_linkst:is_instance(event) and k == "type" then
                    file:write("\t\t<link_type>"..df_enums.histfig_hf_link_type[v]:lower().."</link_type>\n")
                elseif df.history_event_add_hf_site_linkst:is_instance(event) and k == "type" then
                    file:write("\t\t<link_type>"..df_enums.histfig_site_link_type[v]:lower().."</link_type>\n")
                elseif df.history_event_remove_hf_site_linkst:is_instance(event) and k == "type" then
                    file:write("\t\t<link_type>"..df_enums.histfig_site_link_type[v]:lower().."</link_type>\n")
                elseif (df.history_event_item_stolenst:is_instance(event) or
                        df.history_event_masterpiece_created_itemst:is_instance(event) or
                        df.history_event_masterpiece_created_item_improvementst:is_instance(event) or
                        df.history_event_masterpiece_created_dye_itemst:is_instance(event)
                        ) and k == "item_type" then
                    file:write("\t\t<item_type>"..df_enums.item_type[v]:lower().."</item_type>\n")
                elseif (df.history_event_item_stolenst:is_instance(event) or
                        df.history_event_masterpiece_created_itemst:is_instance(event) or
                        df.history_event_masterpiece_created_item_improvementst:is_instance(event) or
                        df.history_event_masterpiece_created_dye_itemst:is_instance(event)
                        ) and k == "item_subtype" then
                    --if event.item_type > -1 and v > -1 then
                        file:write("\t\t<"..k..">"..getItemSubTypeName(event.item_type,v).."</"..k..">\n")
                    --end
                    elseif df.history_event_masterpiece_created_foodst:is_instance(event) and k == "item_subtype" then
                        --if event.item_type > -1 and v > -1 then
                            file:write("\t\t<item_type>food</item_type>\n")
                            file:write("\t\t<"..k..">"..getItemSubTypeName(df.item_type.FOOD,v).."</"..k..">\n")
                        --end
                elseif df.history_event_item_stolenst:is_instance(event) and k == "mattype" then
                    if (v > -1) then
                        if (dfhack.matinfo.decode(event.mattype, event.matindex) == nil) then
                            file:write("\t\t<mattype>"..event.mattype.."</mattype>\n")
                            file:write("\t\t<matindex>"..event.matindex.."</matindex>\n")
                        else
                            file:write("\t\t<mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.mattype, event.matindex)).."</mat>\n")
                        end
                    end
                elseif (df.history_event_masterpiece_created_itemst:is_instance(event) or
                        df.history_event_masterpiece_created_item_improvementst:is_instance(event) or
                        df.history_event_masterpiece_created_foodst:is_instance(event) or
                        df.history_event_masterpiece_created_dye_itemst:is_instance(event)
                        ) and k == "mat_type" then
                    if (v > -1) then
                        if (dfhack.matinfo.decode(event.mat_type, event.mat_index) == nil) then
                            file:write("\t\t<mat_type>"..event.mat_type.."</mat_type>\n")
                            file:write("\t\t<mat_index>"..event.mat_index.."</mat_index>\n")
                        else
                            file:write("\t\t<mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.mat_type, event.mat_index)).."</mat>\n")
                        end
                    end
                elseif df.history_event_masterpiece_created_item_improvementst:is_instance(event) and k == "imp_mat_type" then
                    if (v > -1) then
                        if (dfhack.matinfo.decode(event.imp_mat_type, event.imp_mat_index) == nil) then
                            file:write("\t\t<imp_mat_type>"..event.imp_mat_type.."</imp_mat_type>\n")
                            file:write("\t\t<imp_mat_index>"..event.imp_mat_index.."</imp_mat_index>\n")
                        else
                            file:write("\t\t<imp_mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.imp_mat_type, event.imp_mat_index)).."</imp_mat>\n")
                        end
                    end
                elseif df.history_event_masterpiece_created_dye_itemst:is_instance(event) and k == "dye_mat_type" then
                    if (v > -1) then
                        if (dfhack.matinfo.decode(event.dye_mat_type, event.dye_mat_index) == nil) then
                            file:write("\t\t<dye_mat_type>"..event.dye_mat_type.."</dye_mat_type>\n")
                            file:write("\t\t<dye_mat_index>"..event.dye_mat_index.."</dye_mat_index>\n")
                        else
                            file:write("\t\t<dye_mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.dye_mat_type, event.dye_mat_index)).."</dye_mat>\n")
                        end
                    end

                elseif df.history_event_item_stolenst:is_instance(event) and k == "matindex" then
                    --skip
                elseif df.history_event_item_stolenst:is_instance(event) and k == "item" and v == -1 then
                    --skip
                elseif (df.history_event_masterpiece_created_itemst:is_instance(event) or
                        df.history_event_masterpiece_created_item_improvementst:is_instance(event)
                        ) and k == "mat_index" then
                    --skip
                elseif df.history_event_masterpiece_created_item_improvementst:is_instance(event) and k == "imp_mat_index" then
                    --skip
                elseif (df.history_event_war_peace_acceptedst:is_instance(event) or
                        df.history_event_war_peace_rejectedst:is_instance(event) or
                        df.history_event_topicagreement_concludedst:is_instance(event) or
                        df.history_event_topicagreement_rejectedst:is_instance(event) or
                        df.history_event_topicagreement_madest:is_instance(event)
                        ) and k == "topic" then
                    file:write("\t\t<topic>"..tostring(df_enums.meeting_topic[v]):lower().."</topic>\n")
                elseif df.history_event_masterpiece_created_item_improvementst:is_instance(event) and k == "improvement_type" then
                    file:write("\t\t<improvement_type>"..df_enums.improvement_type[v]:lower().."</improvement_type>\n")
                elseif ((df.history_event_hist_figure_reach_summitst:is_instance(event) and k == "group")
                     or (df.history_event_hist_figure_new_petst:is_instance(event) and k == "group")
                     or (df.history_event_body_abusedst:is_instance(event) and k == "bodies")) then
                    for detailK,detailV in pairs(v) do
                        file:write("\t\t<"..k..">"..detailV.."</"..k..">\n")
                    end
                elseif  df.history_event_hist_figure_new_petst:is_instance(event) and k == "pets" then
                    for detailK,detailV in pairs(v) do
                        file:write("\t\t<"..k..">"..df.global.world.raws.creatures.all[detailV].name[0].."</"..k..">\n")
                    end
                elseif df.history_event_body_abusedst:is_instance(event) and (k == "props") then
                    file:write("\t\t<props_item_type>"..tostring(df_enums.item_type[event.props.item.item_type]):lower().."</props_item_type>\n")
                    file:write("\t\t<props_item_subtype>"..getItemSubTypeName(event.props.item.item_type,event.props.item.item_subtype).."</props_item_subtype>\n")
                    if (event.props.item.mat_type > -1) then
                        if (dfhack.matinfo.decode(event.props.item.mat_type, event.props.item.mat_index) == nil) then
                            file:write("\t\t<props_item_mat_type>"..event.props.item.mat_type.."</props_item_mat_type>\n")
                            file:write("\t\t<props_item_mat_index>"..event.props.item.mat_index.."</props_item_mat_index>\n")
                        else
                            file:write("\t\t<props_item_mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.props.item.mat_type, event.props.item.mat_index)).."</props_item_mat>\n")
                        end
                    end
                    --file:write("\t\t<"..k.."_item_mat_type>"..tostring(event.props.item.mat_type).."</"..k.."_item_mat_index>\n")
                    --file:write("\t\t<"..k.."_item_mat_index>"..tostring(event.props.item.mat_index).."</"..k.."_item_mat_index>\n")
                    file:write("\t\t<"..k.."_pile_type>"..tostring(event.props.pile_type).."</"..k.."_pile_type>\n")
                elseif df.history_event_assume_identityst:is_instance(event) and k == "identity" then
                    if (table.contains(df.global.world.identities.all,v)) then
                        if (df.global.world.identities.all[v].histfig_id == -1) then
                            local thisIdentity = df.global.world.identities.all[v]
                            file:write("\t\t<identity_name>"..thisIdentity.name.first_name.."</identity_name>\n")
                            file:write("\t\t<identity_race>"..(df.global.world.raws.creatures.all[thisIdentity.race].creature_id):lower().."</identity_race>\n")
                            file:write("\t\t<identity_caste>"..(df.global.world.raws.creatures.all[thisIdentity.race].caste[thisIdentity.caste].caste_id):lower().."</identity_caste>\n")
                        else
                            file:write("\t\t<identity_hf>"..df.global.world.identities.all[v].histfig_id.."</identity_hf>\n")
                        end
                    end
                elseif df.history_event_masterpiece_created_arch_constructst:is_instance(event) and k == "building_type" then
                    file:write("\t\t<building_type>"..df_enums.building_type[v]:lower().."</building_type>\n")
                elseif df.history_event_masterpiece_created_arch_constructst:is_instance(event) and k == "building_subtype" then
                    if (df_enums.building_type[event.building_type]:lower() == "furnace") then
                        file:write("\t\t<building_subtype>"..df_enums.furnace_type[v]:lower().."</building_subtype>\n")
                    elseif v > -1 then
                        file:write("\t\t<building_subtype>"..tostring(v).."</building_subtype>\n")
                    end
                elseif k == "race" then
                    if v > -1 then
                        file:write("\t\t<race>"..df.global.world.raws.creatures.all[v].name[0].."</race>\n")
                    end
                elseif k == "caste" then
                    if v > -1 then
                        file:write("\t\t<caste>"..(df.global.world.raws.creatures.all[event.race].caste[v].caste_id):lower().."</caste>\n")
                    end
                elseif k == "interaction" and df.history_event_hf_does_interactionst:is_instance(event) then
                    file:write("\t\t<interaction_action>"..df.global.world.raws.interactions[v].str[3].value.."</interaction_action>\n")
                    file:write("\t\t<interaction_string>"..df.global.world.raws.interactions[v].str[4].value.."</interaction_string>\n")
                elseif k == "interaction" and df.history_event_hf_learns_secretst:is_instance(event) then
                    file:write("\t\t<secret_text>"..df.global.world.raws.interactions[v].str[2].value.."</secret_text>\n")
                elseif df.history_event_hist_figure_diedst:is_instance(event) and k == "weapon" then
                    for detailK,detailV in pairs(v) do
                        if (detailK == "item") then
                            if detailV > -1 then
                                file:write("\t\t<"..detailK..">"..detailV.."</"..detailK..">\n")
                                local thisItem = df.item.find(detailV)
                                if (thisItem ~= nil) then
                                    if (thisItem.flags.artifact == true) then
                                        for refk,refv in pairs(thisItem.general_refs) do
                                            if (df.general_ref_is_artifactst:is_instance(refv)) then
                                                file:write("\t\t<artifact_id>"..refv.artifact_id.."</artifact_id>\n")
                                                break
                                            end
                                        end
                                    end
                                end

                            end
                        elseif (detailK == "item_type") then
                            if event.weapon.item > -1 then
                                file:write("\t\t<"..detailK..">"..tostring(df_enums.item_type[detailV]):lower().."</"..detailK..">\n")
                            end
                        elseif (detailK == "item_subtype") then
                            if event.weapon.item > -1 and detailV > -1 then
                                file:write("\t\t<"..detailK..">"..getItemSubTypeName(event.weapon.item_type,detailV).."</"..detailK..">\n")
                            end
                        elseif (detailK == "mattype") then
                            if (detailV > -1) then
                                file:write("\t\t<mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.weapon.mattype, event.weapon.matindex)).."</mat>\n")
                            end
                        elseif (detailK == "matindex") then

                        elseif (detailK == "shooter_item") then
                            if detailV > -1 then
                                file:write("\t\t<"..detailK..">"..detailV.."</"..detailK..">\n")
                                local thisItem = df.item.find(detailV)
                                if  thisItem ~= nil then
                                    if (thisItem.flags.artifact == true) then
                                        for refk,refv in pairs(thisItem.general_refs) do
                                            if (df.general_ref_is_artifactst:is_instance(refv)) then
                                                file:write("\t\t<shooter_artifact_id>"..refv.artifact_id.."</shooter_artifact_id>\n")
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        elseif (detailK == "shooter_item_type") then
                            if event.weapon.shooter_item > -1 then
                                file:write("\t\t<"..detailK..">"..tostring(df_enums.item_type[detailV]):lower().."</"..detailK..">\n")
                            end
                        elseif (detailK == "shooter_item_subtype") then
                            if event.weapon.shooter_item > -1 and detailV > -1 then
                                file:write("\t\t<"..detailK..">"..getItemSubTypeName(event.weapon.shooter_item_type,detailV).."</"..detailK..">\n")
                            end
                        elseif (detailK == "shooter_mattype") then
                            if (detailV > -1) then
                                file:write("\t\t<shooter_mat>"..dfhack.matinfo.toString(dfhack.matinfo.decode(event.weapon.shooter_mattype, event.weapon.shooter_matindex)).."</shooter_mat>\n")
                            end
                        elseif (detailK == "shooter_matindex") then
                            --skip
                        elseif detailK == "slayer_race" or detailK == "slayer_caste" then
                            --skip
                        else
                            file:write("\t\t<"..detailK..">"..detailV.."</"..detailK..">\n")
                        end
                    end
                elseif df.history_event_hist_figure_diedst:is_instance(event) and k == "death_cause" then
                    file:write("\t\t<"..k..">"..df_enums.death_type[v]:lower().."</"..k..">\n")
                elseif df.history_event_change_hf_jobst:is_instance(event) and (k == "new_job" or k == "old_job") then
                    file:write("\t\t<"..k..">"..df_enums.profession[v]:lower().."</"..k..">\n")
                elseif df.history_event_change_creature_typest:is_instance(event) and (k == "old_race" or k == "new_race")  and v >= 0 then
                    file:write("\t\t<"..k..">"..df.global.world.raws.creatures.all[v].name[0].."</"..k..">\n")
                else
                    file:write("\t\t<"..k..">"..tostring(v).."</"..k..">\n")
                end
            end
            file:write("\t</historical_event>\n")
        end
    end
    file:write("</historical_events>\n")
    file:write("<historical_event_collections>\n")
    file:write("</historical_event_collections>\n")
    file:write("<historical_eras>\n")
    file:write("</historical_eras>\n")

    file:write("<written_contents>\n")
    for wcK, wcV in progress_ipairs(df.global.world.written_contents.all) do
        file:write("\t<written_content>\n")
        file:write("\t\t<id>"..wcV.id.."</id>\n")
        file:write("\t\t<title>"..wcV.title.."</title>\n")
        file:write("\t\t<page_start>"..wcV.page_start.."</page_start>\n")
        file:write("\t\t<page_end>"..wcV.page_end.."</page_end>\n")
        for refK, refV in pairs(wcV.refs) do
            file:write("\t\t<reference>\n")
            file:write("\t\t\t<type>"..df_enums.general_ref_type[refV:getType()].."</type>\n")
            if df.general_ref_artifact:is_instance(refV) then file:write("\t\t\t<id>"..refV.artifact_id.."</id>\n") -- artifact
            elseif df.general_ref_entity:is_instance(refV) then file:write("\t\t\t<id>"..refV.entity_id.."</id>\n") -- entity
            elseif df.general_ref_historical_eventst:is_instance(refV) then file:write("\t\t\t<id>"..refV.event_id.."</id>\n") -- event
            elseif df.general_ref_sitest:is_instance(refV) then file:write("\t\t\t<id>"..refV.site_id.."</id>\n") -- site
            elseif df.general_ref_subregionst:is_instance(refV) then file:write("\t\t\t<id>"..refV.region_id.."</id>\n") -- region
            elseif df.general_ref_historical_figurest:is_instance(refV) then file:write("\t\t\t<id>"..refV.hist_figure_id.."</id>\n") -- hist figure
            elseif df.general_ref_written_contentst:is_instance(refV) then file:write("\t\t\t<id>"..refV.written_content_id.."</id>\n")
            elseif df.general_ref_poetic_formst:is_instance(refV) then file:write("\t\t\t<id>"..refV.poetic_form_id.."</id>\n") -- poetic form
            elseif df.general_ref_musical_formst:is_instance(refV) then file:write("\t\t\t<id>"..refV.musical_form_id.."</id>\n") -- musical form
            elseif df.general_ref_dance_formst:is_instance(refV) then file:write("\t\t\t<id>"..refV.dance_form_id.."</id>\n") -- dance form
            elseif df.general_ref_interactionst:is_instance(refV) then -- TODO INTERACTION
            elseif df.general_ref_knowledge_scholar_flagst:is_instance(refV) then -- TODO KNOWLEDGE_SCHOLAR_FLAG
            elseif df.general_ref_value_levelst:is_instance(refV) then -- TODO VALUE_LEVEL
            elseif df.general_ref_languagest:is_instance(refV) then -- TODO LANGUAGE
            elseif df.general_ref_abstract_buildingst:is_instance(refV) then -- TODO ABSTRACT_BUILDING
            else
                print("unknown reference",refV:getType(),df_enums.general_ref_type[refV:getType()])
                --for k,v in pairs(refV) do print(k,v) end
            end
            file:write("\t\t</reference>\n")
        end
        file:write("\t\t<type>"..(df_enums.written_content_type[wcV.type] or wcV.type).."</type>\n")
        for styleK, styleV in pairs(wcV.styles) do
            file:write("\t\t<style>"..(df_enums.written_content_style[styleV] or styleV).."</style>\n")
        end
        file:write("\t\t<author>"..wcV.author.."</author>\n")
        file:write("\t</written_content>\n")
    end
    file:write("</written_contents>\n")

    file:write("<poetic_forms>\n")
    for formK, formV in progress_ipairs(df.global.world.poetic_forms.all, 'poetic form') do
        file:write("\t<poetic_form>\n")
        file:write("\t\t<id>"..formV.id.."</id>\n")
        file:write("\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(formV.name,1)).."</name>\n")
        file:write("\t</poetic_form>\n")
    end
    file:write("</poetic_forms>\n")

    file:write("<musical_forms>\n")
    for formK, formV in progress_ipairs(df.global.world.musical_forms.all, 'musical form') do
        file:write("\t<musical_form>\n")
        file:write("\t\t<id>"..formV.id.."</id>\n")
        file:write("\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(formV.name,1)).."</name>\n")
        file:write("\t</musical_form>\n")
    end
    file:write("</musical_forms>\n")

    file:write("<dance_forms>\n")
    for formK, formV in progress_ipairs(df.global.world.dance_forms.all, 'dance form') do
        file:write("\t<dance_form>\n")
        file:write("\t\t<id>"..formV.id.."</id>\n")
        file:write("\t\t<name>"..dfhack.df2utf(dfhack.TranslateName(formV.name,1)).."</name>\n")
        file:write("\t</dance_form>\n")
    end
    file:write("</dance_forms>\n")

    file:write("</df_world>\n")
    file:close()
end

-- export information and XML ('p, x')
function export_legends_info()
    print('    Exporting:  World map/gen info')
    gui.simulateInput(vs, 'LEGENDS_EXPORT_MAP')
    print('    Exporting:  Legends xml')
    gui.simulateInput(vs, 'LEGENDS_EXPORT_XML')
    print("    Exporting:  Extra legends_plus xml")
    export_more_legends_xml()
end

function export_detailed_maps()
    script.start(function()
        for i = 1, #MAPS do
            local vs = dfhack.gui.getViewscreenByType(df.viewscreen_export_graphical_mapst, 0)
            if not vs then
                local legends_vs = dfhack.gui.getViewscreenByType(df.viewscreen_legendsst, 0)
                    or qerror("Could not find legends screen")
                gui.simulateInput(legends_vs, 'LEGENDS_EXPORT_DETAILED_MAP')
            end

            vs = dfhack.gui.getViewscreenByType(df.viewscreen_export_graphical_mapst, 0)
                or qerror("Could not find map export screen")
            vs.sel_idx = i - 1
            print('    Exporting map: ' .. MAPS[i])
            gui.simulateInput(vs, 'SELECT')
            while dfhack.gui.getCurViewscreen() == vs do
                script.sleep(10, 'frames')
            end
        end
    end)
end

-- export site maps
function export_site_maps()
    local vs = dfhack.gui.getCurViewscreen()
    if ((dfhack.gui.getCurFocus() ~= "legends" ) and (not table.contains(vs, "main_cursor"))) then -- Using open-legends
        vs = vs.parent --luacheck: retype
    end
    if df.viewscreen_legendsst:is_instance(vs) then
        print('    Exporting:  All possible site maps')
        vs.main_cursor = 1
        gui.simulateInput(vs, 'SELECT')
        for i=1, #vs.sites do
            gui.simulateInput(vs, 'LEGENDS_EXPORT_MAP')
            gui.simulateInput(vs, 'STANDARDSCROLL_DOWN')
        end
        gui.simulateInput(vs, 'LEAVESCREEN')
    else
        qerror('this command can only be used in Legends mode')
    end
end

-- main()
if dfhack.gui.getCurFocus() == "legends" or dfhack.gui.getCurFocus() == "dfhack/lua/legends" then
    -- either native legends mode, or using the open-legends.lua script
    if args[1] == "all" then
        export_legends_info()
        export_site_maps()
        export_detailed_maps()
    elseif args[1] == "info" then
        export_legends_info()
    elseif args[1] == "custom" then
        export_more_legends_xml()
    elseif args[1] == "maps" then
        export_detailed_maps()
    elseif args[1] == "sites" then
        export_site_maps()
    else
        qerror('Valid arguments are "all", "info", "custom", "maps" or "sites"')
    end
elseif args[1] == "maps" and dfhack.gui.getCurFocus() == "export_graphical_map" then
    export_detailed_maps()
else
    qerror('Exportlegends must be run from the main legends view')
end
