local LocaleKeys = require("scripts.LocaleKeys");

---@param color Color
local function formatColor(color)
    return color.r .. "," .. color.g .. "," .. color.b;
end

local function sendMessage(obj, localeId, vars, format)
    obj.print({"stalker.messages"..localeId, vars}, format)
end

-- replace - with _
-- replace . with namespacing ig

---@return me.PlayerData?
local function getPlayer(id)
    local player = game.get_player(id)
    if (player == nil or not player.valid) then return nil; end

    local wrapper = storage.playerMap[id];
    if (wrapper == nil) then
        ---@class me.PlayerData
        wrapper = {
            ---@type integer 
            index = id;
            ---@type LuaPlayer
            player = player;
            data = {
                ---@type integer
                stalkeeIndex = nil
            };
        }
        storage.playerMap[id] = wrapper;
    end

    return wrapper;
end

local function findConnectedIndex(id)
    for i, p in ipairs(game.connected_players) do
        if (p.index == id) then
            return i;
        end
    end

    return 0;
end

---@param playerIndex integer
---@param prevTargetIndex integer?
---@param forward boolean go next or previous
---@return LuaPlayer?
local function getNextTarget(playerIndex, prevTargetIndex, forward)
    local connected = game.connected_players;
    if (#connected <= 1) then return nil; end

    local delta = 1;
    if (forward) then delta = 1; else delta = -1; end

    local start = findConnectedIndex(prevTargetIndex) + delta;
    for offset = 0, #connected - 1 do
        local i = ((start + offset * delta - 1) % #connected) + 1
        local p = connected[i]

        if (p.index ~= playerIndex) then
            return p
        end
    end

    return nil;
end

local function stalk(playerId, forward)
    local wrapper = getPlayer(playerId);
    if (wrapper == nil) then return end

    local player = wrapper.player;

    if (player.controller_type ~= defines.controllers.remote) then
        wrapper.data.stalkeeIndex = nil;
    end

    local target = getNextTarget(wrapper.index, wrapper.data.stalkeeIndex, forward)

    if (target == nil) then
        player.print({LocaleKeys.STALKER.MESSAGES.ALONE});
        return;
    end

    player.print({LocaleKeys.STALKER.MESSAGES.NOW_STALKING, target.name, formatColor(target.color)})

    player.set_controller {
        type = defines.controllers.remote,
        surface = target.surface,
        position = target.position
    }

    wrapper.data.stalkeeIndex = target.index
end

---@param event EventData.CustomInputEvent
local function stalkNext(event)
    stalk(event.player_index, true);
end

local function stalkPrevious(event)
    stalk(event.player_index, false);
end

local function initStorage()
    storage.playerMap = {};
end

script.on_configuration_changed(initStorage);
script.on_init(initStorage)

script.on_event("stalker-spectate_next", stalkNext);
script.on_event("stalker-spectate_previous", stalkPrevious);