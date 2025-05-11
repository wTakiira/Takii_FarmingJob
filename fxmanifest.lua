fx_version 'cerulean'
game 'gta5'

author 'Takiira'
description 'Script de job de farming configurable'
version '1.0.0'

shared_scripts {
    'config/config.lua',
    'locales/locales.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

dependencies {
    'es_extended'
}
dependency 'ox_lib'
