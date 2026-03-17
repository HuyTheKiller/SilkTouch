SilkTouch = SMODS.current_mod

function SilkTouch.config_tab()
    local action_button_label = localize("ph_enable_action_button") ~= "ERROR"
    and localize("ph_enable_action_button") or "Enable Actions Buttons"
    local drag_area_op_label = localize("ph_drag_area_op") ~= "ERROR"
    and localize("ph_drag_area_op") or "Drag Area Opacity"
    return {n=G.UIT.ROOT, config={align = "cm", padding = 0.05, colour = G.C.CLEAR}, nodes={
        create_toggle({label = action_button_label, ref_table = G.SETTINGS, ref_value = 'enable_action_buttons'}),
        create_slider({label = drag_area_op_label, w = 5, h = 0.4, ref_table = G.SETTINGS, ref_value = 'drag_area_opacity', min = 0, max = 100}),
    }}
end

function SilkTouch.can_buy(_card)
    local temp_config = {UIBox = {states = {visible = false}}, config = {ref_table = _card}}
    G.FUNCS.can_buy(temp_config)
    return temp_config.config.button ~= nil
end

function SilkTouch.can_buy_and_use(_card)
    local temp_config = {UIBox = {states = {visible = false}}, config = {ref_table = _card}}
    G.FUNCS.can_buy_and_use(temp_config)
    return temp_config.config.button ~= nil
end

function SilkTouch.can_select(_card)
    local temp_config = {UIBox = {states = {visible = false}}, config = {ref_table = _card}}
    G.FUNCS.can_select_card(temp_config)
    return temp_config.config.button ~= nil
end

SMODS.load_file("src/drag_target.lua")()

SMODS.Atlas{
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}

SilkTouch.description_loc_vars = function()
    return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end