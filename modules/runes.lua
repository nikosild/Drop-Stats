------------------------------------------------------------
-- Runes Module
-- Tracks rune count increases from socketable items
-- Logs new runes to the drop feed
-- Only counts positive deltas (ignores using runes)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local runes = {}

-- Track seen rune keys to detect new ones
local seen_runes = {}

------------------------------------------------------------
-- Log a rune drop to the drop feed
------------------------------------------------------------
local function log_rune_drop(name)
    local entry = {
        category  = 'rune',
        name      = name or 'Rune',
        timestamp = get_time_since_inject() - tracker.uptime_start,
    }
    table.insert(tracker.drop_log, 1, entry)
    while #tracker.drop_log > tracker.drop_log_max do
        table.remove(tracker.drop_log)
    end
end

------------------------------------------------------------
-- Count all runes in socketable inventory.
-- Returns: count (number), valid (bool)
-- valid=false when the API call itself failed; caller must
-- not update prev_scan on those frames.
------------------------------------------------------------
local function count_runes(lp)
    local ok, socks = pcall(function() return lp:get_socketable_items() end)
    if not ok or not socks then return 0, false end

    local total = 0
    for _, item in pairs(socks) do
        if item then
            local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
            if ok_name and name and name:match('rune') then
                local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                total = total + (ok_stack and stack and stack > 0 and stack or 1)
            end
        end
    end
    return total, true
end

------------------------------------------------------------
-- Snapshot current rune item keys from a valid socks list
------------------------------------------------------------
local function snapshot_rune_keys(socks)
    local keys = {}
    for _, item in pairs(socks) do
        if item then
            local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
            if ok_name and name and name:match('rune') then
                local ok_sno,   sno   = pcall(function() return item:get_sno_id() end)
                local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                local key = (ok_sno and tostring(sno) or '?') .. '_' .. (ok_stack and tostring(stack) or '?')
                keys[key] = { item = item, key = key }
            end
        end
    end
    return keys
end

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function runes.build_baseline(lp)
    local count, valid = count_runes(lp)
    if not valid then return end

    tracker.prev_scan.runes = count

    seen_runes = {}
    local ok, socks = pcall(function() return lp:get_socketable_items() end)
    if not ok or not socks then return end

    local snap = snapshot_rune_keys(socks)
    for k in pairs(snap) do
        seen_runes[k] = true
    end
end

------------------------------------------------------------
-- Scan for rune changes
------------------------------------------------------------
function runes.scan(lp)
    local ok, socks = pcall(function() return lp:get_socketable_items() end)
    -- Invalid read: leave prev_scan untouched, don't corrupt baseline
    if not ok or not socks then return end

    -- Count current runes from the list we already have
    local current = 0
    local current_keys = {}
    for _, item in pairs(socks) do
        if item then
            local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
            if ok_name and name and name:match('rune') then
                local ok_sno,   sno   = pcall(function() return item:get_sno_id() end)
                local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                local key = (ok_sno and tostring(sno) or '?') .. '_' .. (ok_stack and tostring(stack) or '?')
                current_keys[key] = item
                local stack_count = (ok_stack and stack and stack > 0 and stack or 1)
                current = current + stack_count
            end
        end
    end

    -- Track delta for session total
    if tracker.prev_scan.runes and current > tracker.prev_scan.runes then
        local delta = current - tracker.prev_scan.runes
        tracker.session.runes = tracker.session.runes + delta

        -- Log newly appeared rune keys
        for key, item in pairs(current_keys) do
            if not seen_runes[key] then
                local display = utils.safe_get(function() return item:get_display_name() end)
                    or utils.safe_get(function() return item:get_name() end)
                    or 'Rune'
                log_rune_drop(display)
            end
        end
    end

    -- Always refresh seen_runes and prev_scan on a valid read
    seen_runes = {}
    for key in pairs(current_keys) do
        seen_runes[key] = true
    end
    tracker.prev_scan.runes = current
end

------------------------------------------------------------
-- Get current rune count
------------------------------------------------------------
function runes.get_current(lp)
    local count, _ = count_runes(lp)
    return count
end

------------------------------------------------------------
-- Reset seen runes
------------------------------------------------------------
function runes.reset()
    seen_runes = {}
end

return runes
