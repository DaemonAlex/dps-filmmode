fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dps-filmmode'
description 'DPS film mode: one key hides every HUD layer and hands you a smooth free camera for recording'
author 'DPS'
version '1.0.0'

shared_scripts { '@ox_lib/init.lua', 'config.lua' }
client_script 'client.lua'
server_script 'server.lua'

dependencies { 'ox_lib' }
