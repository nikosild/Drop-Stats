------------------------------------------------------------
-- Keys Module
-- Tracks key/dungeon key count increases
-- Logs new keys to the drop feed
-- Only counts positive deltas (ignores using keys)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local keys = {}

-- Track seen key identifiers to detect new ones
local seen_keys = {}

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
-- Fetch dungeon key list.
-- Returns: list (table|nil), valid (bool)
-- valid=false when the API call itself failed.
------------------------------------------------------------
local function fetch_keys(lp)
    local ok, list = pcall(function() return lp:get_dungeon_key_items() end)
    if not ok or not list then return nil, false end
    return list, true
end

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function keys.build_baseline(lp)
    local list, valid = fetch_keys(lp)
    if not valid then return end

    tracker.prev_scan.keys = #list

    seen_keys = {}
    for i, item in pairs(list) do
        if item then
            local display = utils.safe_get(function() return item:get_display_name() end) or ''
            local sno     = utils.safe_get(function() return item:get_sno_id() end) or ''
            local key     = tostring(sno) .. '_' .. display .. '_' .. tostring(i)
            seen_keys[key] = true
        end
    end
end

------------------------------------------------------------
-- Scan for key changes
------------------------------------------------------------
function keys.scan(lp)
    local list, valid = fetch_keys(lp)
    -- Invalid read: leave prev_scan untouched, don't corrupt baseline
    if not valid then return end

    local current = #list

    -- Build current key set
    local current_keys = {}
    for i, item in pairs(list) do
        if item then
            local display = utils.safe_get(function() return item:get_display_name() end) or ''
            local sno     = utils.safe_get(function() return item:get_sno_id() end) or ''
            local key     = tostring(sno) .. '_' .. display .. '_' .. tostring(i)
            current_keys[key] = display
        end
    end

    if tracker.prev_scan.keys and current > tracker.prev_scan.keys then
        local delta = current - tracker.prev_scan.keys
        tracker.session.keys = tracker.session.keys + delta

        -- Log newly appeared keys
        for key, display in pairs(current_keys) do
            if not seen_keys[key] then
                log_key_drop(display)
            end
        end
    end

    -- Always refresh seen_keys and prev_scan on a valid read
    seen_keys = {}
    for key in pairs(current_keys) do
        seen_keys[key] = true
    end
    tracker.prev_scan.keys = current
end

------------------------------------------------------------
-- Get current key count
------------------------------------------------------------
function keys.get_current(lp)
    local list, valid = fetch_keys(lp)
    if not valid then return 0 end
    return #list
end

------------------------------------------------------------
-- Reset seen keys
------------------------------------------------------------
function keys.reset()
    seen_keys = {}
end

return keys
