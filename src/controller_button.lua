SilkTouch.ControllerButtons = {}
SilkTouch.ControllerButton = SMODS.GameObject:extend{
    obj_table = SilkTouch.ControllerButtons,
    obj_buffer = {},
    set = "ControllerButton",
    required_params = {
        "key",
    },
    side = "left",
    button_key = "leftshoulder",
    button_order = 1,
    text = function(card) return { "test" } end,
    text_scale = function() return { 0.4 } end,
    colour = G.C.GREEN,
    card_width_coeffi = 1,
    focus_condition = function(card) return true end,
    active_check = function(card) return true end,
    press_func = function(card) G.DEBUG_VALUE = 'WORKIN' end,
    inject = function(self)
        if self.prefix_config == false or (self.prefix_config and self.prefix_config.key == false) then
            assert(self.key ~= "silktouch_order", "Key \"silktouch_order\" is already taken for internal processing. Please use a different key.")
        end
        if self.active_check_cb or self.press_func_cb then
            assert(self.active_check_cb and self.press_func_cb, "\"active_check_cb\" and \"press_func_cb\" must be defined together.")
        else
            local can_press = self.original_mod.prefix.."_can_"..self.original_key
            self.active_check_cb = can_press
            G.FUNCS[can_press] = function(e)
                local card = e.config.ref_table
                if self.active_check(card) then
                    e.config.colour = self.colour
                    e.config.button = self.key
                else
                    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                    e.config.button = nil
                end
            end
            self.press_func_cb = self.key
            G.FUNCS[self.key] = function(e)
                local card = e.config.ref_table
                self.press_func(card)
            end
        end
    end,
    process_loc_text = function() end,
}

SilkTouch.ControllerButton{
    key = "buy",
    prefix_config = {key = false},
    side = "right",
    button_key = "rightshoulder",
    button_order = 1,
    text = function(card)
        return {
            localize('b_buy'),
            single_text = true,
        }
    end,
    text_scale = function() return {0.5} end,
    focus_condition = function(card)
        return G.STAGE == G.STAGES.RUN and card.area and (card.area == G.shop_jokers
        or (card.area == G.shop_vouchers and card.ability.set ~= "Voucher")
        or (card.area == G.shop_booster and card.ability.set ~= "Booster"))
    end,
    active_check_cb = "can_buy",
    press_func_cb = "buy_from_shop",
}

SilkTouch.ControllerButton{
    key = "buy_and_use",
    prefix_config = {key = false},
    side = "right",
    button_key = "leftshoulder",
    button_order = 2,
    text = function(card)
        return {
            localize('b_buy'),
            localize('b_and_use'),
        }
    end,
    text_scale = function()
        return {0.4, 0.3}
    end,
    minh = 1,
    focus_condition = function(card)
        return G.STAGE == G.STAGES.RUN and card.area and (card.area == G.shop_jokers
        or (card.area == G.shop_vouchers and card.ability.set ~= "Voucher")
        or (card.area == G.shop_booster and card.ability.set ~= "Booster"))
        and card.ability.consumeable
    end,
    active_check_cb = "can_buy_and_use",
    press_func_cb = "buy_from_shop",
}

SilkTouch.ControllerButton{
    key = "redeem",
    prefix_config = {key = false},
    side = "left",
    button_key = "leftshoulder",
    button_order = 1,
    text = function(card)
        return {
            localize('b_redeem'),
            single_text = true,
        }
    end,
    text_scale = function() return {0.5} end,
    minw = 1.3,
    focus_condition = function(card)
        return G.STAGE == G.STAGES.RUN and card.ability.set == "Voucher"
    end,
    active_check_cb = "can_redeem",
    press_func_cb = "redeem_from_shop",
}

SilkTouch.ControllerButton{
    key = "open",
    prefix_config = {key = false},
    side = "right",
    button_key = "rightshoulder",
    button_order = 1,
    text = function(card)
        return {
            localize('b_open'),
            single_text = true,
        }
    end,
    text_scale = function() return {0.5} end,
    card_width_coeffi = 0.85,
    minw = 1.2,
    focus_condition = function(card)
        return G.STAGE == G.STAGES.RUN and card.ability.set == "Booster"
    end,
    active_check_cb = "can_open",
    press_func_cb = "open_booster",
}

SilkTouch.ControllerButton{
    key = "use",
    prefix_config = {key = false},
    side = "right",
    button_key = "rightshoulder",
    button_order = 1,
    text = function(card)
        return {
            localize('b_use'),
            single_text = true,
        }
    end,
    text_scale = function() return {0.5} end,
    focus_condition = function(card)
        if card.area and card.area == G.pack_cards and card.ability.consumeable then
            local to_area = booster_obj and SMODS.card_select_area(card, booster_obj) and card:selectable_from_pack(booster_obj)
            if to_area then
                return false
            end
        end
        return G.STAGE == G.STAGES.RUN and card.area and card.area ~= G.shop_jokers and card.area ~= G.shop_vouchers
        and card.area ~= G.shop_booster and card.ability.consumeable
    end,
    active_check_cb = "can_use_consumeable",
    press_func_cb = "use_card",
}

SilkTouch.ControllerButton{
    key = "select",
    prefix_config = {key = false},
    side = "right",
    button_key = "rightshoulder",
    button_order = 1,
    text = function(card)
        return {
            localize('b_select'),
            single_text = true,
        }
    end,
    text_scale = function() return {0.3} end,
    minw = 1.1,
    focus_condition = function(card)
        if card.area and card.area == G.pack_cards and card.ability.consumeable then
            local to_area = booster_obj and SMODS.card_select_area(card, booster_obj) and card:selectable_from_pack(booster_obj)
            if to_area then
                return true
            end
        end
        return G.STAGE == G.STAGES.RUN and card.area and card.area == G.pack_cards and not card.ability.consumeable
    end,
    active_check_cb = "can_select_card",
    press_func_cb = "use_card",
}

SilkTouch.ControllerButton{
    key = "sell",
    prefix_config = {key = false},
    side = "left",
    button_key = "leftshoulder",
    button_order = 1,
    text = function(card)
        return {
            localize('b_sell'),
            {
                localize('$'),
                {ref_table = card, ref_value = "sell_cost_label"},
            },
        }
    end,
    text_scale = function()
        return {
            0.4,
            {0.4, 0.55},
        }
    end,
    focus_condition = function(card)
        return G.STAGE == G.STAGES.RUN and card.area and card.area ~= G.shop_jokers and card.area ~= G.shop_vouchers
        and card.area ~= G.shop_booster and card.area ~= G.pack_cards and card.ability.set ~= "Default" and card.ability.set ~= "Enhanced"
        and G.STATE ~= G.STATES.TUTORIAL
    end,
    active_check_cb = "can_sell_card",
    press_func_cb = "sell_card",
}