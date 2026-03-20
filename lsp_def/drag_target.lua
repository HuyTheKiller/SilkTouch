---@meta

---@class MoveableArg: table
---@field ref_table? string|string[]
---@field ref_value? string|string[]
---@field operation_table? string[]
---@field mod_value? number

---@class SilkTouch.DragTarget: SMODS.GameObject
---@field moveable_t? string|{x: MoveableArg|table, y: MoveableArg|table, w: MoveableArg|table, h: MoveableArg|table} The string key of a predefined Moveable cover, otherwise a Moveable setup.
---@field text? fun(card: table|Card): table A function returning a table of localized texts.
---@field colour? number[] Active colour for this drag area.
---@field drag_condition? fun(card: table|Card): boolean Used to check if dragging a card shows the drag area or not.
---@field active_check? fun(card: table|Card): boolean Used to check if releasing inside drag area may trigger `release_func`.
---@field release_func? fun(card: table|Card) Used to perform an action when released inside drag area.
---@field emboss? number See [Steamodded UI guide](https://github.com/Steamodded/smods/wiki/UI-Guide#node-configuration)
---@field align? string See [Steamodded UI guide](https://github.com/Steamodded/smods/wiki/UI-Guide#node-configuration)
---@field offset? {x: number, y: number} How far away from the alignment origin this drag area is. Simply use `moveable_t` for finer control over the positions.
---@field super? SMODS.GameObject|table Parent class.
---@field obj_table? table<string, SilkTouch.DragTarget|table> Table of objects registered to this class.
---@field obj_buffer? string[] Array of keys to all objects registered to this class.
---@field __call? fun(self: SilkTouch.DragTarget|table, o: SilkTouch.DragTarget|table): nil|table|SilkTouch.DragTarget
---@field extend? fun(self: SilkTouch.DragTarget|table, o: SilkTouch.DragTarget|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SilkTouch.DragTarget|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SilkTouch.DragTarget|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SilkTouch.DragTarget|table) Registers the object.
---@field check_dependencies? fun(self: SilkTouch.DragTarget|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SilkTouch.DragTarget|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SilkTouch.DragTarget|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SilkTouch.DragTarget|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SilkTouch.DragTarget|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SilkTouch.DragTarget|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SilkTouch.DragTarget|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SilkTouch.DragTarget|table, key: string, obj: SilkTouch.DragTarget|table, silent?: boolean): nil|table|SilkTouch.DragTarget Takes control of vanilla objects. Child class must have get_obj for this to function.
---@field get_obj? fun(self: SilkTouch.DragTarget|table, key: string): SilkTouch.DragTarget|table? Returns an object if one matches the `key`.
---@overload fun(self: SilkTouch.DragTarget): SilkTouch.DragTarget
SilkTouch.DragTarget = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SilkTouch.DragTarget|table>
SilkTouch.DragTargets = {}