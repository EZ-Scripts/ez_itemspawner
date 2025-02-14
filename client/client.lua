-- Changable Variables
CommandName = "adminitems" -- Command to open the menu
-------------------------------------

local openFirst = true

-- Open the item spawner menu
--- @param players table The list of players nearby
--- @param Items table The list of items and weapons
RegisterNetEvent("ez_itemspawner:open", function(players, Items)
    SendNUIMessage({
        type = "show",
        items = Items,
        players = players,
    })
    SetNuiFocus(true, true)
end)

-- Register the command to open the menu
RegisterCommand(CommandName, function()
    if openFirst then
        TriggerServerEvent("ez_itemspawner:server:openFirst")
        openFirst = false
        return
    end
    TriggerServerEvent("ez_itemspawner:server:open")
end, false)

-- Close the item spawner menu
RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

-- Spawn items for a player
--- @param data table The data containing the player and items to be spawned
RegisterNUICallback("spawnItems", function(data, cb)
    TriggerServerEvent("ez_itemspawner:server:spawnItems", data)
    cb("ok")
end)

TriggerEvent("chat:addSuggestion", "/"..CommandName, "Open the item spawner menu", {})
