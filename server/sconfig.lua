
-- SConfig table to hold configuration and functions
SConfig = {}

-- Discord Webhook URL
WEBHOOK_URL = "https://discord.com/api/webhooks/..."

-- Core object from vorp_core
local Core = exports.vorp_core:GetCore()

-- Function to send a notification message to a specific source
--- @param msg string The message to be sent
--- @param source number The source to which the message will be sent
SConfig.Notify = function(msg, source)
    if source then
        TriggerClientEvent("chatMessage", source, "ItemSpawner", {255, 0, 0}, msg)
    end
end

-- Function to check if a user has admin permissions
--- @param source number The source of the user
--- @return boolean True if the user is an admin, false otherwise
SConfig.PermissionCheck = function(source)
    local user = Core.getUser(source)
    if not user then return false end
    if user.getGroup == "admin" then
        return true
    end
    return false
end

-- Function to add an item or weapon to a user's inventory
--- @param source number The source of the user
--- @param item string The item or weapon to be added
--- @param amount number The amount of the item or weapon to be added
--- @param type string The type of the item (either "item" or "weapon")
--- @return boolean True if the item was successfully added, false otherwise
SConfig.AddItem = function(source, item, amount, type)
    local VORPInv = exports.vorp_inventory
    if type == "item" then
        local itemCheck = VORPInv:getItemDB(item)
        local canCarry = VORPInv:canCarryItems(source, amount)       --can carry inv space
        local canCarry2 = VORPInv:canCarryItem(source, item, amount) --cancarry item limit

        if not itemCheck or not canCarry or not canCarry2 then
           return false
        end

        VORPInv:addItem(source, item, amount)
    elseif type == "weapon" then
        local canCarry = VORPInv:canCarryWeapons(source, amount, nil, item)
        if not canCarry then
            return false
        end
        for i=1, amount do
            local result = VORPInv:createWeapon(source, item, {})
            if not result then
                return false
            end
        end
    end
    return true
end

-- Function to get a list of items and weapons
--- @return table A table containing the list of items and weapons
SConfig.GetItems = function()
    local items = {
        -- List of predefined items and weapons
    }
    local result = MySQL.Sync.fetchAll("SELECT * FROM items", {})
    for _, db_item in pairs(result) do
        if db_item.id then
            items[#items+1] = {
                type = "item",
                item = db_item.item,
                label = db_item.label,
                limit = db_item.limit,
            }
        end
    end
    return items
end

SConfig.Locale = {
    NoPermission = "You don't have permission to use this command!",
    PlayerNotFound = "Player not found!",
    ItemsSpawned = "Items spawned!",
    CantCarry = "You can't carry that much!",
    ReceivedItem = "Received item %s",
    ItemSpawnerTitle = "Item Spawner",
    ForPlayer = "For player ",
    ByAdmin = "By admin ",
    SpawnedItems = "Spawned items",
}