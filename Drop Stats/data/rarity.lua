------------------------------------------------------------
-- Rarity Definitions
-- Maps game rarity IDs to internal keys and display names
------------------------------------------------------------

local rarity = {}

-- Game rarity ID -> internal key
rarity.id_to_key = {
    [1] = 'common',
    [2] = 'magic',
    [3] = 'rare',
    [4] = 'rare',        -- ancestral rare
    [5] = 'legendary',
    [6] = 'unique',
}

-- Internal key -> display name
rarity.display_names = {
    common    = 'Common',
    magic     = 'Magic',
    rare      = 'Rare',
    legendary = 'Legendary',
    unique    = 'Unique',
    mythic    = 'Mythic',
    rune      = 'Rune',
    gold      = 'Gold',
}

-- Which rarities we track in session
rarity.tracked = { 'rares', 'legendaries', 'uniques', 'mythics', 'runes', 'gold' }

-- Minimum rarity ID we care about (skip common/magic)
rarity.min_tracked_id = 3

return rarity
