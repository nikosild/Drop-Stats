------------------------------------------------------------
-- Persistence Module
-- Auto-saves session state to file every few seconds
-- Restores on startup (survives F5 reload)
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'

local persistence = {}

local SAVE_INTERVAL = 5  -- save every 5 seconds
local last_save_time = 0

-- Determine script root folder from package.path
local function get_script_dir()
    -- Find where this module was loaded from by searching for the gui module path
    for path in package.path:gmatch('[^;]+') do
        local test = path:gsub('%?', 'gui')
        local f = io.open(test, 'r')
        if f then
            f:close()
            -- Found the script root, extract directory
            local dir = test:match('(.*)[\\/]')
            return dir
        end
    end
    return '.'
end

local save_path = get_script_dir() .. '\\session_save.txt'

------------------------------------------------------------
-- Serialize session data to a simple key=value string
------------------------------------------------------------
local function serialize()
    local s = tracker.session
    local p = tracker.peaks
    local elapsed = utils.get_session_seconds()

    local lines = {
        'rares=' .. tostring(s.rares),
        'legendaries=' .. tostring(s.legendaries),
        'uniques=' .. tostring(s.uniques),
        'mythics=' .. tostring(s.mythics),
        'runes=' .. tostring(s.runes),
        'keys=' .. tostring(s.keys),
        'gold=' .. tostring(s.gold),
        'obols=' .. tostring(s.obols),
        'meat=' .. tostring(s.meat),
        'deaths=' .. tostring(s.deaths),
        'pits=' .. tostring(s.pits),
        'pit_total_time=' .. tostring(s.pit_total_time),
        'elapsed=' .. tostring(elapsed),
        'peak_rares=' .. tostring(p.rares_per_hour),
        'peak_legendaries=' .. tostring(p.legendaries_per_hour),
        'peak_uniques=' .. tostring(p.uniques_per_hour),
        'peak_mythics=' .. tostring(p.mythics_per_hour),
        'peak_gold=' .. tostring(p.gold_per_hour),
        'peak_obols=' .. tostring(p.obols_per_hour),
        'drop_count=' .. tostring(#tracker.drop_log),
    }

    -- Save drop log entries
    for i, entry in ipairs(tracker.drop_log) do
        lines[#lines + 1] = 'drop_' .. i .. '_cat=' .. tostring(entry.category)
        lines[#lines + 1] = 'drop_' .. i .. '_name=' .. tostring(entry.name)
        lines[#lines + 1] = 'drop_' .. i .. '_time=' .. tostring(entry.timestamp)
    end

    return table.concat(lines, '\n')
end

------------------------------------------------------------
-- Deserialize key=value string into a table
------------------------------------------------------------
local function deserialize(text)
    local data = {}
    for line in text:gmatch('[^\n]+') do
        local key, val = line:match('^(.-)=(.*)$')
        if key and val then
            data[key] = val
        end
    end
    return data
end

------------------------------------------------------------
-- Save session to file
------------------------------------------------------------
function persistence.save()
    local now = get_time_since_inject()
    if now - last_save_time < SAVE_INTERVAL then return end
    last_save_time = now

    local ok, err = pcall(function()
        local f = io.open(save_path, 'w')
        if f then
            f:write(serialize())
            f:close()
        end
    end)
end

------------------------------------------------------------
-- Try to restore session from file
-- Returns true if restored successfully
------------------------------------------------------------
function persistence.restore()
    local ok, result = pcall(function()
        local f = io.open(save_path, 'r')
        if not f then return false end
        local text = f:read('*a')
        f:close()
        if not text or text == '' then return false end

        local data = deserialize(text)

        -- Restore session totals
        tracker.session.rares       = tonumber(data.rares) or 0
        tracker.session.legendaries = tonumber(data.legendaries) or 0
        tracker.session.uniques     = tonumber(data.uniques) or 0
        tracker.session.mythics     = tonumber(data.mythics) or 0
        tracker.session.runes       = tonumber(data.runes) or 0
        tracker.session.keys        = tonumber(data.keys) or 0
        tracker.session.gold        = tonumber(data.gold) or 0
        tracker.session.obols       = tonumber(data.obols) or 0
        tracker.session.meat        = tonumber(data.meat) or 0
        tracker.session.deaths      = tonumber(data.deaths) or 0
        tracker.session.pits        = tonumber(data.pits) or 0
        tracker.session.pit_total_time = tonumber(data.pit_total_time) or 0

        -- Restore uptime by adjusting uptime_start backwards
        local elapsed = tonumber(data.elapsed) or 0
        tracker.uptime_start = get_time_since_inject() - elapsed

        -- Restore peaks
        tracker.peaks.rares_per_hour       = tonumber(data.peak_rares) or 0
        tracker.peaks.legendaries_per_hour = tonumber(data.peak_legendaries) or 0
        tracker.peaks.uniques_per_hour     = tonumber(data.peak_uniques) or 0
        tracker.peaks.mythics_per_hour     = tonumber(data.peak_mythics) or 0
        tracker.peaks.gold_per_hour        = tonumber(data.peak_gold) or 0
        tracker.peaks.obols_per_hour       = tonumber(data.peak_obols) or 0

        -- Restore drop log
        local drop_count = tonumber(data.drop_count) or 0
        tracker.drop_log = {}
        for i = 1, drop_count do
            local cat  = data['drop_' .. i .. '_cat']
            local name = data['drop_' .. i .. '_name']
            local time = tonumber(data['drop_' .. i .. '_time']) or 0
            if cat and name then
                tracker.drop_log[#tracker.drop_log + 1] = {
                    category  = cat,
                    name      = name,
                    timestamp = time,
                }
            end
        end

        utils.log('Session restored (' .. elapsed .. 's elapsed)')
        return true
    end)

    if ok and result then return true end
    return false
end

------------------------------------------------------------
-- Delete save file (called on manual reset)
------------------------------------------------------------
function persistence.clear()
    pcall(function()
        local f = io.open(save_path, 'w')
        if f then
            f:write('')
            f:close()
        end
    end)
end

return persistence
