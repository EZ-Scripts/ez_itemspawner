# Admin Item Spawner

**A menu which allows admins to easily spawn items for players. This works for both fivem and redm and can be adjusted easily.**

## Script Features
- Open menu and view all items
- Input quantity effectively for multiple items you select to spawn
- Logs system to track what admins spawn

## Changing Frameworks
All can be done within sconfig.lua located in server folder.

There are functions assigned to check permission to open menu, adding items to players, and getting items which exist in server (can simply just put the table there).

## Permission Check
A function which checks if player is allowed to open the adminitem menu, i.e. checks if player is admin
### VORP
```lua
SConfig.PermissionCheck = function(source)
    local user = Core.getUser(source)
    if not user then return false end
    if user.getGroup == "admin" then
        return true
    end
    return false
end
```
### QBCORE
```lua
SConfig.PermissionCheck = function(source)
    return QBCore.Functions.HasPermission(source, 'admin')
end
```

## Add Item
### VORP
```lua
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
        if canCarry then
            return false
        end
        local result = VORPInv:createWeapon(source, item, {})
        if not result then
            return false
        end
    end
    return true
end
```
### QBCore
```lua
SConfig.AddItem = function(source, item, amount, type)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    if not Player.Functions.AddItem(item, amount) then
        return false
    end
    return true
end
```

## Get Items
Each item is in the form of ...
```
items[1] = {
    type = "item",
    item = "water",
    label = "Water",
    limit = 10, -- Optional
}
```
### VORP
```lua
SConfig.GetItems = function()
    local items = {
        -- Put all weapons here
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
```
### QBCore
```lua
SConfig.GetItems = function()
    local items = {}
    for itemName, itemData in pairs(QBCore.Shared.Items) do
        items[#items + 1] = {
            type = "item",
            item = itemName,
            label = itemData.label,
        }
    end
    return items
end
```
