---@type data.CustomInputPrototype
local spectateNextControl = {
    type = "custom-input";
    name = "stalker-spectate_next";
    key_sequence = "RIGHT";
}

---@type data.CustomInputPrototype
local spectatePrevControl = {
    type = "custom-input";
    name = "stalker-spectate_previous";
    key_sequence = "LEFT";
}

data:extend({spectateNextControl, spectatePrevControl})
