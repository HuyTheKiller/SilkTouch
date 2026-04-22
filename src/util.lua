SilkTouch = {
    OS = love.system.getOS(),
}

function Node:can_long_press() end

function Node:can_hover_on_drag() return true end

function Card:can_long_press()
    if self.area and ((self.area == G.hand) or (self.area == G.play) or
    (self.area == G.deck and self.area.cards[1] == self)) then
        return true
    end
end

function Card:can_hover_on_drag()
    return false
end

local controller_upd_axis = Controller.update_axis
function Controller:update_axis(dt)
    local ret = controller_upd_axis(self, dt)
    if SilkTouch.force_touch then
        ret = "touch"
    end
    return ret
end

if G.SETTINGS.enable_action_buttons == nil then
    G.SETTINGS.enable_action_buttons = not (SilkTouch.OS == 'Android' or SilkTouch.OS == 'iOS')
end
if G.SETTINGS.enable_dragging == nil then
    G.SETTINGS.enable_dragging = true
end
if G.SETTINGS.enable_drag_select == nil then
    G.SETTINGS.enable_drag_select = SilkTouch.OS == 'Android' or SilkTouch.OS == 'iOS' or not Handy
end
G.SETTINGS.drag_area_opacity = G.SETTINGS.drag_area_opacity or 90

function SilkTouch.config_tab()
    local dragging_label = localize("ph_enable_dragging") ~= "ERROR"
    and localize("ph_enable_dragging") or "Enable Dragging"
    local action_button_label = localize("ph_enable_action_button") ~= "ERROR"
    and localize("ph_enable_action_button") or "Enable Actions Buttons"
    local drag_to_select_deselect_label = localize("ph_drag_to_select_deselect") ~= "ERROR"
    and localize("ph_drag_to_select_deselect") or "Enable drag to select/deselect from hand area"
    local drag_area_op_label = localize("ph_drag_area_op") ~= "ERROR"
    and localize("ph_drag_area_op") or "Drag Area Opacity"
    return {n=G.UIT.ROOT, config={align = "cm", padding = 0.05, colour = G.C.CLEAR}, nodes={
        create_toggle({label = dragging_label, ref_table = G.SETTINGS, ref_value = 'enable_dragging',
        callback = function()
            for _, area in ipairs(G.I.CARDAREA) do
                area:set_ranks()
            end
        end}),
        create_toggle({label = action_button_label, ref_table = G.SETTINGS, ref_value = 'enable_action_buttons'}),
        create_toggle({label = drag_to_select_deselect_label, ref_table = G.SETTINGS, ref_value = 'enable_drag_select'}),
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

G.FUNCS.can_select_card = function(e)
    local card = e.config.ref_table
    local card_limit = (card.ability.card_limit or 0) - (card.ability.extra_slots_used or 0)
    local to_area = SMODS and booster_obj and SMODS.card_select_area(card, booster_obj) and card:selectable_from_pack(booster_obj)
    if card.ability.set == 'Joker' and not to_area then
        to_area = "jokers"
    end
    if (to_area and #G[to_area].cards < G[to_area].config.card_limit + card_limit)
    or (card.ability.set == "Planet" and not to_area) or card.ability.set == "Default" or card.ability.set == "Enhanced" then
        e.config.colour = G.C.GREEN
        e.config.button = 'use_card'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

function G.UIDEF.card_focus_ui(card)
  local card_width = card.T.w + (card.ability.consumeable and -0.1 or card.ability.set == 'Voucher' and -0.16 or 0)

  local playing_card_colour = copy_table(G.C.WHITE)
  playing_card_colour[4] = 1.5
  if G.hand and card.area == G.hand then ease_value(playing_card_colour, 4, -1.5, nil, 'REAL',nil, 0.2, 'quad') end

  local tcnx, tcny = card.T.x + card.T.w/2 - G.ROOM.T.w/2, card.T.y + card.T.h/2 - G.ROOM.T.h/2

  local base_background = UIBox{
    T = {card.VT.x,card.VT.y,0,0},
    definition =
      (not G.hand or card.area ~= G.hand) and {n=G.UIT.ROOT, config = {align = 'cm', minw = card_width + 0.3, minh = card.T.h + 0.3, r = 0.1, colour = adjust_alpha(G.C.BLACK, 0.7), outline_colour = lighten(G.C.JOKER_GREY, 0.5), outline = 1.5, line_emboss = 0.8}, nodes={
        {n=G.UIT.R, config={id = 'ATTACH_TO_ME'}, nodes={}}
      }} or
      {n=G.UIT.ROOT, config = {align = 'cm', minw = card_width, minh = card.T.h, r = 0.1, colour = playing_card_colour}, nodes={
        {n=G.UIT.R, config={id = 'ATTACH_TO_ME'}, nodes={}}
      }},
    config = {
      align = 'cm',
      offset = {x= 0.007*tcnx*card.T.w, y = 0.007*tcny*card.T.h},
      parent = card,
      r_bond = (not G.hand or card.area ~= G.hand) and 'Weak' or 'Strong'
    }
  }

  base_background.set_alignment = function()
    local cnx, cny = card.T.x + card.T.w/2 - G.ROOM.T.w/2, card.T.y + card.T.h/2 - G.ROOM.T.h/2
    Moveable.set_alignment(card.children.focused_ui, {offset = {x= 0.007*cnx*card.T.w, y = 0.007*cny*card.T.h}})
  end

  local base_attach = base_background:get_UIE_by_ID('ATTACH_TO_ME')
  base_attach.config.align_count = base_attach.config.align_count or {left = 0, right = 0}

  local passed = {}

  for k, v in pairs(SilkTouch.ControllerButtons or {}) do
    if v.focus_condition and v.focus_condition(card) then
      local side = v.get_side and v.get_side(card) or v.side
      if side == "left" or side == "right" then
        base_attach.config.align_count[side] = base_attach.config.align_count[side] + 1
        table.insert(passed, {[k] = v, silktouch_order = v.button_order})
      end
    end
  end
  table.sort(passed, function(a, b) return a.silktouch_order < b.silktouch_order end)
  for i, button in ipairs(passed) do
    for k, v in pairs(button) do
      if k ~= "silktouch_order" then
        local side = v.get_side and v.get_side(card) or v.side
        base_attach.children[k] = G.UIDEF.card_focus_button{
          card = card, parent = base_attach, type = k, func = v.active_check_cb, button = v.press_func_cb,
          card_width = card_width*v.card_width_coeffi, max_index = base_attach.config.align_count[side], index = i
        }
      end
    end
  end

  if not SMODS then
    --The card UI can have BUY, REDEEM, USE, and SELL buttons depending on the context of the card
    if card.area == G.shop_jokers and G.shop_jokers then --Add a buy button
      local buy_and_use = nil
      if card.ability.consumeable then
        base_attach.children.buy_and_use = G.UIDEF.card_focus_button{
          card = card, parent = base_attach, type = 'buy_and_use',
          func = 'can_buy_and_use', button = 'buy_from_shop', card_width = card_width
        }
        buy_and_use = true
      end
      base_attach.children.buy = G.UIDEF.card_focus_button{
        card = card, parent = base_attach, type = 'buy',
        func = 'can_buy', button = 'buy_from_shop', card_width = card_width, buy_and_use = buy_and_use
      }
    end
    if card.area == G.shop_vouchers and G.shop_vouchers then --Add a redeem button
      base_attach.children.redeem = G.UIDEF.card_focus_button{
        card = card, parent = base_attach, type = 'redeem',
        func = 'can_redeem', button = 'redeem_from_shop', card_width = card_width
      }
    end
    if card.area == G.shop_booster and G.shop_booster then --Add a redeem button
      base_attach.children.redeem = G.UIDEF.card_focus_button{
        card = card, parent = base_attach, type = 'open',
        func = 'can_open', button = 'open_booster', card_width = card_width*0.85
      }
    end
    if ((card.area == G.consumeables and G.consumeables) or (card.area == G.pack_cards and G.pack_cards)) and
    card.ability.consumeable then --Add a use button
      base_attach.children.use = G.UIDEF.card_focus_button{
        card = card, parent = base_attach, type = 'use',
        func = 'can_use_consumeable', button = 'use_card', card_width = card_width
      }
    end
    if (card.area == G.pack_cards and G.pack_cards) and not card.ability.consumeable then --Add a use button
      base_attach.children.use = G.UIDEF.card_focus_button{
        card = card, parent = base_attach, type = 'select',
        func = 'can_select_card', button = 'use_card', card_width = card_width
      }
    end
    if (card.area == G.jokers and G.jokers or card.area == G.consumeables and G.consumeables) and G.STATE ~= G.STATES.TUTORIAL then --Add a sell button
      base_attach.children.sell = G.UIDEF.card_focus_button{
        card = card, parent = base_attach, type = 'sell',
        func = 'can_sell_card', button = 'sell_card', card_width = card_width
      }
    end
  end

  local realignment = {left = {}, right = {}}
  for _, v in pairs(base_attach.children) do
    if v.silktouch_utils and (v.silktouch_utils.max_index or 1) > 1 then
      table.insert(realignment[v.silktouch_utils.side], v)
    end
  end

  local sort = function(a, b) return (a and a.index or 0) < (b and b.index or 0) end
  if #realignment.left > 1 then table.sort(realignment.left, sort) end
  if #realignment.right > 1 then table.sort(realignment.right, sort) end

  local total_height = {left = 0, right = 0}
  for side, items in pairs(realignment) do
    if #items > 1 then
      for i, v in ipairs(items) do
        total_height[side] = total_height[side] + v.UIRoot.children[1].children[1].T.h
        if i > 1 then
          total_height[side] = total_height[side] + 0.2
        end
      end
    end
  end
  for side, items in pairs(realignment) do
    if #items > 1 then
      local leftmost_free = 0
      for i, v in ipairs(items) do
        if i == 1 then
          leftmost_free = -total_height[side]/2
        end
        v.alignment.offset.y = leftmost_free + v.UIRoot.children[1].children[1].T.h/2
        leftmost_free = leftmost_free + v.UIRoot.children[1].children[1].T.h + 0.2
      end
    end
  end

  return base_background
end

function G.UIDEF.card_focus_button(args)
  if not args then return end

  local button_contents = {}
  if not SMODS then
    if args.type == 'sell' then
      button_contents =
      {n=G.UIT.C, config={align = "cl"}, nodes={
        {n=G.UIT.R, config={align = "cl", maxw = 1}, nodes={
          {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
        }},
        {n=G.UIT.R, config={align = "cl"}, nodes={
          {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
          {n=G.UIT.T, config={ref_table = args.card, ref_value = 'sell_cost_label', colour = G.C.WHITE, scale = 0.55, shadow = true}}
        }}
      }}
    elseif args.type == 'buy' then
      button_contents = {n=G.UIT.T, config={text = localize('b_buy'),colour = G.C.WHITE, scale = 0.5}}
    elseif args.type == 'select' then
      button_contents = {n=G.UIT.T, config={text = localize('b_select'),colour = G.C.WHITE, scale = 0.3}}
    elseif args.type == 'redeem' then
      button_contents = {n=G.UIT.T, config={text = localize('b_redeem'),colour = G.C.WHITE, scale = 0.5}}
    elseif args.type == 'open' then
      button_contents = {n=G.UIT.T, config={text = localize('b_open'),colour = G.C.WHITE, scale = 0.5}}
    elseif args.type == 'use' then
      button_contents = {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.WHITE, scale = 0.5}}
    elseif args.type == 'buy_and_use' then
      button_contents =
      {n=G.UIT.C, config={align = "cr"}, nodes={
        {n=G.UIT.R, config={align = "cr", maxw = 1}, nodes={
          {n=G.UIT.T, config={text = localize('b_buy'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
        }},
        {n=G.UIT.R, config={align = "cr", maxw = 1}, nodes={
          {n=G.UIT.T, config={text = localize('b_and_use'),colour = G.C.WHITE, scale = 0.3, shadow = true}},
        }}
      }}
    end
  end

  if not next(button_contents) then
    for k, v in pairs(SilkTouch.ControllerButtons or {}) do
      if args.type == k then
        local side = v.get_side and v.get_side(args.card) or v.side
        button_contents = {n=G.UIT.C, config={align = side == "left" and "cl" or "cr"}, nodes={}}
        local text_table = v.text and v.text(args.card) or {}
        local text_scale_table = v.text_scale and v.text_scale()
        if text_table.single_text then
          if type(text_table[1]) == "table" and text_table[1].ref_table and text_table[1].ref_value then
            button_contents = {n=G.UIT.T, config={ref_table = text_table[1].ref_table, ref_value = text_table[1].ref_value,
            colour = G.C.WHITE, scale = text_scale_table[1]}}
          else
            button_contents = {n=G.UIT.T, config={text = text_table[1], colour = G.C.WHITE, scale = text_scale_table[1]}}
          end
        else
          for i, text in ipairs(text_table) do
            local node = {n=G.UIT.R, config={align = side == "left" and "cl" or "cr", maxw = 1}, nodes={}}
            if type(text) == "table" and type(text_scale_table[i]) == "table" then
              node.config.maxw = nil
              for j, inner_text in ipairs(text) do
                local inner_node
                if type(inner_text) == "table" and inner_text.ref_table and inner_text.ref_value then
                  inner_node = {n=G.UIT.T, config={ref_table = inner_text.ref_table, ref_value = inner_text.ref_value,
                  colour = G.C.WHITE, scale = text_scale_table[i][j] or 0.4, shadow = true}}
                else
                  inner_node = {n=G.UIT.T, config={text = inner_text, colour = G.C.WHITE,
                  scale = text_scale_table[i][j] or 0.4, shadow = true}}
                end
                table.insert(node.nodes, inner_node)
              end
            elseif type(text) == "table" and text.ref_table and text.ref_value then
              local inner_node = {n=G.UIT.T, config={ref_table = text.ref_table, ref_value = text.ref_value,
              colour = G.C.WHITE, scale = text_scale_table[i] or 0.4, shadow = true}}
              table.insert(node.nodes, inner_node)
            else
              local inner_node = {n=G.UIT.T, config={text = text, colour = G.C.WHITE, scale = text_scale_table[i] or 0.4, shadow = true}}
              table.insert(node.nodes, inner_node)
            end
            table.insert(button_contents.nodes, node)
          end
        end

        local minw = v.minw or 1
        local minh = v.minh or (0.5 + 0.5*(#(button_contents.nodes or {0})))

        local uibox = UIBox{
          T = {args.card.VT.x,args.card.VT.y,0,0},
          definition =
            {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes={
              {n=G.UIT.R, config={id = k, ref_table = args.card, ref_parent = args.parent, align = side == "left" and 'cl' or 'cr', colour = G.C.BLACK, shadow = true, r = 0.08, func = args.func, one_press = true, button = args.button, focus_args = {type = 'none'}, hover = true}, nodes={
                {n=G.UIT.R, config={align = side == "left" and 'cl' or 'cr', minw = minw, minh = minh, padding = 0.08,
                    focus_args = {button = v.button_key, scale = 0.55, orientation = side == "left" and 'tli' or 'tri', offset = {x = side == "left" and 0.1 or -0.1, y = 0}, type = 'none'},
                    func = 'set_button_pip'}, nodes={
                  {n=G.UIT.R, config={align = "cm", minh = 0.3}, nodes={}},
                  {n=G.UIT.R, config={align = "cm"}, nodes={
                    #(button_contents.nodes or {}) > 1 and not v.minh and {n=G.UIT.C, config={align = "cm",minw = 0.2, minh = 0.6}, nodes={}} or nil,
                    {n=G.UIT.C, config={align = "cm", maxw = 1}, nodes={
                      button_contents
                    }},
                    #(button_contents.nodes or {}) > 1 and not v.minh and {n=G.UIT.C, config={align = "cm",minw = 0.2, minh = 0.6}, nodes={}} or nil,
                  }}
                }}
              }}
            }},
          config = {
            align = side == "left" and 'cl' or 'cr',
            offset = {x=(side == "left" and -1 or 1)*((args.card_width or 0) - 0.17 - args.card.T.w/2),y=args.type == 'buy_and_use' and 0.6 or (args.buy_and_use) and -0.6 or 0},
            parent = args.parent,
          }
        }
        uibox.silktouch_utils = {
          side = side, index = args.index,
          max_index = args.max_index
        }
        return uibox
      end
    end
  end

  return UIBox{
    T = {args.card.VT.x,args.card.VT.y,0,0},
    definition =
      {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={id = args.type == 'buy_and_use' and 'buy_and_use' or nil, ref_table = args.card, ref_parent = args.parent, align =  args.type == 'sell' and 'cl' or 'cr', colour = G.C.BLACK, shadow = true, r = 0.08, func = args.func, one_press = true, button = args.button, focus_args = {type = 'none'}, hover = true}, nodes={
          {n=G.UIT.R, config={align = args.type == 'sell' and 'cl' or 'cr', minw = 1 + (args.type == 'select' and 0.1 or 0), minh = args.type == 'sell' and 1.5 or 1, padding = 0.08,
              focus_args = {button = args.type == 'sell' and 'leftshoulder' or args.type == 'buy_and_use' and 'leftshoulder' or 'rightshoulder', scale = 0.55, orientation = args.type == 'sell' and 'tli' or 'tri', offset = {x = args.type == 'sell' and 0.1 or -0.1, y = 0}, type = 'none'},
              func = 'set_button_pip'}, nodes={
            {n=G.UIT.R, config={align = "cm", minh = 0.3}, nodes={}},
            {n=G.UIT.R, config={align = "cm"}, nodes={
              args.type ~= 'sell' and {n=G.UIT.C, config={align = "cm",minw = 0.2, minh = 0.6}, nodes={}} or nil,
              {n=G.UIT.C, config={align = "cm", maxw = 1}, nodes={
                button_contents
              }},
              args.type == 'sell' and {n=G.UIT.C, config={align = "cm",minw = 0.2, minh = 0.6}, nodes={}} or nil,
            }}
          }}
        }}
      }},
    config = {
      align = args.type == 'sell' and 'cl' or 'cr',
      offset = {x=(args.type == 'sell' and -1 or 1)*((args.card_width or 0) - 0.17 - args.card.T.w/2),y=args.type == 'buy_and_use' and 0.6 or (args.buy_and_use) and -0.6 or 0},
      parent = args.parent,
    }
  }
end

local can_use_ref = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
    if not self.ability.consumeable then return false end
    return can_use_ref(self, any_state, skip_check)
end

local can_highlight_ref = CardArea.can_highlight
function CardArea:can_highlight(card)
    if not G.SETTINGS.enable_action_buttons and G.SETTINGS.enable_dragging
    and self.config.type ~= 'hand' then return false end
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
      local buy_loc = copy_table(localize((_card.ability.set == "Voucher" and 'ml_redeem_target') or (_card.ability.set == "Booster" and 'ml_open_target') or 'ml_buy_target'))
      buy_loc[#buy_loc + 1] = localize('$').._card.cost
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
        buy_use_loc[#buy_use_loc + 1] = localize('$').._card.cost
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
        local select_text = localize('b_select')
        if SMODS and booster_obj then
          select_text = SMODS.get_select_text(_card, booster_obj) or localize('b_select')
        end
        drag_target({ cover = G.DRAG_TARGETS.P_select, colour = adjust_alpha(G.C.GREEN, (G.SETTINGS.drag_area_opacity / 100)), text = {select_text},
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
      sell_loc[#sell_loc + 1] = localize('$').._card.sell_cost_label
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
          cover = type(v.moveable_t) == "string" and G.DRAG_TARGETS[v.moveable_t] or G.DRAG_TARGETS[k] or G.DRAG_TARGETS.S_buy,
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
  if not G.SETTINGS.enable_dragging then return end
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