fx_version 'cerulean'
game {'gta5'}
author 'Nobody Workz'
version '1.0'
lua54 'yes'
description 'Carwash for FiveM/ESX'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@es_extended/locale.lua', -- Stellt sicher, dass es_extended zuerst geladen wird
    'server/server.lua'
}

dependencies {
    'es_extended'
}w