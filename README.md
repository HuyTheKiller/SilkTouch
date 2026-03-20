# Silk Touch
A Balatro mod that brings touch controls from mobile version to PC/Mac.

There are 2 other mods - [Sticky Fingers](https://github.com/eramdam/sticky-fingers) and [MobileLikeDragging](https://github.com/jfmmm/BalatroMobileLikeDragging) - that already do the same thing. What sets this mod apart is that it provides a full-fledged API, allowing other mods to easily define new drag areas and/or use existing ones, all without a Pull Request hassle from Sticky Fingers or vanilla-hardcoded nature of MobileLikeDragging.

# How to use this mod
In your mod code, put a check to see if the player has SilkTouch installed.
```lua
if SilkTouch then
    SilkTouch.DragTarget{
        key = "my_drag_area",
        -- More on that below
    }
end
```
You can then start adding your own drag areas. See below for documentation.

### What's new in v1.1:
This version is packed with a brand new API: `SilkTouch.ControllerButton`, allowing other mods to append buttons meant for controller on a card.

# API Documentation: `SilkTouch.DragTarget`

- **Required parameters:**
	- `key`
- **Optional parameters** *(defaults)*:
    - `moveable_t`: A string key to an existing drag area, or a table containing a Moveable setup
        - Expects a string matching any of the following keys:
        ```lua
        G.DRAG_TARGETS = {
            S_buy, -- Standard buy area (overlayed on G.jokers plus G.consumeables). Text varies depending on card type (Voucher, Booster or generic).
            S_buy_and_use, -- Buy-and-use area (above G.deck). Used for consumables that can be used right after purchase.
            C_sell, -- Consumable's sell area (overlayed on G.jokers).
            J_sell, -- Joker's sell area (overlayed on G.consumeables).
            C_use, -- Consumable's use area (above G.deck).
            P_select, -- Select area (between G.jokers and G.hand). Used for selecting jokers and using planet cards in booster packs.
            modprefix_key, -- A custom drag target, defined by a Moveable setup (more on that below).
        }
        ```
        - Or, expects the following table format:
        ```lua
        {
            moveable_t = {
                x = {ref_table = "G.jokers.T", ref_value = "x"}, -- Standard usage with ref_table and ref_value.
                y = {ref_table = "G.jokers.T", ref_value = "y", mod_value = -0.1}, -- Modify the result with a number.
                w = {
                    -- A more complicated case where you need to combine multiple references at once.
                    -- There's a limit to operation_table: only pluses (+) and minuses (-) are supported.
                    -- The example has been realigned to improve comprehensibility.
                    ref_table = {"G.consumeables.T", "G.consumeables.T", "G.jokers.T"  },
                    ref_value = {                 "x",                "w",          "x"},
                    operation_table = {             "+",                "-"            },
                },
                h = {mod_value = 4.5}, -- Simply specify a number.
            },
        }
        ```
    - `text`: A function returning a table of localized texts
        - Expects a function like this:
        ```lua
        {
            text = function(card)
                -- Example text for a joker or consumable
                local buy_loc = copy_table(localize('ml_buy_target'))
                buy_loc[#buy_loc+1] = '$'..card.cost
                return buy_loc -- {"Buy", "$3"}
            end
        }
        ```
    - `colour = G.C.UI.TRANSPARENT_DARK` - The active colour for the drag area,
    - `drag_condition`: A function to check if dragging a card shows the drag area or not
        - Expects a function like this:
        ```lua
        {
            drag_condition = function(card)
                -- Example condition for consumable cards in a booster pack to reveal consumable's use area (except Planet cards)
                return card.area and card.area == G.pack_cards and card.ability.consumeable and card.ability.set ~= 'Planet'
            end
        }
        ```
    - `active_check`: A function to check if releasing inside drag area may trigger `release_func` (more on that below)
        - Expects a function like this:
        ```lua
        {
            active_check = function(card)
                -- Example condition for consumable cards to be useable or not
                return card:can_use_consumeable()
            end
        }
        ```
    - `release_func`: A function to perform an action when released inside drag area
        - Expects a function like this:
        ```lua
        {
            release_func = function(card)
                -- Example action for using consumable cards
                if card:can_use_consumeable() then
                    G.FUNCS.use_card({config={ref_table = card}})
                end
            end
        }
        ```

# API Documentation: `SilkTouch.ControllerButton`

- **Required parameters:**
	- `key`
- **Optional parameters** *(defaults)*:
    - `side = "left"`: The side the button will be on when it's available, either `"left"` or `"right"`
    - `button_key = "leftshoulder"`: The key to the controller input needed to activate this button
        - Expects any of the following keys:
        ```lua
        {
            "a", "b", "x", "y", "leftshoulder", "rightshoulder",
            "triggerleft", "triggerright", "start", "back",
            "dpadup", "dpadright", "dpaddown", "dpadleft",
            "left", "right", "leftstick", "rightstick", "guide",
        }
        ```
    - `button_order = 1`: The order of this button when aligning multiple ones on either side (smallest order is placed on top)
        - It's recommended for your custom buttons to start at 2
    - `text`: A function returning a table of localized texts
        - Expects a function like this:
        ```lua
        {
            -- Example 1: single line of text
            text = function(card)
                return {
                    localize('b_buy'),  -- The only line
                    single_text = true, -- Set this field to true (optional but recommended)
                }
            end,
            -- Example 2: multiple lines of text
            text = function(card)
                return {
                    localize('b_buy'),     -- The first line
                    localize('b_and_use'), -- The second line
                }
            end,
            -- Example 3: multiple text combinations on single lines
            text = function(card)
                return {
                    localize('b_sell'), -- The first line
                    {                   -- The second line
                        localize('$'),  -- First piece of text on second line
                        -- Second piece of text on second line
                        -- any string text mentioned above can be replaced with ref_table and ref_value
                        {ref_table = card, ref_value = "sell_cost_label"},
                    },
                }
            end
        }
        ```
    - `text_scale`: A function returning a table of text scales for the return table of `text` above
        - Expects a function like this:
        ```lua
        {
            -- This is used for Example 3 above
            text_scale = function()
                return {
                    0.4, -- First line
                    {0.4, 0.55}, -- Second line, used for each piece of text separately
                }
            end
        }
        ```
    - `colour = G.C.GREEN`: Active colour for this button
    - `card_width_coeffi = 1`: The coefficient for the focus box width of the card this button is on, mainly used for Booster Packs
    - `minw`, `minh`: Minimum width and height of this button
    - `focus_condition`: A function to check if a focused card shows the button or not
        - Expects a function like this:
        ```lua
        {
            focus_condition = function(card)
                -- Example check if it's a voucher to show the REDEEM button
                -- Make sure it only works in shop areas (*cough* Cryptid Equilibrium Deck *cough*)
                return G.STAGE == G.STAGES.RUN and card.area and (card.area == G.shop_jokers
                or card.area == G.shop_vouchers or card.area == G.shop_booster)
                and card.ability.set == "Voucher"
            end
        }
        ```
    - `active_check`: A function to check if activating this button may trigger `press_func` (more on that below)
        - Expects a function like this:
        ```lua
        {
            active_check = function(card)
                -- Example condition for consumable cards to be useable or not
                return card:can_use_consumeable()
            end
        }
        ```
    - `press_func`: A function to perform an action when this button is activated
        - Expects a function like this:
        ```lua
        {
            press_func = function(card)
                -- Example action for using consumable cards
                if card:can_use_consumeable() then
                    G.FUNCS.use_card({config={ref_table = card}})
                end
            end
        }
        ```
    - `active_check_cb`, `press_func_cb`: String keys to the respective function in `G.FUNCS` for handling whether a button can be activated and the action it will perform, must be defined together (highly recommended)
        - If these two are defined, `colour`, `active_check` and `press_func` may be ignored
