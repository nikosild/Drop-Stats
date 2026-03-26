------------------------------------------------------------
-- Settings
-- Reads GUI element values into a flat runtime table
-- Other modules read settings.* instead of gui.elements.*
------------------------------------------------------------

local gui = require 'gui'

local settings = {
    plugin_label   = gui.plugin_label,
    plugin_version = gui.plugin_version,

    -- Runtime values (updated each frame by update_settings)
    enabled          = false,
    persist_session  = true,
    show_rares       = true,
    bold_rares       = false,
    show_legendaries = true,
    bold_legendaries = false,
    show_uniques     = true,
    bold_uniques     = true,
    show_mythics     = true,
    bold_mythics     = true,
    show_runes       = true,
    bold_runes       = false,
    show_keys        = true,
    bold_keys        = true,
    show_gold        = true,
    bold_gold        = false,
    show_obols        = true,
    bold_obols        = false,
    show_meat         = true,
    bold_meat         = false,
    show_deaths       = true,
    bold_deaths       = true,
    show_pits         = true,
    show_uptime      = true,
    show_rates       = false,
    show_history     = true,
    show_drops       = true,
    show_peaks       = true,
    font_size        = 19,
    header_gap       = 4,
    line_gap         = 1,
    offset_x         = 0,
    offset_y         = 0,
    history_max      = 2,
    drop_log_max     = 3,
}

function settings:update_settings()
    local el = gui.elements
    settings.enabled          = el.main_toggle:get()
    settings.persist_session  = el.persist_session:get()
    settings.show_rares       = el.show_rares:get()
    settings.bold_rares       = el.bold_rares:get()
    settings.show_legendaries = el.show_legendaries:get()
    settings.bold_legendaries = el.bold_legendaries:get()
    settings.show_uniques     = el.show_uniques:get()
    settings.bold_uniques     = el.bold_uniques:get()
    settings.show_mythics     = el.show_mythics:get()
    settings.bold_mythics     = el.bold_mythics:get()
    settings.show_runes       = el.show_runes:get()
    settings.bold_runes       = el.bold_runes:get()
    settings.show_keys        = el.show_keys:get()
    settings.bold_keys        = el.bold_keys:get()
    settings.show_gold        = el.show_gold:get()
    settings.bold_gold        = el.bold_gold:get()
    settings.show_obols        = el.show_obols:get()
    settings.bold_obols        = el.bold_obols:get()
    settings.show_meat         = el.show_meat:get()
    settings.bold_meat         = el.bold_meat:get()
    settings.show_deaths       = el.show_deaths:get()
    settings.bold_deaths       = el.bold_deaths:get()
    settings.show_pits         = el.show_pits:get()
    settings.show_uptime      = el.show_uptime:get()
    settings.show_rates       = el.show_rates:get()
    settings.show_history     = el.show_history:get()
    settings.show_drops       = el.show_drops:get()
    settings.show_peaks       = el.show_peaks:get()
    settings.font_size        = el.font_size:get()
    settings.header_gap       = el.header_gap:get()
    settings.line_gap         = el.line_gap:get()
    settings.offset_x         = el.draw_offset_x:get()
    settings.offset_y         = el.draw_offset_y:get()
    settings.history_max      = el.history_max:get()
    settings.drop_log_max     = el.drop_log_max:get()
end

return settings
