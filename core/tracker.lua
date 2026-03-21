------------------------------------------------------------
-- Session Tracker
-- Centralized mutable state for the entire plugin
-- All modules read/write to this single state table
------------------------------------------------------------

local plugin_label = 'session_stats'

local tracker = {
    name         = plugin_label,
    version      = nil,

    -- Session totals (accumulated by modules)
    session = {
        rares       = 0,
        legendaries = 0,
        uniques     = 0,
        mythics     = 0,
        runes       = 0,
        gold        = 0,
        obols       = 0,
    },

    -- Previous scan values (for delta detection)
    prev_scan = {
        gold  = nil,
        runes = nil,
        obols = nil,
    },

    -- Seen item keys (track what's been in inventory)
    seen_items = {},

    -- Scan state
    first_scan    = true,
    uptime_start  = get_time_since_inject(),

    -- Run history
    runs = {},           -- array of completed run snapshots
    current_run_start = get_time_since_inject(),
    run_active = false,

    -- Peak tracking
    peaks = {
        rares_per_hour       = 0,
        legendaries_per_hour = 0,
        uniques_per_hour     = 0,
        mythics_per_hour     = 0,
        gold_per_hour        = 0,
        obols_per_hour       = 0,
    },

    -- Drop log (recent items, ring buffer)
    drop_log = {},
    drop_log_max = 50,
}

return tracker
