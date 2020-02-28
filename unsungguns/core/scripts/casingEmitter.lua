include "config"
include "vec2"
include "animator"
include "world"
include "mcontroller"
include "activeItem"
include "updateable"

casingEmitter = {}
casingEmitter._parts = {}

function casingEmitter:init()
    local muzzleConfig = config.casing or {}
    for i,v in pairs(muzzleConfig) do
        self:addPart(v.part, v.offset)
    end
end

function casingEmitter:addPart(part, offset)
    self._parts[part] = vec2(offset or {0,0})
end

function casingEmitter:fire(ammo)
    for i,v in pairs(self._parts) do
        local position = activeItem.handPosition(animator.transformPoint(v,i))
        local end_position = activeItem.handPosition(animator.transformPoint(v + vec2(0,1), i))
        local projectileArgs = ammo:casing(position + mcontroller.position(), end_position - position)
        if not projectileArgs[1] then return end
        projectileArgs[3] = activeItem.ownerEntityId()
        world.spawnProjectile(table.unpack(projectileArgs))
    end
end

updateable:add("casingEmitter")