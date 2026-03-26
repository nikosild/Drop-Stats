------------------------------------------------------------
-- Deaths Module
-- Tracks player deaths by monitoring health changes
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local deaths = {}

local _was_alive = true
local _baseline_set = false

------------------------------------------------------------
-- Build baseline - check initial alive state
------------------------------------------------------------
function deaths.build_baseline(local_player)
    if _baseline_set then return end
    
    local ok, is_alive = pcall(function()
        return local_player:is_alive()
    end)
    
    if ok and is_alive ~= nil then
        _was_alive = is_alive
        _baseline_set = true
    end
end

------------------------------------------------------------
-- Scan for death state changes
------------------------------------------------------------
function deaths.scan(local_player)
    if not _baseline_set then
        deaths.build_baseline(local_player)
        return
    end
    
    local ok, is_alive = pcall(function()
        return local_player:is_alive()
    end)
    
    if not ok or is_alive == nil then return end
    
    -- Detect death transition (was alive, now dead)
    if _was_alive and not is_alive then
        tracker.session.deaths = tracker.session.deaths + 1
        
        -- Log death to drop feed
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
        
        utils.log('Death detected (total: ' .. tracker.session.deaths .. ')')
    end
    
    _was_alive = is_alive
end

------------------------------------------------------------
-- Reset tracking state
------------------------------------------------------------
function deaths.reset()
    _was_alive = true
    _baseline_set = false
end

return deaths
