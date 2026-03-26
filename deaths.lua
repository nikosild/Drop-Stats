------------------------------------------------------------
-- Deaths Module
-- Tracks player deaths by monitoring health changes
-- Uses multiple detection methods for reliability
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local deaths = {}

local _prev_health = nil
local _was_dead = false
local _baseline_set = false
local _death_cooldown = 0  -- Prevent double-counting same death

------------------------------------------------------------
-- Try multiple methods to check if player is dead
------------------------------------------------------------
local function is_dead(local_player)
    -- Method 1: Try is_alive() if available
    local alive_check = utils.safe_get(function() return local_player:is_alive() end)
    if alive_check ~= nil then
        return not alive_check
    end
    
    -- Method 2: Check health is exactly 0
    local current_health = utils.safe_get(function() return local_player:get_current_health() end)
    if current_health and current_health <= 0 then
        return true
    end
    
    -- Method 3: Check if player is in death state
    local is_dead_state = utils.safe_get(function() return local_player:is_dead() end)
    if is_dead_state ~= nil then
        return is_dead_state
    end
    
    return false
end

------------------------------------------------------------
-- Build baseline - check initial state
------------------------------------------------------------
function deaths.build_baseline(local_player)
    if _baseline_set then return end
    
    _was_dead = is_dead(local_player)
    _prev_health = utils.safe_get(function() return local_player:get_current_health() end) or 0
    _baseline_set = true
    utils.log('Death tracking baseline set (alive: ' .. tostring(not _was_dead) .. ')')
end

------------------------------------------------------------
-- Log a death event
------------------------------------------------------------
local function log_death()
    tracker.session.deaths = tracker.session.deaths + 1
    
    local elapsed = utils.get_session_seconds()
    local entry = {
        category  = 'death',
        name      = 'Death',
        timestamp = elapsed,
    }
    table.insert(tracker.drop_log, 1, entry)
    if #tracker.drop_log > tracker.drop_log_max then
        table.remove(tracker.drop_log)
    end
    
    _death_cooldown = get_time_since_inject() + 10  -- 10 second cooldown to prevent double-counting
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
    
    -- Don't double-count deaths within cooldown period
    if get_time_since_inject() < _death_cooldown then
        -- Still update state during cooldown
        _was_dead = is_dead(local_player)
        _prev_health = utils.safe_get(function() return local_player:get_current_health() end) or 0
        return
    end
    
    local current_health = utils.safe_get(function() return local_player:get_current_health() end) or 0
    local currently_dead = is_dead(local_player)
    
    -- Only detect death on state transition from alive to dead
    if not _was_dead and currently_dead then
        log_death()
    end
    
    _was_dead = currently_dead
    _prev_health = current_health
end

------------------------------------------------------------
-- Reset tracking state
------------------------------------------------------------
function deaths.reset()
    _prev_health = nil
    _was_dead = false
    _baseline_set = false
    _death_cooldown = 0
end

return deaths
