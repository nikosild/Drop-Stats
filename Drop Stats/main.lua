------------------------------------------------------------
-- Session Stats - Main Entry Point
-- Standalone plugin for tracking session loot statistics
------------------------------------------------------------

local plugin_label = 'session_stats'

local gui      = require 'gui'
local settings = require 'core.settings'
local tracker  = require 'core.tracker'
local scanner  = require 'core.scanner'
local drawing  = require 'core.drawing'
local external = require 'core.external'
local persistence = require 'core.persistence'

local local_player
local _was_enabled = true  -- start true so F5 reload doesn't reset
local _restored = false    -- track if we've tried restoring

local debounce_time = nil
local debounce_timeout = 1

------------------------------------------------------------
-- Update locals
------------------------------------------------------------
local function update_locals()
    local_player = get_local_player()
end

------------------------------------------------------------
-- Main pulse (called every game update tick)
------------------------------------------------------------
local function main_pulse()
    settings:update_settings()

    -- Reset session when toggled on from off
    if settings.enabled and not _was_enabled then
        scanner.reset()
    end
    _was_enabled = settings.enabled

    if not local_player or not settings.enabled then return end

    -- Reset keybind
    if gui.elements.reset_keybind:get_state() == 1 then
        if debounce_time == nil or debounce_time + debounce_timeout < get_time_since_inject() then
            gui.elements.reset_keybind:set(false)
            debounce_time = get_time_since_inject()
            scanner.reset()
        end
    end

    -- Mark run keybind
    if gui.elements.mark_run_keybind:get_state() == 1 then
        if debounce_time == nil or debounce_time + debounce_timeout < get_time_since_inject() then
            gui.elements.mark_run_keybind:set(false)
            debounce_time = get_time_since_inject()
            scanner.mark_run()
        end
    end
end

------------------------------------------------------------
-- Render pulse (called every frame)
------------------------------------------------------------
local function render_pulse()
    if not local_player or not settings.enabled then return end

    -- Try to restore saved session on first frame
    if not _restored then
        _restored = true
        settings:update_settings()
        if settings.persist_session and persistence.restore() then
            tracker.first_scan = true  -- still need baseline for deltas
        end
    end

    -- Scan runs every render frame for best accuracy
    scanner.scan()

    -- Draw the overlay
    drawing.draw_overlay()
end

------------------------------------------------------------
-- Register callbacks
------------------------------------------------------------
on_update(function()
    update_locals()
    main_pulse()
end)

on_render(render_pulse)

on_render_menu(function()
    gui.render()
end)

------------------------------------------------------------
-- Expose global API for other plugins
------------------------------------------------------------
PLUGIN_session_stats = external
