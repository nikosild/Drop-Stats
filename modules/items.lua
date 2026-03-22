------------------------------------------------------------
-- Items Module
-- Scans inventory for new items, classifies by rarity
-- Updates tracker.session counts and drop log
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'
local mythics = require 'data.mythics'

local items = {}

------------------------------------------------------------
-- Classify a single new item and update session counts
------------------------------------------------------------
local function classify_item(sno_id, rarity)
    if mythics[sno_id] ~= nil then
        tracker.session.mythics = tracker.session.mythics + 1
        tracker.last_mythic_time = get_time_since_inject()
        return 'mythic', mythics[sno_id]
    elseif rarity == 6 then
        tracker.session.uniques = tracker.session.uniques + 1
        return 'unique', nil
    elseif rarity == 5 then
        tracker.session.legendaries = tracker.session.legendaries + 1
        return 'legendary', nil
    elseif rarity == 4 or rarity == 3 then
        tracker.session.rares = tracker.session.rares + 1
        return 'rare', nil
    end
    return nil, nil
end

------------------------------------------------------------
-- Add entry to drop log (ring buffer)
------------------------------------------------------------
local function log_drop(category, name, sno_id)
    local entry = {
        category  = category,
        name      = name or ('sno:' .. tostring(sno_id)),
        timestamp = get_time_since_inject() - tracker.uptime_start,
    }
    table.insert(tracker.drop_log, 1, entry)
    -- Trim to max size
    while #tracker.drop_log > tracker.drop_log_max do
        table.remove(tracker.drop_log)
    end
end

------------------------------------------------------------
-- Build baseline (first scan only, count nothing)
------------------------------------------------------------
function items.build_baseline(lp)
    local ok_items, inv = pcall(function() return lp:get_inventory_items() end)
    if not ok_items or not inv then return false end

    local count = 0
    for _, item in pairs(inv) do
        if item then
            local key = utils.make_item_key(item)
            if key then
                tracker.seen_items[key] = true
                count = count + 1
            end
        end
    end
    utils.log('Baseline set: ' .. count .. ' items')
    return count > 0
end

------------------------------------------------------------
-- Scan for new items (call every frame)
------------------------------------------------------------
function items.scan(lp)
    local ok_items, inv = pcall(function() return lp:get_inventory_items() end)
    if not ok_items or not inv then return end

    local current_ids = {}
    for _, item in pairs(inv) do
        if item then
            local key    = utils.make_item_key(item)
            local sno_id = utils.safe_get(function() return item:get_sno_id() end)
            local rarity = utils.safe_get(function() return item:get_rarity() end)

            if key and sno_id and rarity then
                current_ids[key] = true
                if not tracker.seen_items[key] then
                    -- New item entered inventory
                    local category, mythic_name = classify_item(sno_id, rarity)
                    if category then
                        local display = utils.safe_get(function() return item:get_display_name() end)
                        log_drop(category, display or mythic_name, sno_id)
                    end
                    tracker.seen_items[key] = true
                end
            end
        end
    end

    -- Remove items that left inventory (sold, stashed, salvaged)
    for id in pairs(tracker.seen_items) do
        if not current_ids[id] then
            tracker.seen_items[id] = nil
        end
    end
end

return items
