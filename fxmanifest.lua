fx_version 'cerulean'

game 'gta5'

lua54 'yes'

author 'eMILSOMFAN'
description 'EMP script to use an item and disable all vehicles in the area.'

version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page('html/index.html')

files {
    'html/index.html',
    'html/sounds/*.ogg',
}

escrow_ignore {
    'config.lua',
    'server/*.lua',
    'client/*.lua'
}

dependency 'emfan-framework'