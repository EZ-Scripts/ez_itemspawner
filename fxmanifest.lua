fx_version 'cerulean'
games {"rdr3","gta5"}
lua54 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name "ez_itemspawner"
author "Rayaan Uddin"
version "1.0"
description "Item Spawner for Fivem and RedM"

files {
    'html/*.*',
}
ui_page 'html/index.html'

server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua' }
client_scripts {'client/*.lua', }
