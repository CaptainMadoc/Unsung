modPath = "/unsungguns/"
corePath = modPath.."core/"
includePath = corePath.."scripts/"

local _included = {}
function include(util)
	if _included[includePath..util..".lua"] then return end
	_included[includePath..util..".lua"] = true
	require(includePath..util..".lua")
end

function init()
	include "config" --needed to load certain configs
	require(config.gunScript or modPath.."systems/default.lua")
	if gun and gun.init then
		gun:init()
	end
end

update_lastInfo = {}
update_info = {}
update_lateInited = false
function update(...)
	update_lastInfo = update_info
	update_info = {...}
	if not update_lateInited and gun and gun.lateInit then
		update_lateInited = true
		gun:lateInit(...)
	end
	if gun and gun.update then
		gun:update(...)
	end
end

function activate(...)
	if gun and gun.activate then
		gun:activate(...)
	end
end

function uninit()
	if gun and gun.uninit then
		gun:uninit()
	end
end