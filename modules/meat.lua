------------------------------------------------------------
-- Meat Module
-- Tracks Meaty Offering count increases from consumables
-- Only counts positive deltas (ignores spending)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local meat = {}

local MEAT_SNO_ID = 2583761

------------------------------------------------------------
-- Log meat drop to feed
------------------------------------------------------------
local function log_meat_drop(amount)
    local entry = {
        category  = 'meat',
        name      = '+' .. tostring(amount) .. ' Meaty Offering',
        timestamp = get_time_since_inject() - tracker.uptime_start,
    }
    table.insert(tracker.drop_log, 1, entry)
    while #tracker.drop_log > tracker.drop_log_max do
        table.remove(tracker.drop_log)
    end
end

------------------------------------------------------------
-- Count all meat in consumable inventory
------------------------------------------------------------
local function count_meat(lp)
    local total = 0
    local ok, consumables = pcall(function() return lp:get_consumable_items() end)
    if not ok or not consumables then return 0 end

    for _, item in pairs(consumables) do
        if item then
            local ok_sno, sno = pcall(function() return item:get_sno_id() end)
            if ok_sno and sno == MEAT_SNO_ID then
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
function meat.build_baseline(lp)
    tracker.prev_scan.meat = count_meat(lp)
end

------------------------------------------------------------
-- Scan for meat changes
------------------------------------------------------------
function meat.scan(lp)
    local current = count_meat(lp)
    if tracker.prev_scan.meat and current > tracker.prev_scan.meat then
        local delta = current - tracker.prev_scan.meat
        tracker.session.meat = tracker.session.meat + delta
        log_meat_drop(delta)
    end
    tracker.prev_scan.meat = current
end

------------------------------------------------------------
-- Get current meat count
------------------------------------------------------------
function meat.get_current(lp)
    return count_meat(lp)
end

return meat
