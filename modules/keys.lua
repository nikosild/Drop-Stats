------------------------------------------------------------
-- Keys Module
-- Tracks key/dungeon key count increases
-- Logs new keys to the drop feed
-- Only counts positive deltas (ignores using keys)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local keys = {}

-- Track seen key keys to detect new ones
local seen_keys = {}

------------------------------------------------------------
-- Make a unique key for a key item
------------------------------------------------------------
local function make_key_key(item)
    local ok, key = pcall(function()
        return tostring(item:get_sno_id())
            .. '_' .. tostring(item:get_display_name())
    end)
    if ok then return key end
    return nil
end

------------------------------------------------------------
-- Log a key drop to the drop feed
------------------------------------------------------------
local function log_key_drop(name)
    local entry = {
        category  = 'key',
        name      = name or 'Key',
        timestamp = get_time_since_inject() - tracker.uptime_start,
    }
    table.insert(tracker.drop_log, 1, entry)
    while #tracker.drop_log > tracker.drop_log_max do
        table.remove(tracker.drop_log)
    end
end

------------------------------------------------------------
-- Count all keys in dungeon key inventory
------------------------------------------------------------
local function count_keys(lp)
    local ok, keys = pcall(function() return lp:get_dungeon_key_items() end)
    if not ok or not keys then return 0 end
    return #keys
end

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function keys.build_baseline(lp)
    tracker.prev_scan.keys = count_keys(lp)

    seen_keys = {}
    local ok, keys = pcall(function() return lp:get_dungeon_key_items() end)
    if not ok or not keys then return end

    for i, item in pairs(keys) do
        if item then
            local display = utils.safe_get(function() return item:get_display_name() end) or ''
            local sno = utils.safe_get(function() return item:get_sno_id() end) or ''
            local key = tostring(sno) .. '_' .. display .. '_' .. tostring(i)
            seen_keys[key] = true
        end
    end
end

------------------------------------------------------------
-- Scan for key changes
------------------------------------------------------------
function keys.scan(lp)
    local current = count_keys(lp)

    if tracker.prev_scan.keys and current > tracker.prev_scan.keys then
        local delta = current - tracker.prev_scan.keys
        tracker.session.keys = tracker.session.keys + delta

        -- Find new keys to log
        local ok, keys = pcall(function() return lp:get_dungeon_key_items() end)
        if ok and keys then
            local current_keys = {}
            for i, item in pairs(keys) do
                if item then
                    local display = utils.safe_get(function() return item:get_display_name() end) or ''
                    local sno = utils.safe_get(function() return item:get_sno_id() end) or ''
                    local key = tostring(sno) .. '_' .. display .. '_' .. tostring(i)
                    current_keys[key] = true
                    if not seen_keys[key] then
                        log_key_drop(display)
                    end
                end
            end
            seen_keys = current_keys
        end
    else
        -- Update seen keys even when no delta
        local ok, keys = pcall(function() return lp:get_dungeon_key_items() end)
        if ok and keys then
            local current_keys = {}
            for i, item in pairs(keys) do
                if item then
                    local display = utils.safe_get(function() return item:get_display_name() end) or ''
                    local sno = utils.safe_get(function() return item:get_sno_id() end) or ''
                    local key = tostring(sno) .. '_' .. display .. '_' .. tostring(i)
                    current_keys[key] = true
                end
            end
            seen_keys = current_keys
        end
    end

    tracker.prev_scan.keys = current
end

------------------------------------------------------------
-- Get current key count
------------------------------------------------------------
function keys.get_current(lp)
    return count_keys(lp)
end

------------------------------------------------------------
-- Reset seen keys
------------------------------------------------------------
function keys.reset()
    seen_keys = {}
end

return keys
