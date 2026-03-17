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
        assert(type(self.moveable_t) == "string" or type(self.moveable_t) == "table", ("Field \"moveable_t\" must be a string or a table."))
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