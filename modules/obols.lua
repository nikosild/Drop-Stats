------------------------------------------------------------
-- Obols Module
-- Tracks obol increases between scans
-- Only counts positive deltas (ignores spending)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local obols = {}

------------------------------------------------------------
-- Log obols drop to feed
------------------------------------------------------------
local function log_obols_drop(amount)
    local entry = {
        category  = 'obols',
        name      = '+' .. tostring(amount) .. ' Obols',
        timestamp = get_time_since_inject() - tracker.uptime_start,
    }
    table.insert(tracker.drop_log, 1, entry)
    while #tracker.drop_log > tracker.drop_log_max do
        table.remove(tracker.drop_log)
    end
end

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function obols.build_baseline(lp)
    local amount = utils.safe_get(function() return lp:get_obols() end)
    if amount then
        tracker.prev_scan.obols = amount
    end
end

------------------------------------------------------------
-- Scan for obol changes
------------------------------------------------------------
function obols.scan(lp)
    local amount = utils.safe_get(function() return lp:get_obols() end)
    if not amount then return end

    if tracker.prev_scan.obols and amount > tracker.prev_scan.obols then
        local delta = amount - tracker.prev_scan.obols
        tracker.session.obols = tracker.session.obols + delta
        log_obols_drop(delta)
    end
    tracker.prev_scan.obols = amount
end

------------------------------------------------------------
-- Get current obol amount
------------------------------------------------------------
function obols.get_current(lp)
    return utils.safe_get(function() return lp:get_obols() end) or 0
end

return obols
