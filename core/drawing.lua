------------------------------------------------------------
-- Drawing
-- Renders the on-screen overlay using data from all modules
-- Sections: totals, rates, drop log, run history, peaks
------------------------------------------------------------

local settings = require 'core.settings'
local tracker  = require 'core.tracker'
local utils    = require 'core.utils'
local colors   = require 'data.colors'
local rates    = require 'modules.rates'
local drops    = require 'modules.drops'
local history  = require 'modules.history'
local pit      = require 'modules.pit'

local drawing = {}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function draw_text(text, x, y, size, colour)
    graphics.text_2d(text, vec2:new(x, y), size, colour)
end

local function draw_bold(text, x, y, size, colour)
    graphics.text_2d(text, vec2:new(x, y), size, colour)
    graphics.text_2d(text, vec2:new(x + 1, y), size, colour)
end

local function draw_line(text, x, y, fs, category, is_bold)
    local colour = colors.category[category]()
    if is_bold then
        draw_bold(text, x, y, fs, colour)
    else
        draw_text(text, x, y, fs, colour)
    end
end

------------------------------------------------------------
-- Section: Session Totals
------------------------------------------------------------
local function draw_totals(x, y, fs)
    local s = tracker.session
    local show_rates = settings.show_rates
    local secs = utils.get_session_seconds()

    draw_bold('-- Drop Stats | ALiTiS | v.1.2 --', x, y, fs, colors.category.separator())
    y = y + fs + settings.header_gap

    local categories = {
        { key = 'rares',       label = 'Rares       ', value = s.rares,       show = settings.show_rares,       bold = settings.bold_rares },
        { key = 'legendaries', label = 'Legendaries ', value = s.legendaries, show = settings.show_legendaries, bold = settings.bold_legendaries },
        { key = 'uniques',     label = 'Uniques     ', value = s.uniques,     show = settings.show_uniques,     bold = settings.bold_uniques },
        { key = 'mythics',     label = 'Mythics     ', value = s.mythics,     show = settings.show_mythics,     bold = settings.bold_mythics },
        { key = 'runes',       label = 'Runes       ', value = s.runes,       show = settings.show_runes,       bold = settings.bold_runes },
    }

    for _, cat in ipairs(categories) do
        if cat.show then
            local line = cat.label .. ': ' .. tostring(cat.value)
            if show_rates then
                line = line .. '  (' .. rates.get_formatted(cat.key) .. ')'
            end
            draw_line(line, x, y, fs, cat.key, cat.bold)
            y = y + fs + settings.line_gap
        end
    end

    if settings.show_obols then
        local line = 'Obols       : ' .. utils.format_number(s.obols)
        if show_rates then
            line = line .. '  (' .. rates.get_formatted('obols') .. ')'
        end
        draw_line(line, x, y, fs, 'obols', settings.bold_obols)
        y = y + fs + settings.line_gap
    end

    if settings.show_meat then
        local line = 'Meat        : ' .. utils.format_number(s.meat)
        if show_rates then
            line = line .. '  (' .. rates.get_formatted('meat') .. ')'
        end
        draw_line(line, x, y, fs, 'meat', settings.bold_meat)
        y = y + fs + settings.line_gap
    end

    if settings.show_gold then
        local line = 'Gold        : ' .. utils.format_gold(s.gold)
        if show_rates then
            line = line .. '  (' .. rates.get_formatted('gold') .. ')'
        end
        draw_line(line, x, y, fs, 'gold', settings.bold_gold)
        y = y + fs + settings.line_gap
    end

    if settings.show_pits then
        local avg = pit.get_avg_time()
        local avg_str = avg > 0 and ('  avg ' .. utils.format_uptime(avg)) or ''
        local secs = utils.get_session_seconds()
        local pph_str = ''
        if secs >= 60 and s.pits > 0 then
            local pph = s.pits / (secs / 3600)
            pph_str = '  ' .. string.format("%.1f/h", pph)
        end
        local line = 'Pits        : ' .. tostring(s.pits) .. pph_str .. avg_str
        draw_line(line, x, y, fs, 'pits', true)
        y = y + fs + settings.line_gap
    end

    return y
end

------------------------------------------------------------
-- Section: Uptime
------------------------------------------------------------
local function draw_uptime(x, y, fs)
    if not settings.show_uptime then return y end

    draw_text('Uptime      : ' .. utils.format_uptime(utils.get_session_seconds()),
        x, y, fs, colors.category.uptime())
    y = y + fs + settings.line_gap

    return y
end

------------------------------------------------------------
-- Section: Peak Rates
------------------------------------------------------------
local function draw_peaks(x, y, fs)
    if not settings.show_peaks then return y end

    local p = tracker.peaks
    local secs = utils.get_session_seconds()
    if secs < 10 then return y end

    y = y + settings.header_gap  -- header gap
    draw_bold('-- Peak Rates --', x, y, fs, colors.category.run_best())
    y = y + fs

    local peak_lines = {
        { show = settings.show_legendaries, label = 'Legendaries ', val = p.legendaries_per_hour },
        { show = settings.show_uniques,     label = 'Uniques     ', val = p.uniques_per_hour },
        { show = settings.show_gold,        label = 'Gold        ', val = p.gold_per_hour },
    }

    for _, pk in ipairs(peak_lines) do
        if pk.show and pk.val > 0 then
            local val_str
            if pk.val >= 1000 then val_str = string.format("%.1fK/h", pk.val / 1000)
            else val_str = string.format("%.0f/h", pk.val) end
            draw_text(pk.label .. ': ' .. val_str, x, y, fs, colors.category.run_best())
            y = y + fs
        end
    end

    return y
end

------------------------------------------------------------
-- Section: Recent Drops
------------------------------------------------------------
local function draw_drops(x, y, fs)
    if not settings.show_drops then return y end

    local recent = drops.get_recent(settings.drop_log_max)
    if #recent == 0 then return y end

    y = y + settings.header_gap
    draw_bold('-- Recent Drops --', x, y, fs, colors.category.separator())
    y = y + fs

    local small_fs = math.max(12, fs - 4)
    for _, entry in ipairs(recent) do
        local text = drops.format_entry(entry)
        local col  = drops.get_color(entry.category)
        draw_text(text, x, y, small_fs, col)
        y = y + small_fs
    end

    return y
end

------------------------------------------------------------
-- Section: Run History
------------------------------------------------------------
local function draw_history(x, y, fs)
    if not settings.show_history then return y end

    local runs = history.get_runs(settings.history_max)
    if #runs == 0 then return y end

    local best = history.get_best_run()

    y = y + settings.header_gap
    draw_bold('-- Run History --', x, y, fs, colors.category.separator())
    y = y + fs

    local small_fs = math.max(12, fs - 4)
    for i, run in ipairs(runs) do
        local is_best = (best and run == best)
        local col = is_best and colors.category.run_best() or colors.category.run_normal()
        local prefix = is_best and '*' or ' '

        local line = string.format('%s#%d  %s  L:%d U:%d M:%d  %s',
            prefix, i,
            utils.format_uptime(run.duration),
            run.legendaries, run.uniques, run.mythics,
            utils.format_gold(run.gold))
        draw_text(line, x, y, small_fs, col)
        y = y + small_fs
    end

    -- Current run (live)
    local current = history.get_current_run()
    if current then
        local line = string.format(' NOW  %s  L:%d U:%d M:%d  %s',
            utils.format_uptime(current.duration),
            current.legendaries, current.uniques, current.mythics,
            utils.format_gold(current.gold))
        draw_text(line, x, y, small_fs, colors.category.header())
        y = y + small_fs
    end

    return y
end

------------------------------------------------------------
-- Main draw entry point
------------------------------------------------------------
function drawing.draw_overlay()
    local fs = settings.font_size
    local x  = 8 + settings.offset_x
    local y  = 50 + settings.offset_y

    y = draw_totals(x, y, fs)
    y = draw_uptime(x, y, fs)
    y = draw_peaks(x, y, fs)
    y = draw_drops(x, y, fs)
    y = draw_history(x, y, fs)
end

return drawing
