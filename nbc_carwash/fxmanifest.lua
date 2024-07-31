fx_version 'cerulean'
game {'gta5'}
author 'Nobody Workz'
version '1.0'
lua54 'yes'
description 'Carwash for FiveM/ESX'

client_scripts {
    'shared/config.lua',
    'client/client.lua'
}

server_scripts {
    '@es_extended/locale.lua', -- Stellt sicher, dass es_extended zuerst geladen wird
    'shared/config.lua',
    'server/server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

dependencies {
    'es_extended'
}
