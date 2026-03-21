------------------------------------------------------------
-- Drops Module
-- Provides read access to the recent drop log
-- (Writing is done by modules/items.lua during scan)
-- Offers filtering and display-ready formatting
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'
local colors  = require 'data.colors'

local drops = {}

------------------------------------------------------------
-- Get recent drops (most recent first)
------------------------------------------------------------
function drops.get_recent(max)
    max = max or 10
    local result = {}
    for i = 1, math.min(max, #tracker.drop_log) do
        result[#result + 1] = tracker.drop_log[i]
    end
    return result
end

------------------------------------------------------------
-- Get recent drops filtered by category
------------------------------------------------------------
function drops.get_by_category(category, max)
    max = max or 10
    local result = {}
    for _, entry in ipairs(tracker.drop_log) do
        if entry.category == category then
            result[#result + 1] = entry
            if #result >= max then break end
        end
    end
    return result
end

------------------------------------------------------------
-- Format a single drop entry for display
------------------------------------------------------------
function drops.format_entry(entry)
    local time_str = utils.format_timestamp(entry.timestamp)
    local tag = string.upper(string.sub(entry.category, 1, 3))
    return string.format('[%s] %s  %s', time_str, tag, entry.name)
end

------------------------------------------------------------
-- Get color for a drop category
------------------------------------------------------------
function drops.get_color(category)
    -- Map singular drop categories to the plural tracker keys
    local map = {
        rare      = 'rares',
        legendary = 'legendaries',
        unique    = 'uniques',
        mythic    = 'mythics',
    }
    local key = map[category] or category
    local color_fn = colors.category[key]
    if color_fn then return color_fn() end
    return colors.category.separator()
end

------------------------------------------------------------
-- Get total drop count
------------------------------------------------------------
function drops.get_count()
    return #tracker.drop_log
end

------------------------------------------------------------
-- Clear drop log
------------------------------------------------------------
function drops.clear()
    tracker.drop_log = {}
end

return drops
