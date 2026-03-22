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
-- Make a unique key for a socketable item
------------------------------------------------------------
local function make_rune_key(item)
    local ok, key = pcall(function()
        return tostring(item:get_sno_id())
            .. '_' .. tostring(item:get_stack_count())
    end)
    if ok then return key end
    return nil
end

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
-- Count all runes in socketable inventory
------------------------------------------------------------
local function count_runes(lp)
    local total = 0
    local ok, socks = pcall(function() return lp:get_socketable_items() end)
    if not ok or not socks then return 0 end

    for _, item in pairs(socks) do
        if item then
            local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
            if ok_name and name and name:match('rune') then
                local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                total = total + (ok_stack and stack and stack > 0 and stack or 1)
            end
        end
    end
    return total
end

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function runes.build_baseline(lp)
    tracker.prev_scan.runes = count_runes(lp)

    -- Snapshot current rune items
    seen_runes = {}
    local ok, socks = pcall(function() return lp:get_socketable_items() end)
    if not ok or not socks then return end

    for _, item in pairs(socks) do
        if item then
            local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
            if ok_name and name and name:match('rune') then
                local ok_sno, sno = pcall(function() return item:get_sno_id() end)
                local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                local key = (ok_sno and tostring(sno) or '?') .. '_' .. (ok_stack and tostring(stack) or '?')
                seen_runes[key] = true
            end
        end
    end
end

------------------------------------------------------------
-- Scan for rune changes
------------------------------------------------------------
function runes.scan(lp)
    local current = count_runes(lp)

    -- Track delta for session total
    if tracker.prev_scan.runes and current > tracker.prev_scan.runes then
        local delta = current - tracker.prev_scan.runes
        tracker.session.runes = tracker.session.runes + delta

        -- Find new runes to log
        local ok, socks = pcall(function() return lp:get_socketable_items() end)
        if ok and socks then
            local current_keys = {}
            for _, item in pairs(socks) do
                if item then
                    local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
                    if ok_name and name and name:match('rune') then
                        local ok_sno, sno = pcall(function() return item:get_sno_id() end)
                        local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                        local key = (ok_sno and tostring(sno) or '?') .. '_' .. (ok_stack and tostring(stack) or '?')
                        current_keys[key] = true
                        if not seen_runes[key] then
                            local display = utils.safe_get(function() return item:get_display_name() end)
                                or utils.safe_get(function() return item:get_name() end)
                                or 'Rune'
                            log_rune_drop(display)
                        end
                    end
                end
            end
            seen_runes = current_keys
        end
    else
        -- Update seen keys even when no delta (items may have left)
        local ok, socks = pcall(function() return lp:get_socketable_items() end)
        if ok and socks then
            local current_keys = {}
            for _, item in pairs(socks) do
                if item then
                    local ok_name, name = pcall(function() return string.lower(item:get_name()) end)
                    if ok_name and name and name:match('rune') then
                        local ok_sno, sno = pcall(function() return item:get_sno_id() end)
                        local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                        local key = (ok_sno and tostring(sno) or '?') .. '_' .. (ok_stack and tostring(stack) or '?')
                        current_keys[key] = true
                    end
                end
            end
            seen_runes = current_keys
        end
    end

    tracker.prev_scan.runes = current
end

------------------------------------------------------------
-- Get current rune count
------------------------------------------------------------
function runes.get_current(lp)
    return count_runes(lp)
end

------------------------------------------------------------
-- Reset seen runes
------------------------------------------------------------
function runes.reset()
    seen_runes = {}
end

return runes
