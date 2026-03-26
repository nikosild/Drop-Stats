------------------------------------------------------------
-- Rates Module
-- Calculates per-hour rates for all tracked categories
-- Maintains peak (best) rate records across the session
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local rates = {}

-- Cache to avoid recalculating every frame
local cached_rates = {}
local last_calc_time = 0
local calc_interval = 2  -- recalculate every 2 seconds

------------------------------------------------------------
-- Recalculate all rates
------------------------------------------------------------
local function recalculate()
    local secs = utils.get_session_seconds()
    if secs < 10 then
        cached_rates = {}
        return
    end

    local s = tracker.session
    cached_rates = {
        rares       = utils.get_rate(s.rares, secs),
        legendaries = utils.get_rate(s.legendaries, secs),
        uniques     = utils.get_rate(s.uniques, secs),
        mythics     = utils.get_rate(s.mythics, secs),
        runes       = utils.get_rate(s.runes, secs),
        keys        = utils.get_rate(s.keys, secs),
        gold        = utils.get_rate(s.gold, secs),
        obols       = utils.get_rate(s.obols, secs),
        meat        = utils.get_rate(s.meat, secs),
        deaths      = utils.get_rate(s.deaths, secs),
    }

    -- Update peaks
    if secs >= 10 then
        local p = tracker.peaks
        if cached_rates.rares       > p.rares_per_hour       then p.rares_per_hour       = cached_rates.rares end
        if cached_rates.legendaries > p.legendaries_per_hour then p.legendaries_per_hour = cached_rates.legendaries end
        if cached_rates.uniques     > p.uniques_per_hour     then p.uniques_per_hour     = cached_rates.uniques end
        if cached_rates.mythics     > p.mythics_per_hour     then p.mythics_per_hour     = cached_rates.mythics end
        if cached_rates.gold        > p.gold_per_hour        then p.gold_per_hour        = cached_rates.gold end
        if cached_rates.obols       > p.obols_per_hour       then p.obols_per_hour       = cached_rates.obols end
    end
end

------------------------------------------------------------
-- Get current rates (cached, recalculated periodically)
------------------------------------------------------------
function rates.get()
    local now = get_time_since_inject()
    if now - last_calc_time >= calc_interval then
        recalculate()
        last_calc_time = now
    end
    return cached_rates
end

------------------------------------------------------------
-- Get formatted rate string for a category
------------------------------------------------------------
function rates.get_formatted(category)
    local r = rates.get()
    local val = r[category]
    if not val or val == 0 then return '--' end
    if val >= 10000 then return string.format("%.1fK/h", val / 1000) end
    if val >= 1000  then return string.format("%.1fK/h", val / 1000) end
    return string.format("%.0f/h", val)
end

------------------------------------------------------------
-- Get peak rates table
------------------------------------------------------------
function rates.get_peaks()
    return tracker.peaks
end

------------------------------------------------------------
-- Reset peaks
------------------------------------------------------------
function rates.reset_peaks()
    tracker.peaks = {
        rares_per_hour       = 0,
        legendaries_per_hour = 0,
        uniques_per_hour     = 0,
        mythics_per_hour     = 0,
        gold_per_hour        = 0,
        obols_per_hour       = 0,
    }
end

return rates
