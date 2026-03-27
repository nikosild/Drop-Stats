------------------------------------------------------------
-- Deaths Module
-- Tracks player deaths by monitoring health changes
-- Uses multiple detection methods for reliability
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local deaths = {}

local _was_dead       = false
local _baseline_set   = false
local _death_cooldown = 0  -- absolute time: ignore death checks until this passes

------------------------------------------------------------
-- Try multiple methods to check if player is dead.
-- Returns nil if no method could produce a definitive answer.
------------------------------------------------------------
local function is_dead(local_player)
    -- Method 1: is_alive() - most reliable when available
    local alive_check = utils.safe_get(function() return local_player:is_alive() end)
    if alive_check ~= nil then
        return not alive_check
    end

    -- Method 2: explicit is_dead() flag
    local dead_state = utils.safe_get(function() return local_player:is_dead() end)
    if dead_state ~= nil then
        return dead_state
    end

    -- Method 3: health at zero
    local hp = utils.safe_get(function() return local_player:get_current_health() end)
    if hp ~= nil then
        return hp <= 0
    end

    -- No method succeeded - return nil so caller can skip
    return nil
end

------------------------------------------------------------
-- Build baseline - record initial alive/dead state
------------------------------------------------------------
function deaths.build_baseline(local_player)
    if _baseline_set then return end

    local dead = is_dead(local_player)
    if dead == nil then
        -- API not ready yet; will retry next scan frame
        return
    end

    _was_dead = dead
    _baseline_set = true
    utils.log('Death tracking baseline set (alive: ' .. tostring(not _was_dead) .. ')')
end

------------------------------------------------------------
-- Log a death event
------------------------------------------------------------
local function log_death()
    tracker.session.deaths = tracker.session.deaths + 1

    local entry = {
        category  = 'death',
        name      = 'Death',
        timestamp = utils.get_session_seconds(),
    }
    table.insert(tracker.drop_log, 1, entry)
    while #tracker.drop_log > tracker.drop_log_max do
        table.remove(tracker.drop_log)
    end

    -- Cooldown: ignore further death checks for 10 seconds.
    -- _was_dead is intentionally left as true here so the transition
    -- from dead->alive can be tracked cleanly after the cooldown expires.
    _death_cooldown = get_time_since_inject() + 10
    utils.log('Death detected (total: ' .. tracker.session.deaths .. ')')
end

------------------------------------------------------------
-- Scan for death state changes
------------------------------------------------------------
function deaths.scan(local_player)
    if not _baseline_set then
        deaths.build_baseline(local_player)
        return
    end

    -- Inside cooldown: do nothing - don't read state, don't update _was_dead.
    -- This prevents the dead->alive->dead flicker that caused double-counts.
    if get_time_since_inject() < _death_cooldown then
        return
    end

    local currently_dead = is_dead(local_player)
    -- If all API methods failed this frame, skip entirely
    if currently_dead == nil then return end

    -- Only fire on the alive->dead edge
    if not _was_dead and currently_dead then
        log_death()
        -- _was_dead will be updated to true on the NEXT frame (after this
        -- function returns), so log_death can safely set the cooldown above
        -- without immediately re-triggering.
    end

    _was_dead = currently_dead
end

------------------------------------------------------------
-- Reset tracking state
------------------------------------------------------------
function deaths.reset()
    _was_dead       = false
    _baseline_set   = false
    _death_cooldown = 0
end

return deaths
