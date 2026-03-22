------------------------------------------------------------
-- GUI
-- All menu elements and the render function
------------------------------------------------------------

local plugin_label = 'session_stats'
local plugin_version = 'Drop Stats | ALiTiS | v.1.2'

local gui = {}

gui.plugin_label = plugin_label
gui.plugin_version = plugin_version

------------------------------------------------------------
-- Helper
------------------------------------------------------------
local function create_checkbox(value, key)
    return checkbox:new(value, get_hash(plugin_label .. '_' .. key))
end

------------------------------------------------------------
-- Elements
------------------------------------------------------------
gui.elements = {
    -- Main
    main_tree       = tree_node:new(0),
    main_toggle     = create_checkbox(true, 'main_toggle'),
    persist_session = create_checkbox(true, 'persist_session'),

    -- Display settings
    display_tree     = tree_node:new(1),
    draw_offset_x    = slider_int:new(0, 4000, 0, get_hash(plugin_label .. '_offset_x')),
    draw_offset_y    = slider_int:new(-200, 1500, 0, get_hash(plugin_label .. '_offset_y')),
    font_size        = slider_int:new(12, 30, 19, get_hash(plugin_label .. '_font_size')),
    header_gap       = slider_int:new(4, 10, 4, get_hash(plugin_label .. '_header_gap')),
    line_gap         = slider_int:new(0, 10, 1, get_hash(plugin_label .. '_line_gap')),

    -- Category toggles
    category_tree    = tree_node:new(1),
    show_rates       = create_checkbox(false, 'show_rates'),
    show_uptime      = create_checkbox(true, 'show_uptime'),

    rares_tree       = tree_node:new(2),
    show_rares       = create_checkbox(true, 'show_rares'),
    bold_rares       = create_checkbox(false, 'bold_rares'),

    legendaries_tree = tree_node:new(2),
    show_legendaries = create_checkbox(true, 'show_legendaries'),
    bold_legendaries = create_checkbox(false, 'bold_legendaries'),

    uniques_tree     = tree_node:new(2),
    show_uniques     = create_checkbox(true, 'show_uniques'),
    bold_uniques     = create_checkbox(true, 'bold_uniques'),

    mythics_tree     = tree_node:new(2),
    show_mythics     = create_checkbox(true, 'show_mythics'),
    bold_mythics     = create_checkbox(true, 'bold_mythics'),

    runes_tree       = tree_node:new(2),
    show_runes       = create_checkbox(true, 'show_runes'),
    bold_runes       = create_checkbox(false, 'bold_runes'),

    gold_tree        = tree_node:new(2),
    show_gold        = create_checkbox(true, 'show_gold'),
    bold_gold        = create_checkbox(false, 'bold_gold'),

    obols_tree        = tree_node:new(2),
    show_obols        = create_checkbox(true, 'show_obols'),
    bold_obols        = create_checkbox(false, 'bold_obols'),

    show_meat         = create_checkbox(true, 'show_meat'),
    bold_meat         = create_checkbox(false, 'bold_meat'),
    meat_tree         = tree_node:new(2),

    show_pits         = create_checkbox(true, 'show_pits'),

    -- Extra sections
    extras_tree      = tree_node:new(1),
    show_peaks       = create_checkbox(true, 'show_peaks'),
    show_drops       = create_checkbox(true, 'show_drops'),
    drop_log_max     = slider_int:new(3, 20, 3, get_hash(plugin_label .. '_drop_log_max')),
    show_history     = create_checkbox(true, 'show_history'),
    history_max      = slider_int:new(1, 10, 2, get_hash(plugin_label .. '_history_max')),

    -- Keybinds
    keybind_tree     = tree_node:new(1),
    reset_keybind    = keybind:new(0x0A, true, get_hash(plugin_label .. '_reset_keybind')),
    mark_run_keybind = keybind:new(0x0A, true, get_hash(plugin_label .. '_mark_run_keybind')),
}

------------------------------------------------------------
-- Render menu
------------------------------------------------------------
function gui.render()
    if not gui.elements.main_tree:push(gui.plugin_version) then return end

    gui.elements.main_toggle:render('Enable', 'Enable the session stats overlay')
    gui.elements.persist_session:render('F5 Saves Data', 'Keep session stats when F5 is pressed')

    -- Display settings
    if gui.elements.display_tree:push('Display Settings') then
        gui.elements.draw_offset_x:render('Offset X', 'Horizontal position offset')
        gui.elements.draw_offset_y:render('Offset Y', 'Vertical position offset')
        gui.elements.font_size:render('Font Size', 'Text size for the overlay')
        gui.elements.header_gap:render('Header Gap', 'Extra spacing after section headers')
        gui.elements.line_gap:render('Line Gap', 'Extra spacing between lines')
        gui.elements.display_tree:pop()
    end

    -- Category toggles
    if gui.elements.category_tree:push('Tracked Categories') then
        gui.elements.show_rates:render('Show Rates (/h)', 'Display per-hour rates next to totals')
        gui.elements.show_pits:render('Pit Counter', 'Auto-detect and count completed Pit runs with average time')
        gui.elements.show_uptime:render('Uptime', 'Display session timer')

        if gui.elements.rares_tree:push('Rares') then
            gui.elements.show_rares:render('Enable', 'Track and display rare items')
            gui.elements.bold_rares:render('Bold', 'Render rares text in bold')
            gui.elements.rares_tree:pop()
        end

        if gui.elements.legendaries_tree:push('Legendaries') then
            gui.elements.show_legendaries:render('Enable', 'Track and display legendary items')
            gui.elements.bold_legendaries:render('Bold', 'Render legendaries text in bold')
            gui.elements.legendaries_tree:pop()
        end

        if gui.elements.uniques_tree:push('Uniques') then
            gui.elements.show_uniques:render('Enable', 'Track and display unique items')
            gui.elements.bold_uniques:render('Bold', 'Render uniques text in bold')
            gui.elements.uniques_tree:pop()
        end

        if gui.elements.mythics_tree:push('Mythics') then
            gui.elements.show_mythics:render('Enable', 'Track and display mythic items')
            gui.elements.bold_mythics:render('Bold', 'Render mythics text in bold')
            gui.elements.mythics_tree:pop()
        end

        if gui.elements.runes_tree:push('Runes') then
            gui.elements.show_runes:render('Enable', 'Track and display runes')
            gui.elements.bold_runes:render('Bold', 'Render runes text in bold')
            gui.elements.runes_tree:pop()
        end

        if gui.elements.gold_tree:push('Gold') then
            gui.elements.show_gold:render('Enable', 'Track and display gold earned')
            gui.elements.bold_gold:render('Bold', 'Render gold text in bold')
            gui.elements.gold_tree:pop()
        end

        if gui.elements.obols_tree:push('Obols') then
            gui.elements.show_obols:render('Enable', 'Track and display obols earned')
            gui.elements.bold_obols:render('Bold', 'Render obols text in bold')
            gui.elements.obols_tree:pop()
        end

        if gui.elements.meat_tree:push('Meat') then
            gui.elements.show_meat:render('Enable', 'Track and display Meaty Offerings earned')
            gui.elements.bold_meat:render('Bold', 'Render meat text in bold')
            gui.elements.meat_tree:pop()
        end

        gui.elements.category_tree:pop()
    end

    -- Extra sections
    if gui.elements.extras_tree:push('Extra Features') then
        gui.elements.show_peaks:render('Show Peak Rates', 'Display best per-hour rates achieved')
        gui.elements.show_drops:render('Show Recent Drops', 'Display a scrolling feed of recent item drops')
        if gui.elements.show_drops:get() then
            gui.elements.drop_log_max:render('Max Drop Log', 'Maximum number of recent drops to display')
        end
        gui.elements.show_history:render('Show Run History', 'Display per-run breakdowns')
        if gui.elements.show_history:get() then
            gui.elements.history_max:render('Max Runs Shown', 'Number of recent runs to display')
            render_menu_header('Press Mark Run keybind between runs. Best run is highlighted green.')
        end
        gui.elements.extras_tree:pop()
    end

    -- Keybinds
    if gui.elements.keybind_tree:push('Keybinds') then
        gui.elements.reset_keybind:render('Reset Session', 'Press to reset all session stats and history')
        gui.elements.mark_run_keybind:render('Mark Run', 'Press to mark end of current run and start a new one')
        gui.elements.keybind_tree:pop()
    end

    gui.elements.main_tree:pop()
end

return gui
