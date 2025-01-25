SConfig = {}
WEBHOOK_URL = "https://discord.com/api/webhooks/.." -- Discord Webhook URL
local Core = exports.vorp_core:GetCore()
--local QBCore = exports['qb-core']:GetCoreObject()

SConfig.Notify = function(msg, source)
    if source then
        TriggerClientEvent("chatMessage", source, "ItemSpawner", {255, 0, 0}, msg)
    end
end

SConfig.PermissionCheck = function(source)
    local user = Core.getUser(source)
    if not user then return false end
    if user.getGroup == "admin" then
        return true
    end
    return false
end

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
        local result = VORPInv:createWeapon(source, item, {})
        if not result then
            return false
        end
    end
    return true
end

SConfig.GetItems = function()
    local items = {
        {
            label = "Lasso",
            item = "WEAPON_LASSO", -- DONT TOUCH
            type = "weapon",
        },
        {
            label = "Reinforced Lasso",
            item = "WEAPON_LASSO_REINFORCED",
            type = "weapon",
        },
        {
            label = "Knife",
            item = "WEAPON_MELEE_KNIFE",
            type = "weapon",
        },
        {
            label = "Knife Rustic",
            item = "WEAPON_MELEE_KNIFE_RUSTIC",
            type = "weapon",
        },
        {
            label = "Knife Horror",
            item = "WEAPON_MELEE_KNIFE_HORROR",
            type = "weapon",
        },
        {
            label = "Knife Civil War",
            item = "WEAPON_MELEE_KNIFE_CIVIL_WAR",
            type = "weapon",
        },
        {
            label = "Knife Jawbone",
            item = "WEAPON_MELEE_KNIFE_JAWBONE",
            type = "weapon",
        },
        {
            label = "Knife Miner",
            item = "WEAPON_MELEE_KNIFE_MINER",
            type = "weapon",
        },
        {
            label = "Knife Vampire",
            item = "WEAPON_MELEE_KNIFE_VAMPIRE",
            type = "weapon",
        },
        {
            label = "Cleaver",
            item = "WEAPON_MELEE_CLEAVER",
            type = "weapon",
        },
        {
            label = "Hachet",
            item = "WEAPON_MELEE_HATCHET",
            type = "weapon",
        },
        {
            label = "Hachet Double Bit",
            item = "WEAPON_MELEE_HATCHET_DOUBLE_BIT",
            type = "weapon",
        },
        {
            label = "Hachet Hewing",
            item = "WEAPON_MELEE_HATCHET_HEWING",
            type = "weapon",
        },
        {
            label = "Hachet Hunter",
            item = "WEAPON_MELEE_HATCHET_HUNTER",
            type = "weapon",
        },
        {
            label = "Hachet Viking",
            item = "WEAPON_MELEE_HATCHET_VIKING",
            type = "weapon",
        },
        {
            label = "Tomahawk",
            item = "WEAPON_THROWN_TOMAHAWK",
            type = "weapon",
        },
        {
            label = "Tomahawk Ancient",
            item = "WEAPON_THROWN_TOMAHAWK_ANCIENT",
            type = "weapon",
        },
        {
            label = "Throwing Knifes",
            item = "WEAPON_THROWN_THROWING_KNIVES",
            type = "weapon",
        },
        {
            label = "Machete",
            item = "WEAPON_MELEE_MACHETE",
            type = "weapon",
        },
        {
            label = "Bow",
            item = "WEAPON_BOW",
            type = "weapon",
        },
        {
            label = "Pistol Semi-Auto",
            item = 'WEAPON_PISTOL_SEMIAUTO',
            type = "weapon",
        },
        {
            label = "Pistol Mauser",
            item = "WEAPON_PISTOL_MAUSER",
            type = "weapon",
        },
        {
            label = "Pistol Volcanic",
            item = "WEAPON_PISTOL_VOLCANIC",
            type = "weapon",
        },
        {
            label = "Pistol M1899",
            item = "WEAPON_PISTOL_M1899",
            type = "weapon",
        },
        {
            label = "Revolver Schofield",
            item = "WEAPON_REVOLVER_SCHOFIELD",
            type = "weapon",
        },
        {
            label = "Revolver Navy",
            item = "WEAPON_REVOLVER_NAVY",
            type = "weapon",
        },
        {
            label = "Revolver Navy Crossover",
            item = "WEAPON_REVOLVER_NAVY_CROSSOVER",
            type = "weapon",
        },
        {
            label = "Revolver Lemat",
            item = "WEAPON_REVOLVER_LEMAT",
            type = "weapon",
        },
        {
            label = "Revolver Double Action",
            item = "WEAPON_REVOLVER_DOUBLEACTION",
            type = "weapon",
        },
        {
            label = "Revolver Cattleman",
            item = "WEAPON_REVOLVER_CATTLEMAN",
            type = "weapon",
        },
        {
            label = "Revolver Cattleman mexican",
            item = "WEAPON_REVOLVER_CATTLEMAN_MEXICAN",
            type = "weapon",
        },
        {
            label = "Varmint Rifle",
            item = "WEAPON_RIFLE_VARMINT",
            type = "weapon",
        },
        {
            label = "Winchester Repeater",
            item = "WEAPON_REPEATER_WINCHESTER",
            type = "weapon",
        },
        {
            label = "Henry Reapeater",
            item = "WEAPON_REPEATER_HENRY",
            type = "weapon",
        },
        {
            label = "Evans Repeater",
            item = "WEAPON_REPEATER_EVANS",
            type = "weapon",
        },
        {
            label = "Carabine Reapeater",
            item = "WEAPON_REPEATER_CARBINE",
            type = "weapon",
        },
        {
            label = "Rolling Block Rifle",
            item = "WEAPON_SNIPERRIFLE_ROLLINGBLOCK",
            type = "weapon",
        },
        {
            label = "Carcano Rifle",
            item = "WEAPON_SNIPERRIFLE_CARCANO",
            type = "weapon",
        },
        {
            label = "Springfield Rifle",
            item = "WEAPON_RIFLE_SPRINGFIELD",
            type = "weapon",
        },
        {
            label = "Elephant Rifle",
            item = "WEAPON_RIFLE_ELEPHANT",
            type = "weapon",
        },
        {
            label = "BoltAction Rifle",
            item = "WEAPON_RIFLE_BOLTACTION",
            type = "weapon",
        },
        {
            label = "Semi-Auto Shotgun",
            item = "WEAPON_SHOTGUN_SEMIAUTO",
            type = "weapon",
        },
        {
            label = "Sawedoff Shotgun",
            item = "WEAPON_SHOTGUN_SAWEDOFF",
            type = "weapon",
        },
        {
            label = "Repeating Shotgun",
            item = "WEAPON_SHOTGUN_REPEATING",
            type = "weapon",
        },
        {
            label = "Double Barrel Exotic Shotgun",
            item = "WEAPON_SHOTGUN_DOUBLEBARREL_EXOTIC",
            type = "weapon",
        },
        {
            label = "Pump Shotgun",
            item = "WEAPON_SHOTGUN_PUMP",
            type = "weapon",
        },
        {
            label = "Double Barrel Shotgun",
            item = "WEAPON_SHOTGUN_DOUBLEBARREL",
            type = "weapon",
        },
        {
            label = "Camera",
            item = "WEAPON_KIT_CAMERA",
            type = "weapon",
        },
        {
            label = "Improved Binoculars",
            item = "WEAPON_KIT_BINOCULARS_IMPROVED",
            type = "weapon",
        },
        {
            label = "Knife Trader",
            item = "WEAPON_MELEE_KNIFE_TRADER",
            type = "weapon",
        },
        {
            label = "Binoculars",
            item = "WEAPON_KIT_BINOCULARS",
            type = "weapon",
        },
        {
            label = "Advanced Camera",
            item = "WEAPON_KIT_CAMERA_ADVANCED",
            type = "weapon",
        },
        {
            label = "Lantern",
            item = "WEAPON_MELEE_LANTERN",
            type = "weapon",
        },
        {
            label = "Davy Lantern",
            item = "WEAPON_MELEE_DAVY_LANTERN",
            type = "weapon",
        },
        {
            label = "Halloween Lantern",
            item = "WEAPON_MELEE_LANTERN_HALLOWEEN",
            type = "weapon",
        },
        {
            label = "Poison Bottle",
            item = "WEAPON_THROWN_POISONBOTTLE",
            type = "weapon",
        },
        {
            label = "Metal Detector",
            item = "WEAPON_KIT_METAL_DETECTOR",
            type = "weapon",
        },
        {
            label = "Dynamite",
            item = "WEAPON_THROWN_DYNAMITE",
            type = "weapon",
        },
        {
            label = "Molotov",
            item = "WEAPON_THROWN_MOLOTOV",
            type = "weapon",
        },
        {
            label = "Improved Bow",
            item = "WEAPON_BOW_IMPROVED",
            type = "weapon",
        },
        {
            label = "Machete Collector",
            item = "WEAPON_MELEE_MACHETE_COLLECTOR",
            type = "weapon",
        },
        {
            label = "Electric Lantern",
            item = "WEAPON_MELEE_LANTERN_ELECTRIC",
            type = "weapon",
        },
        {
            label = "Torch",
            item = "WEAPON_MELEE_TORCH",
            type = "weapon",
        },
        {
            label = "Moonshine Jug",
            item = "WEAPON_MOONSHINEJUG_MP",
            type = "weapon",
        },
        {
            label = "Bolas",
            item = "WEAPON_THROWN_BOLAS",
            type = "weapon",
        },
        {
            label = "Bolas Hawkmoth",
            item = "WEAPON_THROWN_BOLAS_HAWKMOTH",
            type = "weapon",
        },
        {
            label = "Bolas Ironspiked",
            item = "WEAPON_THROWN_BOLAS_IRONSPIKED",
            type = "weapon",
        },
        {
            label = "Bolas Intertwined",
            item = "WEAPON_THROWN_BOLAS_INTERTWINED",
            type = "weapon",
        },
        {
            label = "Fishing Rod",
            item = "WEAPON_FISHINGROD",
            type = "weapon",
        },
        {
            label = "Machete Horror",
            item = "WEAPON_MACHETE_HORROR",
            type = "weapon",
        },
        {
            label = "Hammer",
            item = "WEAPON_MELEE_HAMMER",
            type = "weapon",
        },
        {
            label = "High Roller Double-Action Revolver",
            item = "WEAPON_REVOLVER_DOUBLEACTION_GAMBLER",
            type = "weapon",
        },
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
