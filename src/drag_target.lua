SilkTouch.DragTargets = {}
SilkTouch.DragTarget = SMODS.GameObject:extend{
    obj_table = SilkTouch.DragTargets,
    obj_buffer = {},
    set = "DragTarget",
    required_params = {
        "key",
    },
    moveable_t = "S_buy",
    text = function(card)
        local buy_loc = copy_table(localize('ml_buy_target'))
        buy_loc[#buy_loc+1] = '$'..card.cost
        return buy_loc
    end,
    colour = G.C.UI.TRANSPARENT_DARK,
    drag_condition = function(card) return true end,
    active_check = function(card) return true end,
    release_func = function(card) G.DEBUG_VALUE = 'WORKIN' end,
    inject = function(self)
        assert(type(self.moveable_t) == "string" or type(self.moveable_t) == "table" or type(self.moveable_t) == "function", ("Field \"moveable_t\" must be a string, a table or a function."))
        if type(self.moveable_t) == "table" then
            local function valid_index(key)
                for _, v in ipairs{"x", "y", "w", "h"} do
                    if key == v then return true end
                end
                return false
            end
            for k, v in pairs(self.moveable_t) do
                assert(valid_index(k), ("Invalid key \"%s\" passed into \"moveable_t\"."):format(k))
                assert((type(v.ref_table) == "string" and type(v.ref_value) == "string")
                or (type(v.ref_table) == "table" and type(v.ref_value) == "table"
                and v.ref_table[1] and v.ref_value[1] and #v.ref_table == #v.ref_value
                and #v.ref_table <= #(v.operation_table or {}) + 1)
                or type(v.mod_value) == "number",
                "Invalid type for \"ref_table\" and \"ref_value\" (strings or string arrays with matching size expected).\nIf they're string arrays, make sure \"operation_table\" has at least one element less than them.\n\nIf you wish to ignore those altogether, please at least specify \"mod_value\" as a number instead.")
            end
        end
    end,
    process_loc_text = function() end,
}

SilkTouch.DragTarget{
    key = "S_buy",
    prefix_config = {key = false},
    moveable_t = function()
        return Moveable{
            T = {
                x = G.jokers.T.x,
                y = G.jokers.T.y - 0.1,
                w = G.consumeables.T.x + G.consumeables.T.w - G.jokers.T.x,
                h = G.jokers.T.h + 0.6,
            }
        }
    end,
    text = function(card)
        local buy_loc
        if card.ability.set == "Voucher" then
            buy_loc = copy_table(localize("ml_redeem_target"))
        elseif card.ability.set == "Booster" then
            buy_loc = copy_table(localize("ml_open_target"))
        else
            buy_loc = copy_table(localize("ml_buy_target"))
        end
        buy_loc[#buy_loc+1] = localize("$")..card.cost
        return buy_loc
    end,
    colour = G.C.GREEN,
    drag_condition = function(card)
        return card.area and (card.area == G.shop_jokers or card.area == G.shop_vouchers or card.area == G.shop_booster)
    end,
    active_check = function(card)
        return SilkTouch.can_buy(card)
    end,
    release_func = function(card)
        if SilkTouch.can_buy(card) then
            if card.area == G.shop_jokers then
                if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == "buy_from_shop" then
                    G.FUNCS.tut_next{}
                end
                G.FUNCS.buy_from_shop({config = {
                    ref_table = card,
                    id = "buy"
                }})
                return
            elseif card.area == G.shop_vouchers then
                G.FUNCS.use_card({config={ref_table = card}})
            elseif card.area == G.shop_booster then
                G.FUNCS.use_card({config={ref_table = card}})
            end
        end
    end,
}

SilkTouch.DragTarget{
    key = "S_buy_and_use",
    prefix_config = {key = false},
    moveable_t = function()
        return Moveable{
            T = {
                x = G.deck.T.x + 0.2,
                y = G.deck.T.y - 5.1,
                w = G.deck.T.w - 0.1,
                h = 4.5,
            }
        }
    end,
    text = function(card)
        local buy_use_loc = copy_table(localize("ml_buy_and_use_target"))
        buy_use_loc[#buy_use_loc+1] = localize("$")..card.cost
        return buy_use_loc
    end,
    colour = G.C.ORANGE,
    drag_condition = function(card)
        return card.area and (card.area == G.shop_jokers or card.area == G.shop_vouchers or card.area == G.shop_booster) and SilkTouch.can_buy_and_use(card)
    end,
    active_check = function(card)
        return SilkTouch.can_buy_and_use(card)
    end,
    release_func = function(card)
        if SilkTouch.can_buy_and_use(card) then
            G.FUNCS.buy_from_shop({config = {
                ref_table = card,
                id = "buy_and_use",
            }})
            return
        end
    end,
}

SilkTouch.DragTarget{
    key = "C_use",
    prefix_config = {key = false},
    moveable_t = function()
        return Moveable{
            T = {
                x = G.deck.T.x + 0.2,
                y = G.deck.T.y - 5.1,
                w = G.deck.T.w - 0.1,
                h = 4.5,
            }
        }
    end,
    text = function(card)
        return {localize('b_use')}
    end,
    colour = G.C.RED,
    drag_condition = function(card)
        return card.area and ((card.area == G.pack_cards
        and card.ability.consumeable and card.ability.set ~= "Planet"
        and not (booster_obj and SMODS.card_select_area(card, booster_obj) and card:selectable_from_pack(booster_obj)))
        or ((card.area == G.jokers or card.area == G.consumeables) and card.ability.consumeable))
    end,
    active_check = function(card)
        return card:can_use_consumeable()
    end,
    release_func = function(card)
        if card:can_use_consumeable() then
            G.FUNCS.use_card{config = {ref_table = card}}
        end
    end,
}

SilkTouch.DragTarget{
    key = "P_select",
    prefix_config = {key = false},
    moveable_t = function()
        return Moveable{
            T = {
                x = G.play.T.x,
                y = G.play.T.y - 2,
                w = G.play.T.w + 2,
                h = G.play.T.h + 1,
            }
        }
    end,
    text = function(card)
        local select_text = booster_obj and SMODS.get_select_text(card, booster_obj) or localize('b_select')
        return {select_text}
    end,
    colour = G.C.GREEN,
    drag_condition = function(card)
        return card.area and card.area == G.pack_cards
        and not (card.ability.consumeable and card.ability.set ~= "Planet"
        and not (booster_obj and SMODS.card_select_area(card, booster_obj) and card:selectable_from_pack(booster_obj)))
    end,
    active_check = function(card)
        return SilkTouch.can_select(card)
    end,
    release_func = function(card)
        if SilkTouch.can_select(card) then
            G.FUNCS.use_card{config={ref_table = card}}
        end
    end,
}

SilkTouch.DragTarget{
    key = "J_sell",
    prefix_config = {key = false},
    moveable_t = function()
        return Moveable{
            T = {
                x = G.consumeables.T.x + 0.3,
                y = G.consumeables.T.y - 0.2,
                w = G.consumeables.T.w - 0.3,
                h = G.consumeables.T.h + 0.6,
            }
        }
    end,
    text = function(card)
        local sell_loc = copy_table(localize('ml_sell_target'))
        sell_loc[#sell_loc+1] = localize('$')..card.sell_cost_label
        return sell_loc
    end,
    colour = G.C.GOLD,
    drag_condition = function(card)
        return card.area and card.area == G.jokers
    end,
    active_check = function(card)
        return card:can_sell_card()
    end,
    release_func = function(card)
        G.FUNCS.sell_card{config = {ref_table = card}}
    end,
}

SilkTouch.DragTarget{
    key = "C_sell",
    prefix_config = {key = false},
    moveable_t = function()
        return Moveable{
            T = {
                x = G.jokers.T.x,
                y = G.jokers.T.y - 0.2,
                w = G.jokers.T.w,
                h = G.jokers.T.h + 0.6,
            }
        }
    end,
    text = function(card)
        local sell_loc = copy_table(localize('ml_sell_target'))
        sell_loc[#sell_loc+1] = localize('$')..card.sell_cost_label
        return sell_loc
    end,
    colour = G.C.GOLD,
    drag_condition = function(card)
        return card.area and card.area == G.consumeables
    end,
    active_check = function(card)
        return card:can_sell_card()
    end,
    release_func = function(card)
        G.FUNCS.sell_card{config = {ref_table = card}}
    end,
}