Items = SConfig.GetItems()

-- Get players in server except the source
--- @param source number|nil The source to exclude (can be nil)
local function getPlayers(source)
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
    local players = getPlayers(source)
    TriggerClientEvent("ez_itemspawner:open", source, players, Items)
end

local identifiers_cache = {}
function ExtractIdentifiers(src) --[[ Just  a simple function to grab all identifiers for a user. ]]
    if identifiers_cache[src] then
        return identifiers_cache[src]
    end
    local identifiers = {
        steam = "N/A",
        ip = "N/A",
        discord = "N/A",
        license = "N/A",
        license2 = "N/A",
        xbl = "N/A",
        live = "N/A",
        fivem = "N/A"
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "ip:") then
            identifiers['ip'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        elseif string.find(id, "xbl:") then
            identifiers['xbl'] = id
        elseif string.find(id, "live:") then
            identifiers['live'] = id
        elseif string.find(id, "fivem:") then
            identifiers['fivem'] = id
        end
        if identifiers.license2 == identifiers.license then
            identifiers.license2 = "N/A"
        end
        if identifiers.license2:gsub("license2:", "") == identifiers.license:gsub("license:", "") then
            identifiers.license2 = "N/A"
        end
    end
    identifiers_cache[src] = identifiers
    return identifiers
end

function GetPlayerDetails(src) --[[ Function to grab player details. ]]
    if not src then return "No info Avalible." end

    local identifiers = ExtractIdentifiers(src)
    local value = "`🔢` **Server ID:** `" .. tostring(src) .. "`"
    if identifiers.discord ~= "N/A" then
        value = value .. "\n`💬` **Discord:** <@" .. identifiers.discord:gsub("discord:", "") .."> (||" .. identifiers.discord:gsub("discord:", "") .. "||)"
    end
    if identifiers.ip ~= "N/A" then
        value = value .. "\n`🔗` **IP:** ||" .. identifiers.ip:gsub("ip:", "") .. "||"
    end
    value = value .. "\n`📶` **Ping:** `" .. GetPlayerPing(src) .. "ms`"
    if identifiers.steam ~= "N/A" then
        value = value .. "\n`🎮` **Steam Hex:** `" .. identifiers.steam .. "` [`🔗` Steam Profile](https://steamcommunity.com/profiles/" ..tonumber(identifiers.steam:gsub("steam:", ""), 16)..")"
    end
    if identifiers.license ~= "N/A" then
        value = value .. "\n`💿` **License:** `" .. identifiers.license .. "`"
    end
    if identifiers.license2 ~= "N/A" then
        value = value .. "\n`💿` **License2:** `" .. identifiers.license2 .. "`"
    end
    if identifiers.fivem ~= "N/A" then
        value = value .. "\n`🛠️` **FiveM:** `" .. identifiers.fivem .. "`"
    end
    if value ~= "" then
        return value
    else
        return "No info Avalible."
    end
end

-- Send a message to a Discord channel
--- @param name string The name of the player
--- @param message string The message to be sent
local function sendToDiscord(name, message, players)
    local connect = {
        {
            ["color"] = 16777215,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Date : " .. os.date("%Y-%m-%d %X"),
            },
            ["fields"] = {
            }
        },
    }
    if players and #players > 0 then
        for _, v in pairs(players) do
            table.insert(connect[1].fields, {
                name = "Player: ".. GetPlayerName(v),
                value = GetPlayerDetails(v)
            })
        end
    end
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
    logs.message = "**Player: **`" .. givename .. "`\n**Admin: **`" .. GetPlayerName(_source) .. "`\n"
    local itemsMessageBox = "**"..SConfig.Locale.SpawnedItems .. ": **```"
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
    logs.message = logs.message..itemsMessageBox
    SConfig.Notify(SConfig.Locale.ItemsSpawned, _source)
    local players = {givesource}
    if givesource ~= tonumber(_source) then
        table.insert(players, tonumber(_source))
    end
    if sendlog then sendToDiscord(logs.title, logs.message, players) end
end)