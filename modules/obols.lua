------------------------------------------------------------
-- Obols Module
-- Tracks obol increases between scans
-- Only counts positive deltas (ignores spending)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local obols = {}

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
        tracker.session.obols = tracker.session.obols + (amount - tracker.prev_scan.obols)
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
