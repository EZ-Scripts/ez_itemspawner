Items = SConfig.GetItems()

RegisterNetEvent("ez_itemspawner:server:openFirst", function()
    local _source<const> = source
    if not SConfig.PermissionCheck(_source) then
        return SConfig.Notify("You don't have permission to use this command!", _source)
    end
	-- Get Nearby players
	local players = {}
	for _, player in ipairs(GetPlayers()) do
		if tonumber(player) ~= tonumber(_source) then
			table.insert(players, {id = tonumber(player), name = GetPlayerName(player)})
		end
	end
    TriggerClientEvent("ez_itemspawner:open", _source, players, Items)
end)

RegisterNetEvent("ez_itemspawner:server:open", function()
    local _source<const> = source
    if not SConfig.PermissionCheck(_source) then
		return SConfig.Notify("You don't have permission to use this command!", _source)
    end
	-- Get Nearby players
	local players = {}
	for _, player in ipairs(GetPlayers()) do
		if tonumber(player) ~= tonumber(_source) then
			table.insert(players, {id = tonumber(player), name = GetPlayerName(player)})
		end
	end
    TriggerClientEvent("ez_itemspawner:open", _source, players)
end)

function SendToDiscord(name, message)
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

RegisterNetEvent("ez_itemspawner:server:spawnItems", function(data)
    local _source<const> = source
    if not SConfig.PermissionCheck(_source) then
		return SConfig.Notify("You don't have permission to use this command!", _source)
    end
    local givesource = _source
    if data.player ~= "self" then
        givesource = tonumber(data.player)
    end
	local givename = GetPlayerName(givesource)
	if not givename then
		return SConfig.Notify("Player not found!", _source)
	end
	local logs = {message = "", title = "Item Spawner"}
	logs.message = "## For Player: "..givename .. "(id "..givesource..")\n ## By Admin: "..GetPlayerName(_source) .. "(id ".._source..")"
	local itemsMessageBox = "## Spawned Items\n```\n"
	local sendlog = false
    for k, v in pairs(data.items) do
        if not SConfig.AddItem(givesource, v.item, v.quantity, v.type) then
			SConfig.Notify("You can't carry that much!", _source)
		else
			sendlog = true
			SConfig.Notify("Received item "..v.label, givesource)
			itemsMessageBox = itemsMessageBox..v.label.." x"..v.quantity.."\n"
		end
	end
	itemsMessageBox = itemsMessageBox.."```\n"
	logs.message = logs.message.."\n"..itemsMessageBox
	SConfig.Notify("Items spawned!", _source)
	if sendlog then SendToDiscord(logs.title, logs.message) end
end)