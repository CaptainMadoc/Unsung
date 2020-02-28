include "vec2"
include "class"

local activeItemWrapped = activeItem
local _activeItem = {}

function  _activeItem.ownerAimPosition()
	return vec2(activeItemWrapped.ownerAimPosition())
end

local armAngle = 0
function  _activeItem.setArmAngle(angle)
	armAngle = angle
	activeItemWrapped.setArmAngle(angle)
end

function  _activeItem.getArmAngle()
	return armAngle
end

function _activeItem.handPosition(relative)
	return vec2(activeItemWrapped.handPosition(relative))
end

function _activeItem:__index(key)
	return _activeItem[key] or activeItemWrapped[key]
end

activeItem = class:new(_activeItem)