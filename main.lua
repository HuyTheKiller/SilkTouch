SilkTouch = SMODS.merge_defaults(SMODS.current_mod, SilkTouch)

SMODS.load_file("src/drag_target.lua")()
SMODS.load_file("src/controller_button.lua")()

SMODS.Atlas{
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}

SilkTouch.description_loc_vars = function()
    return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end