include "vec2"
include "Class"

local worldWrapped = world
local _world = {}

function _world.lineCollision(...)
	local ret = worldWrapped.lineCollision(...)
	if ret then
		return vec2(ret)
	end
	return 
end

function _world:__index(key)
	return _world[key] or worldWrapped[key]
end

world = class:new(_world)