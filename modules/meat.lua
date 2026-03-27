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
-- Returns: count (number), valid (bool)
-- valid = false means the API call itself failed (nil list),
-- so the caller should NOT update prev_scan on that frame.
------------------------------------------------------------
local function count_meat(lp)
    local ok, consumables = pcall(function() return lp:get_consumable_items() end)
    -- API error or nil list → treat as invalid read, not zero
    if not ok or not consumables then
        return 0, false
    end

    local total = 0
    for _, item in pairs(consumables) do
        if item then
            local ok_sno, sno = pcall(function() return item:get_sno_id() end)
            if ok_sno and sno == MEAT_SNO_ID then
                local ok_stack, stack = pcall(function() return item:get_stack_count() end)
                total = total + (ok_stack and stack and stack > 0 and stack or 1)
            end
        end
    end
    -- Empty list is a valid read (player simply has no meat)
    return total, true
end

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function meat.build_baseline(lp)
    local count, valid = count_meat(lp)
    if valid then
        tracker.prev_scan.meat = count
    end
    -- If invalid on first scan, prev_scan.meat stays nil,
    -- and scan() will keep skipping until we get a valid read.
end

------------------------------------------------------------
-- Scan for meat changes
------------------------------------------------------------
function meat.scan(lp)
    local current, valid = count_meat(lp)

    -- Skip this frame entirely if the API returned garbage.
    -- prev_scan.meat is left unchanged so we don't corrupt the baseline.
    if not valid then return end

    if tracker.prev_scan.meat ~= nil and current > tracker.prev_scan.meat then
        local delta = current - tracker.prev_scan.meat
        tracker.session.meat = tracker.session.meat + delta
        log_meat_drop(delta)
    end

    -- Only update prev_scan when the read was valid
    tracker.prev_scan.meat = current
end

------------------------------------------------------------
-- Get current meat count
------------------------------------------------------------
function meat.get_current(lp)
    local count, _ = count_meat(lp)
    return count
end

return meat
