------------------------------------------------------------
-- Gold Module
-- Tracks gold increases between scans
-- Only counts positive deltas (ignores spending)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local gold = {}

------------------------------------------------------------
-- Build baseline (first scan)
------------------------------------------------------------
function gold.build_baseline(lp)
    local amount = utils.safe_get(function() return lp:get_gold() end)
    if amount then
        tracker.prev_scan.gold = amount
    end
end

------------------------------------------------------------
-- Scan for gold changes
------------------------------------------------------------
function gold.scan(lp)
    local amount = utils.safe_get(function() return lp:get_gold() end)
    if not amount then return end

    if tracker.prev_scan.gold and amount > tracker.prev_scan.gold then
        tracker.session.gold = tracker.session.gold + (amount - tracker.prev_scan.gold)
    end
    tracker.prev_scan.gold = amount
end

------------------------------------------------------------
-- Get current gold amount
------------------------------------------------------------
function gold.get_current(lp)
    return utils.safe_get(function() return lp:get_gold() end) or 0
end

return gold
