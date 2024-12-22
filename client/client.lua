local openFirst = true
RegisterNetEvent("ez_itemspawner:open", function(players, Items)
    SendNUIMessage({
        type = "show",
        items = Items,
        players = players,
    })
    SetNuiFocus(true, true)
end)

RegisterCommand("adminitems", function()
    if openFirst then
        TriggerServerEvent("ez_itemspawner:server:openFirst")
        openFirst = false
        return
    end
    TriggerServerEvent("ez_itemspawner:server:open")
end, false)

RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("spawnItems", function(data, cb)
    TriggerServerEvent("ez_itemspawner:server:spawnItems", data)
    cb("ok")
end)
