------------------------------------------------------------
-- Utility Functions
-- Formatting, logging, safe pcall wrappers, time helpers
------------------------------------------------------------

local tracker = require 'core.tracker'

local utils = {}

------------------------------------------------------------
-- Logging
------------------------------------------------------------
function utils.log(msg)
    console.print('[Drop Stats | ALiTiS] ' .. tostring(msg))
end

------------------------------------------------------------
-- Number formatting
------------------------------------------------------------
function utils.format_gold(g)
    if g >= 1000000000 then return string.format("%.2fB", g / 1000000000) end
    if g >= 1000000    then return string.format("%.2fM", g / 1000000) end
    if g >= 1000       then return string.format("%.1fK", g / 1000) end
    return tostring(g)
end

function utils.format_number(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000    then return string.format("%.1fK", n / 1000) end
    return tostring(n)
end

------------------------------------------------------------
-- Time formatting
------------------------------------------------------------
function utils.format_uptime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

function utils.format_timestamp(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

------------------------------------------------------------
-- Rate formatting
------------------------------------------------------------
function utils.format_rate(total, seconds)
    if seconds < 60 then return '--' end
    local per_hour = total / (seconds / 3600)
    if per_hour >= 10000 then return string.format("%.1fK/h", per_hour / 1000) end
    if per_hour >= 1000  then return string.format("%.1fK/h", per_hour / 1000) end
    return string.format("%.0f/h", per_hour)
end

function utils.get_rate(total, seconds)
    if seconds < 1 then return 0 end
    return total / (seconds / 3600)
end

------------------------------------------------------------
-- Safe item key generation
------------------------------------------------------------
function utils.make_item_key(item)
    local ok, key = pcall(function()
        return tostring(item:get_sno_id())
            .. '_' .. tostring(item:get_inventory_row())
            .. '_' .. tostring(item:get_inventory_column())
    end)
    if ok then return key end
    return nil
end

------------------------------------------------------------
-- Safe property access wrappers
------------------------------------------------------------
function utils.safe_get(fn)
    local ok, result = pcall(fn)
    if ok then return result end
    return nil
end

function utils.safe_count(fn)
    local ok, result = pcall(fn)
    if ok and result then return #result end
    return 0
end

------------------------------------------------------------
-- Session elapsed time
------------------------------------------------------------
function utils.get_session_seconds()
    return math.floor(get_time_since_inject() - tracker.uptime_start)
end

------------------------------------------------------------
-- Table utilities
------------------------------------------------------------
function utils.shallow_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

function utils.table_count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

return utils
