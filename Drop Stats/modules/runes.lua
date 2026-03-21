------------------------------------------------------------
-- Runes Module
-- Tracks rune count increases from socketable items
-- Only counts positive deltas (ignores using runes)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local runes = {}

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
end

------------------------------------------------------------
-- Scan for rune changes
------------------------------------------------------------
function runes.scan(lp)
    local current = count_runes(lp)
    if tracker.prev_scan.runes and current > tracker.prev_scan.runes then
        tracker.session.runes = tracker.session.runes + (current - tracker.prev_scan.runes)
    end
    tracker.prev_scan.runes = current
end

------------------------------------------------------------
-- Get current rune count
------------------------------------------------------------
function runes.get_current(lp)
    return count_runes(lp)
end

return runes
