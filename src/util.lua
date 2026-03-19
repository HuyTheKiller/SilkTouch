SilkTouch = {}

if G.SETTINGS.enable_action_buttons == nil then
    G.SETTINGS.enable_action_buttons = true
end
G.SETTINGS.drag_area_opacity = G.SETTINGS.drag_area_opacity or 90

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
    if _card.ability.set == "Joker" or _card.ability.set == "Planet"
    or _card.ability.set == "Default" or _card.ability.set == "Enhanced" then
        G.FUNCS.can_select_card(temp_config)
    elseif SMODS and _card.ability.consumeable then
        G.FUNCS.can_select_from_booster(temp_config)
    end
    return temp_config.config.button ~= nil
end

G.FUNCS.can_select_card = function(e)
    local card = e.config.ref_table
    local card_limit = (card.ability.card_limit or 0) - (card.ability.extra_slots_used or 0)
    local to_area = SMODS and booster_obj and SMODS.card_select_area(card, booster_obj) and card:selectable_from_pack(booster_obj)
    if card.ability.set == 'Joker' and not to_area then
        to_area = "jokers"
    end
    if (to_area and #G[to_area].cards < G[to_area].config.card_limit + card_limit)
    or ((card.ability.set == "Planet" or card.ability.set == "Default" or card.ability.set == "Enhanced") and not to_area) then
        e.config.colour = G.C.GREEN
        e.config.button = 'use_card'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

local can_use_ref = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
    if not self.ability.consumeable then return false end
    return can_use_ref(self, any_state, skip_check)
end

local can_highlight_ref = CardArea.can_highlight
function CardArea:can_highlight(card)
    if not G.SETTINGS.enable_action_buttons and self.config.type ~= 'hand' then return false end
    return can_highlight_ref(self, card)
end

local remove_from_hl_ref = CardArea.remove_from_highlighted
function CardArea:remove_from_highlighted(card, force)
    if not card then return end
    return remove_from_hl_ref(self, card, force)
end

--- Splits text by a separator.
---@param str string String to split.
---@param sep string? Separator. Defaults to whitespace.
---@return table split_text
function string.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for substr in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, substr)
    end
    return t
end

G.FUNCS.check_drag_target_active = function(e)
  if e.config.args.active_check(e.config.args.card) then
    if not e.config.pulse_border or not e.config.args.init then
      e.config.pulse_border = true
      e.config.colour = e.config.args.colour
      e.config.args.text_colour[4] = 1
      e.config.release_func = e.config.args.release_func
    end
  else
    if e.config.pulse_border or not e.config.args.init then
      e.config.pulse_border = nil
      e.config.colour = adjust_alpha(G.C.L_BLACK, 0.9)
      e.config.args.text_colour[4] = 0.5
      e.config.release_func = nil
    end
  end
  e.config.args.init = true
end

function create_drag_target_from_card(_card)
  if _card and G.STAGE == G.STAGES.RUN then
    if not G.DRAG_TARGETS then
      G.DRAG_TARGETS = {
        S_buy =         Moveable{T={x = G.jokers.T.x, y = G.jokers.T.y - 0.1, w = G.consumeables.T.x + G.consumeables.T.w - G.jokers.T.x, h = G.jokers.T.h+0.6}},
        S_buy_and_use = Moveable{T={x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w-0.1, h = 4.5}},
        C_sell =        Moveable{T={x = G.jokers.T.x, y = G.jokers.T.y - 0.2, w = G.jokers.T.w, h = G.jokers.T.h+0.6}},
        J_sell =        Moveable{T={x = G.consumeables.T.x+0.3, y = G.consumeables.T.y - 0.2, w = G.consumeables.T.w-0.3, h = G.consumeables.T.h+0.6}},
        C_use =         Moveable{T={x = G.deck.T.x + 0.2, y = G.deck.T.y - 5.1, w = G.deck.T.w-0.1, h =4.5}},
        P_select =      Moveable{T={x = G.play.T.x, y = G.play.T.y - 2, w = G.play.T.w + 2, h = G.play.T.h + 1}},
      }
      for k, v in pairs(SilkTouch.DragTargets or {}) do
        if type(v.moveable_t) == "table" then
          local init_args = {T = {}}
          for kk, vv in pairs(v.moveable_t) do
            init_args.T[kk] = 0
            if type(vv.ref_table) == "string" and type(vv.ref_value) == "string" then
              local ref_table = {}
              local table_path = string.split(vv.ref_table, ".")
              ref_table = table_path[1] == "card" and _card or _G[table_path[1]]
              for i = 2, #table_path do
                if ref_table[table_path[i]] then
                  ref_table = ref_table[table_path[i]]
                end
              end
              init_args.T[kk] = init_args.T[kk] + ref_table[vv.ref_value]
            elseif type(vv.ref_table) == "table" and type(vv.ref_value) == "table"
            and vv.ref_table[1] and vv.ref_value[1] and #vv.ref_table == #vv.ref_value
            and #vv.ref_table <= #(vv.operation_table or {}) + 1 then
              for i = 1, #vv.ref_table do
                local ref_table = {}
                local table_path = string.split(vv.ref_table[i], ".")
                ref_table = table_path[1] == "card" and _card or _G[table_path[1]]
                for ii = 2, #table_path do
                  if ref_table[table_path[ii]] then
                  ref_table = ref_table[table_path[ii]]
                  end
                end
                if i == 1 then
                  init_args.T[kk] = init_args.T[kk] + ref_table[vv.ref_value[i]]
                else
                  if vv.operation_table[i-1] == "+" or vv.operation_table[i-1] == "plus" then
                    init_args.T[kk] = init_args.T[kk] + ref_table[vv.ref_value[i]]
                  elseif vv.operation_table[i-1] == "-" or vv.operation_table[i-1] == "minus" then
                    init_args.T[kk] = init_args.T[kk] - ref_table[vv.ref_value[i]]
                  end
                end
              end
            end
            init_args.T[kk] = init_args.T[kk] + (vv.mod_value or 0)
          end
          G.DRAG_TARGETS[k] = Moveable(init_args)
        end
      end
    end

    if _card.area and (_card.area == G.shop_jokers or _card.area == G.shop_vouchers or _card.area == G.shop_booster) then
      local buy_loc = copy_table(localize((_card.area == G.shop_vouchers and 'ml_redeem_target') or (_card.area == G.shop_booster and 'ml_open_target') or 'ml_buy_target'))
      buy_loc[#buy_loc + 1] = '$'.._card.cost
      drag_target({ cover = G.DRAG_TARGETS.S_buy, colour = adjust_alpha(G.C.GREEN, (G.SETTINGS.drag_area_opacity / 100)), text = buy_loc,
        card = _card,
        active_check = function(other)
          return SilkTouch.can_buy(other)
        end,
        release_func = function(other)
          if other.area == G.shop_jokers and SilkTouch.can_buy(other) then
            if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == 'buy_from_shop' then
              G.FUNCS.tut_next{}
            end
            G.FUNCS.buy_from_shop({config = {
              ref_table = other,
              id = 'buy'
            }})
            return
          elseif other.area == G.shop_vouchers and SilkTouch.can_buy(other) then
            G.FUNCS.use_card({config={ref_table = other}})
          elseif other.area == G.shop_booster and SilkTouch.can_buy(other) then
            G.FUNCS.use_card({config={ref_table = other}})
          end
        end
      })

      if SilkTouch.can_buy_and_use(_card) then
        local buy_use_loc = copy_table(localize('ml_buy_and_use_target'))
        buy_use_loc[#buy_use_loc + 1] = '$'.._card.cost
        drag_target({ cover = G.DRAG_TARGETS.S_buy_and_use, colour = adjust_alpha(G.C.ORANGE, (G.SETTINGS.drag_area_opacity / 100)),text=buy_use_loc,
          card = _card,
          active_check = (function(other)
            return SilkTouch.can_buy_and_use(other)
          end),
          release_func = (function(other)
            if SilkTouch.can_buy_and_use(other) then
              G.FUNCS.buy_from_shop({config = {
                ref_table = other,
                id = 'buy_and_use'
              }})
              return
            end
          end)
        })
      end
    end

    if _card.area and (_card.area == G.pack_cards) then
      if _card.ability.consumeable and _card.ability.set ~= 'Planet'
      and (not SMODS or not (booster_obj and SMODS.card_select_area(_card, booster_obj) and _card:selectable_from_pack(booster_obj))) then
        drag_target({ cover = G.DRAG_TARGETS.C_use, colour = adjust_alpha(G.C.RED, (G.SETTINGS.drag_area_opacity / 100)),text = {localize('b_use')},
          card = _card,
          active_check = function(other)
            return other:can_use_consumeable()
          end,
          release_func = function(other)
            if other:can_use_consumeable() then
              G.FUNCS.use_card({config={ref_table = other}})
            end
          end
        })
      else
        drag_target({ cover = G.DRAG_TARGETS.P_select, colour = adjust_alpha(G.C.GREEN, (G.SETTINGS.drag_area_opacity / 100)), text = {localize('b_select')},
          card = _card,
          active_check = function(other)
            return SilkTouch.can_select(other)
          end,
          release_func = function(other)
            if SilkTouch.can_select(other) then
              G.FUNCS.use_card({config={ref_table = other}})
            end
          end
        })
      end
    end

    if _card.area and (_card.area == G.jokers or _card.area == G.consumeables) then
      local sell_loc = copy_table(localize('ml_sell_target'))
      sell_loc[#sell_loc + 1] = '$'..(_card.facing == 'back' and '?' or _card.sell_cost)
      drag_target({ cover = _card.area == G.consumeables and G.DRAG_TARGETS.C_sell or G.DRAG_TARGETS.J_sell, colour = adjust_alpha(G.C.GOLD, (G.SETTINGS.drag_area_opacity / 100)),text = sell_loc,
        card = _card,
        active_check = function(other)
          return other:can_sell_card()
        end,
        release_func = function(other)
          G.FUNCS.sell_card{config={ref_table=other}}
        end
      })
      if _card.ability.consumeable then
        drag_target({ cover = G.DRAG_TARGETS.C_use, colour = adjust_alpha(G.C.RED, (G.SETTINGS.drag_area_opacity / 100)),text = {localize('b_use')},
          card = _card,
          active_check = function(other)
            return other:can_use_consumeable()
          end,
          release_func = function(other)
            if other:can_use_consumeable() then
              G.FUNCS.use_card({config={ref_table = other}})
              if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.button_listen == 'use_card' then
                G.FUNCS.tut_next{}
              end
            end
          end
        })
      end
    end

    for k, v in pairs(SilkTouch.DragTargets or {}) do
      if v.drag_condition and v.drag_condition(_card) then
        drag_target{
          cover = type(v.moveable_t) == "string" and G.DRAG_TARGETS[v.moveable_t] or G.DRAG_TARGETS[k],
          colour = adjust_alpha(v.colour, (G.SETTINGS.drag_area_opacity / 100)),
          text = type(v.text) == "function" and v.text(_card),
          card = _card,
          active_check = v.active_check,
          release_func = v.release_func,
          emboss = v.emboss,
          align = v.align,
          offset = v.offset,
        }
      end
    end
  end
end

function drag_target(args)
  args = args or {}
  if args.card and args.card.area then args.card.area:remove_from_highlighted(args.card) end
  args.text = args.text or {'BUY'}
  args.colour = copy_table(args.colour or G.C.UI.TRANSPARENT_DARK)
  args.cover = args.cover or nil
  args.emboss = args.emboss or nil
  args.active_check = args.active_check or function(other) return true end
  args.release_func = args.release_func or function(other) G.DEBUG_VALUE = 'WORKIN' end
  args.text_colour = copy_table(G.C.WHITE)
  args.uibox_config = {
    align = args.align or 'tli',
    offset = args.offset or {x=0,y=0},
    major = args.cover or args.major or nil,
  }

  local drag_area_width =(args.T and args.T.w or args.cover and args.cover.T.w or 0.001) + (args.cover_padding or 0)

  local text_rows = {}
  for k, v in ipairs(args.text) do
    text_rows[#text_rows+1] = {n=G.UIT.R, config={align = "cm", padding = 0.05, maxw = drag_area_width-0.1}, nodes={{n=G.UIT.O, config={object = DynaText({scale = args.scale, string = v, maxw = args.maxw or (drag_area_width-0.1), colours = {args.text_colour},float = true, shadow = true, silent = not args.noisy, 0.7, pop_in = 0, pop_in_rate = 6, rotate = args.rotate or nil})}}}}
  end

  args.DT = UIBox{
    T = {0,0,0,0},
    definition =
      {n=G.UIT.ROOT, config = {align = 'cm',  args = args, can_collide = true, hover = true, release_func = args.release_func, func = 'check_drag_target_active', minw = drag_area_width, minh = (args.cover and args.cover.T.h or 0.001) + (args.cover_padding or 0), padding = 0.03, r = 0.1, emboss = args.emboss, colour = G.C.CLEAR}, nodes=text_rows},
    config = args.uibox_config
  }
  args.DT.attention_text = true

  if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.highlights then
    G.OVERLAY_TUTORIAL.highlights[#G.OVERLAY_TUTORIAL.highlights+1] = args.DT
  end

  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0,
    blockable = false,
    blocking = false,
    func = function()
      if not G.CONTROLLER.dragging.target and args.DT then
        if G.OVERLAY_TUTORIAL and G.OVERLAY_TUTORIAL.highlights then
          for k, v in ipairs(G.OVERLAY_TUTORIAL.highlights) do
            if args.DT == v then
              table.remove(G.OVERLAY_TUTORIAL.highlights, k)
              break
            end
          end
        end
        args.DT:remove()
        return true
      end
    end
    }))
end