------------------------------------------------------------
-- Scanner
-- Orchestrates scanning across all modules
-- Called every render frame for best accuracy
------------------------------------------------------------

local tracker = require 'core.tracker'
local utils   = require 'core.utils'
local items   = require 'modules.items'
local gold    = require 'modules.gold'
local runes   = require 'modules.runes'
local keys    = require 'modules.keys'
local obols   = require 'modules.obols'
local meat    = require 'modules.meat'
local deaths  = require 'modules.deaths'
local pit     = require 'modules.pit'
local rates   = require 'modules.rates'
local history = require 'modules.history'
local persistence = require 'core.persistence'
local settings = require 'core.settings'

local scanner = {}

-- Currency/resource baselines are set once immediately on first frame.
-- Kept separate from first_scan so they don't re-run every frame while
-- waiting for inventory to populate.
local _currency_baselined = false

------------------------------------------------------------
-- Main scan (called every frame)
------------------------------------------------------------
function scanner.scan()
    local lp = get_local_player()
    if not lp then return end

    -- First scan: build baseline across all modules
    if tracker.first_scan then
        -- Currency baselines run exactly once, don't depend on inventory.
        if not _currency_baselined then
            gold.build_baseline(lp)
            runes.build_baseline(lp)
            keys.build_baseline(lp)
            obols.build_baseline(lp)
            meat.build_baseline(lp)
            deaths.build_baseline(lp)
            _currency_baselined = true
        end

        -- Items baseline: try regardless, it's okay if inventory is empty.
        -- We no longer block on this -- an empty inventory is a valid baseline.
        items.build_baseline(lp)
        history.start_run()

        tracker.first_scan = false
        return
    end

    -- Regular scan: run all modules
    items.scan(lp)
    gold.scan(lp)
    runes.scan(lp)
    keys.scan(lp)
    obols.scan(lp)
    meat.scan(lp)
    deaths.scan(lp)
    pit.scan()

    -- Auto-save session periodically (if enabled)
    if settings.persist_session then
        persistence.save()
    end

    -- Rates are calculated lazily on read (cached internally)
    -- rates.get() is called by drawing when needed
end

------------------------------------------------------------
-- Full reset (clears everything)
------------------------------------------------------------
function scanner.reset()
    tracker.session    = { rares = 0, legendaries = 0, uniques = 0, mythics = 0, runes = 0, keys = 0, gold = 0, obols = 0, meat = 0, pits = 0, pit_total_time = 0, deaths = 0 }
    tracker.prev_scan  = { gold = nil, runes = nil, keys = nil, obols = nil, meat = nil }
    tracker.seen_items = {}
    tracker.drop_log   = {}
    tracker.first_scan = true
    tracker.uptime_start = get_time_since_inject()

    _currency_baselined = false
    rates.reset_peaks()
    history.clear()
    history.start_run()
    pit.reset()
    runes.reset()
    keys.reset()
    deaths.reset()
    persistence.clear()

    utils.log('Session reset')
end

------------------------------------------------------------
-- Mark end of current run and start new one
------------------------------------------------------------
function scanner.mark_run()
    history.end_run()
    history.start_run()
    utils.log('Run marked')
end

return scanner
