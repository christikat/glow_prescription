fx_version 'cerulean'
game 'gta5'
author 'Glowie'
description 'Prescribe and pickup medications at pharmacy'
version '1.0'

ui_page 'web/build/index.html'

shared_script "config.lua"
client_script "client/**/*"
server_script "server/**/*"

files {
	'web/build/index.html',
	'web/build/**/*',
}

lua54 'yes'