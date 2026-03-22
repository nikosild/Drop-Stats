------------------------------------------------------------
-- External API
-- Public interface for other plugins to interact with
-- session stats. Exposed as PLUGIN_session_stats global.
------------------------------------------------------------

local settings = require 'core.settings'
local tracker  = require 'core.tracker'
local utils    = require 'core.utils'
local scanner  = require 'core.scanner'
local rates    = require 'modules.rates'
local history  = require 'modules.history'
local drops    = require 'modules.drops'

local external = {
    ------------------------------------------------------------
    -- Status
    ------------------------------------------------------------
    get_status = function()
        return {
            name    = settings.plugin_label,
            version = settings.plugin_version,
            enabled = settings.enabled,
            uptime  = utils.get_session_seconds(),
        }
    end,

    ------------------------------------------------------------
    -- Version check
    ------------------------------------------------------------
    check_version = function(input)
        input = input:gsub("^v", "")
        local current = {}
        local check = {}
        for part in settings.plugin_version:gmatch("%d+") do
            local num = tonumber(part)
            if not num then return false end
            table.insert(current, num)
        end
        for part in input:gmatch("%d+") do
            local num = tonumber(part)
            if not num then return false end
            table.insert(check, num)
        end
        if #check ~= 3 then return false end
        for i = 1, 3 do
            if current[i] > check[i] then return true
            elseif current[i] < check[i] then return false end
        end
        return true
    end,

    ------------------------------------------------------------
    -- Session data
    ------------------------------------------------------------
    get_session = function()
        return {
            rares       = tracker.session.rares,
            legendaries = tracker.session.legendaries,
            uniques     = tracker.session.uniques,
            mythics     = tracker.session.mythics,
            runes       = tracker.session.runes,
            keys        = tracker.session.keys,
            gold        = tracker.session.gold,
            obols       = tracker.session.obols,
            meat        = tracker.session.meat,
            pits        = tracker.session.pits,
            pit_total_time = tracker.session.pit_total_time,
            uptime      = utils.get_session_seconds(),
        }
    end,

    get_rates = function()
        return rates.get()
    end,

    get_peaks = function()
        return rates.get_peaks()
    end,

    ------------------------------------------------------------
    -- Drop log
    ------------------------------------------------------------
    get_recent_drops = function(max)
        return drops.get_recent(max or 10)
    end,

    get_drops_by_category = function(category, max)
        return drops.get_by_category(category, max or 10)
    end,

    ------------------------------------------------------------
    -- Run history
    ------------------------------------------------------------
    get_run_history = function(max)
        return history.get_runs(max or 5)
    end,

    get_best_run = function()
        return history.get_best_run()
    end,

    get_current_run = function()
        return history.get_current_run()
    end,

    get_run_count = function()
        return history.get_run_count()
    end,

    ------------------------------------------------------------
    -- Actions
    ------------------------------------------------------------
    reset = function()
        scanner.reset()
    end,

    mark_run = function()
        scanner.mark_run()
    end,

    is_enabled = function()
        return settings.enabled
    end,

    ------------------------------------------------------------
    -- Mythics table (in case other plugins need it)
    ------------------------------------------------------------
    get_mythics_table = function()
        return require 'data.mythics'
    end,
}

return external
