---@meta

---@class SilkTouch.ControllerButton: SMODS.GameObject
---@field side? "left"|"right" Where to align this button. Due to limited choices, only "left" and "right" are supported.
---@field get_side? fun(card: table|Card): "left"|"right" Used for finer control over which side this button will align.
---@field button_key? "a"|"b"|"x"|"y"|"leftshoulder"|"rightshoulder"|"triggerleft"|"triggerright"|"start"|"back"|"dpadup"|"dpadright"|"dpaddown"|"dpadleft"|"left"|"right"|"leftstick"|"rightstick"|"guide" The key to a button/stick on the controller.
---@field button_order? integer Alignment order for this button (lower number means higher order from top to bottom).
---@field text? fun(card: table|Card): table|{single_text?: true} A function returning a table of localized texts. Append `single_text` field to the return table to shorten node creation.
---@field text_scale? fun(): table A function returning a table of text scales for the above table.
---@field colour? number[] Active colour for this button. Can be ignored if `active_check_cb` is defined.
---@field card_width_coeffi? number The coefficient for the focus box width of the card this button is on.
---@field minw? number Minimum width for this button.
---@field minh? number Minimum height for this button.
---@field focus_condition? fun(card: table|Card): boolean Used to check if a focused card shows the button or not.
---@field active_check? fun(card: table|Card): boolean Used to check if this button can be pressed. Can be ignored if `active_check_cb` is defined.
---@field press_func? fun(card: table|Card) Used to perform an action when this button is pressed. Can be ignored if `press_func_cb` is defined.
---@field active_check_cb? string If defined, use G.FUNCS[active_check_cb] to check instead of automatically defining a new function. Must be defined alongside `press_func_cb`.
---@field press_func_cb? string If defined, use G.FUNCS[press_func_cb] to check instead of automatically defining a new function. Must be defined alongside `active_check_cb`.
---@field super? SMODS.GameObject|table Parent class.
---@field obj_table? table<string, SilkTouch.ControllerButton|table> Table of objects registered to this class.
---@field obj_buffer? string[] Array of keys to all objects registered to this class.
---@field __call? fun(self: SilkTouch.ControllerButton|table, o: SilkTouch.ControllerButton|table): nil|table|SilkTouch.ControllerButton
---@field extend? fun(self: SilkTouch.ControllerButton|table, o: SilkTouch.ControllerButton|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SilkTouch.ControllerButton|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SilkTouch.ControllerButton|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SilkTouch.ControllerButton|table) Registers the object.
---@field check_dependencies? fun(self: SilkTouch.ControllerButton|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SilkTouch.ControllerButton|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SilkTouch.ControllerButton|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SilkTouch.ControllerButton|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SilkTouch.ControllerButton|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SilkTouch.ControllerButton|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SilkTouch.ControllerButton|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SilkTouch.ControllerButton|table, key: string, obj: SilkTouch.ControllerButton|table, silent?: boolean): nil|table|SilkTouch.ControllerButton Takes control of vanilla objects. Child class must have get_obj for this to function.
---@field get_obj? fun(self: SilkTouch.ControllerButton|table, key: string): SilkTouch.ControllerButton|table? Returns an object if one matches the `key`.
---@overload fun(self: SilkTouch.ControllerButton): SilkTouch.ControllerButton
SilkTouch.ControllerButton = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SilkTouch.ControllerButton|table>
SilkTouch.ControllerButtons = {}