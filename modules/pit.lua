------------------------------------------------------------
-- Pit Module
-- Auto-detects Pit completions by tracking zone transitions
-- Counts completed pits and tracks average duration
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local pit = {}

local PIT_ZONES = {
    ['EGD_MSWK_World_01'] = true,
    ['EGD_MSWK_World_02'] = true,
}

local was_in_pit = false
local pit_enter_time = nil

------------------------------------------------------------
-- Check if player is currently in a Pit zone
------------------------------------------------------------
local function is_in_pit()
    local ok, zone = pcall(function()
        return get_current_world():get_current_zone_name()
    end)
    if ok and zone then
        return PIT_ZONES[zone] == true
    end
    return false
end

------------------------------------------------------------
-- Scan for zone transitions (call every frame)
------------------------------------------------------------
function pit.scan()
    local in_pit = is_in_pit()

    -- Entered pit
    if in_pit and not was_in_pit then
        pit_enter_time = get_time_since_inject()
    end

    -- Left pit (completed a run)
    if not in_pit and was_in_pit and pit_enter_time then
        local duration = math.floor(get_time_since_inject() - pit_enter_time)
        -- Only count runs that lasted at least 15 seconds
        if duration >= 15 then
            tracker.session.pits = tracker.session.pits + 1
            tracker.session.pit_total_time = tracker.session.pit_total_time + duration
        end
        pit_enter_time = nil
    end

    was_in_pit = in_pit
end

------------------------------------------------------------
-- Get average pit time in seconds
------------------------------------------------------------
function pit.get_avg_time()
    if tracker.session.pits == 0 then return 0 end
    return math.floor(tracker.session.pit_total_time / tracker.session.pits)
end

------------------------------------------------------------
-- Check if currently in pit (for external use)
------------------------------------------------------------
function pit.is_in_pit()
    return is_in_pit()
end

------------------------------------------------------------
-- Reset state
------------------------------------------------------------
function pit.reset()
    was_in_pit = false
    pit_enter_time = nil
end

return pit
