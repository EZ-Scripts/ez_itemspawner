Items = SConfig.GetItems()

-- Get nearby players from a player
--- @param source number The source of the player
local function getNearbyPlayers(source)
    local players = {}
    for _, player in ipairs(GetPlayers()) do
        local ply = tonumber(player)
        if ply ~= source then
            table.insert(players, {id = ply, name = GetPlayerName(player)})
        end
    end
    return players
end

-- Open the item spawner menu
--- @param source number The source of the player
--- @return nil
local function openSpawner(source)
    if not SConfig.PermissionCheck(source) then
        return SConfig.Notify(SConfig.Locale.NoPermission, source)
    end
    local players = getNearbyPlayers(source)
    TriggerClientEvent("ez_itemspawner:open", source, players, Items)
end

-- Send a message to a Discord channel
--- @param name string The name of the player
--- @param message string The message to be sent
local function sendToDiscord(name, message)
    local connect = {
        {
            ["color"] = 15158332,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Date : " .. os.date("%Y-%m-%d %X"),
            },
        },
    }
    PerformHttpRequest(
        WEBHOOK_URL,
        function(err, text, headers) end, 'POST',
        json.encode({
            username = "Item Spawner",
            embeds = connect,
            avatar_url = "https://media.discordapp.net/attachments/1163182151391527053/1317888980876005417/image-removebg-preview_4.png"
        }), { ['Content-Type'] = 'application/json' }
    )
end

-- Open the item spawner menu for the first time
RegisterNetEvent("ez_itemspawner:server:openFirst", function()
    local _source<const> = source
    openSpawner(_source)
end)

-- Open the item spawner menu
RegisterNetEvent("ez_itemspawner:server:open", function()
    local _source<const> = source
    openSpawner(_source)
end)

-- Spawn items for a player
--- @param data table The data containing the player and items to be spawned
RegisterNetEvent("ez_itemspawner:server:spawnItems", function(data)
    local _source<const> = source
    if not SConfig.PermissionCheck(_source) then
        return SConfig.Notify(SConfig.Locale.NoPermission, _source)
    end
    local givesource<const> = data.player == "self" and tonumber(_source) or tonumber(data.player)
    local givename = GetPlayerName(givesource)
    if not givename then
        return SConfig.Notify(SConfig.Locale.PlayerNotFound, _source)
    end
    local logs = {message = "", title = SConfig.Locale.ItemSpawnerTitle}
    logs.message = "## "..SConfig.Locale.ForPlayer..": " .. givename .. "(id "..givesource..")\n" .. "## "..SConfig.Locale.ByAdmin .. GetPlayerName(_source) .. "(id ".._source..")"
    local itemsMessageBox = "## "..SConfig.Locale.SpawnedItems .. "\n```\n"
    local sendlog = false
    for k, v in pairs(data.items) do
        if not SConfig.AddItem(givesource, v.item, v.quantity, v.type) then
            SConfig.Notify(SConfig.Locale.CantCarry, _source)
        else
            sendlog = true
            SConfig.Notify(SConfig.Locale.ReceivedItem .. v.label, givesource)
            itemsMessageBox = itemsMessageBox..v.label.." x"..v.quantity.."\n"
        end
    end
    itemsMessageBox = itemsMessageBox.."```\n"
    logs.message = logs.message.."\n"..itemsMessageBox
    SConfig.Notify(SConfig.Locale.ItemsSpawned, _source)
    if sendlog then sendToDiscord(logs.title, logs.message) end
end)