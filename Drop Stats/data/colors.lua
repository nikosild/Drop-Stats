------------------------------------------------------------
-- Color Theme Configuration
-- Centralised color definitions for the overlay
-- Each entry maps a category key to its render color function
------------------------------------------------------------

local colors = {}

-- Category -> color function used for rendering
-- These reference the global color_*() functions from the game API
colors.category = {
    header      = function() return color_yellow(255) end,
    separator   = function() return color_white(255) end,
    rares       = function() return color_yellow(255) end,
    legendaries = function() return color_orange(255) end,
    uniques     = function() return color_white(255) end,
    mythics     = function() return color_pink(255) end,
    runes       = function() return color_white(255) end,
    gold        = function() return color_yellow(255) end,
    obols       = function() return color_white(255) end,
    uptime      = function() return color_white(255) end,
    rate        = function() return color_white(180) end,
    run_best    = function() return color_green(255) end,
    run_normal  = function() return color_white(200) end,
}

-- Which categories get the bold (double-draw) treatment
colors.bold = {
    legendaries = true,
    uniques     = true,
    mythics     = true,
}

return colors
