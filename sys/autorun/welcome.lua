local Config = require('config')
local Util   = require('util')

local fs     = _G.fs
local shell  = _ENV.shell

local config = Config.load('os')
if not config.welcomed and shell.openForegroundTab then
	config.welcomed = true
	config.securityUpdate = true
	config.readNotes = 1
	Config.update('os', config)

	shell.openForegroundTab('Welcome')
end

if not config.securityUpdate then
	config.securityUpdate = true
	config.secretKey = nil
	config.password = nil
	config.readNotes = 1
	Config.update('os', config)

	fs.delete('usr/.known_hosts')

	Util.writeFile('sys/notes_1.txt', [[
An important security update has been applied.

Unfortunately, this update has reset the
password on the system. You can set a new
password in System->System->Password.

All computers that you connect to will also
need to be updated as well.

Thanks for your patience. And... thanks to
Anavrins for the much improved security.
	]])
end

if fs.exists('sys/notes_1.txt') and shell.openForegroundTab then
	shell.openForegroundTab('edit sys/notes_1.txt')
	os.sleep(2)
	fs.delete('sys/notes_1.txt')
end
