------------------------------------------------------------
-- History Module
-- Tracks individual run snapshots so you can see per-run
-- breakdowns. A "run" is the period between resets.
-- Also identifies the best run by total legendaries+.
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local history = {}

-- Snapshot of session at the start of the current run
local run_start_snapshot = nil

------------------------------------------------------------
-- Start tracking a new run
------------------------------------------------------------
function history.start_run()
    run_start_snapshot = utils.shallow_copy(tracker.session)
    tracker.current_run_start = get_time_since_inject()
    tracker.run_active = true
end

------------------------------------------------------------
-- End current run and save to history
------------------------------------------------------------
function history.end_run()
    if not tracker.run_active or not run_start_snapshot then return end

    local s = tracker.session
    local snap = run_start_snapshot
    local duration = math.floor(get_time_since_inject() - tracker.current_run_start)

    local run = {
        duration    = duration,
        rares       = s.rares - snap.rares,
        legendaries = s.legendaries - snap.legendaries,
        uniques     = s.uniques - snap.uniques,
        mythics     = s.mythics - snap.mythics,
        runes       = s.runes - snap.runes,
        gold        = s.gold - snap.gold,
        obols       = s.obols - snap.obols,
        timestamp   = get_time_since_inject() - tracker.uptime_start,
    }

    -- Only save runs that lasted at least 30 seconds
    if duration >= 30 then
        table.insert(tracker.runs, 1, run)
        -- Keep a rolling window of recent runs
        while #tracker.runs > 20 do
            table.remove(tracker.runs)
        end
    end

    tracker.run_active = false
    run_start_snapshot = nil
end

------------------------------------------------------------
-- Get run history (most recent first)
------------------------------------------------------------
function history.get_runs(max)
    max = max or 5
    local result = {}
    for i = 1, math.min(max, #tracker.runs) do
        result[#result + 1] = tracker.runs[i]
    end
    return result
end

------------------------------------------------------------
-- Get best run by total valuable drops (leg + unique + mythic)
------------------------------------------------------------
function history.get_best_run()
    local best = nil
    local best_score = -1
    for _, run in ipairs(tracker.runs) do
        local score = run.legendaries + (run.uniques * 5) + (run.mythics * 50)
        if score > best_score then
            best_score = score
            best = run
        end
    end
    return best
end

------------------------------------------------------------
-- Get total number of completed runs
------------------------------------------------------------
function history.get_run_count()
    return #tracker.runs
end

------------------------------------------------------------
-- Get current run stats (live, since last start_run)
------------------------------------------------------------
function history.get_current_run()
    if not tracker.run_active or not run_start_snapshot then return nil end

    local s = tracker.session
    local snap = run_start_snapshot
    local duration = math.floor(get_time_since_inject() - tracker.current_run_start)

    return {
        duration    = duration,
        rares       = s.rares - snap.rares,
        legendaries = s.legendaries - snap.legendaries,
        uniques     = s.uniques - snap.uniques,
        mythics     = s.mythics - snap.mythics,
        runes       = s.runes - snap.runes,
        gold        = s.gold - snap.gold,
        obols       = s.obols - snap.obols,
        active      = true,
    }
end

------------------------------------------------------------
-- Clear history
------------------------------------------------------------
function history.clear()
    tracker.runs = {}
    run_start_snapshot = nil
    tracker.run_active = false
end

return history
