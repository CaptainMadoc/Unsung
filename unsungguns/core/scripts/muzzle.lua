include "config"
include "vec2"
include "animator"
include "world"
include "mcontroller"
include "activeItem"
include "updateable"

muzzle = {}
muzzle._flash = {}
muzzle._parts = {}
muzzle.inaccuracy = 0
muzzle.damageMultplier = 1

function muzzle:init()
	local muzzleConfig = config.muzzle or {}
	for i,v in pairs(muzzleConfig) do
		self:addPart(v.part, v.offset)
	end
	self._flash = config.muzzleFlash or {animationStates = {}}
end

function muzzle:flash()
	for i,v in pairs(self._flash.animationStates) do
		animator.setAnimationState(i,v)
	end
end

function muzzle:addPart(part, offset)
	self._parts[part] = vec2(offset or {0,0})
end

function muzzle:getPositions()
	local positions = {}
	for i,v in pairs(self._parts) do
		positions[i] = activeItem.handPosition(animator.transformPoint(v,i))
	end
	return positions
end

function muzzle:fire(ammo)
	for i,v in pairs(self._parts) do
		-- world.spawnProjectile(`String` projectileName [arg1], `Vec2F` position [arg2], [`EntityId` sourceEntityId] [arg3], [`Vec2F` direction] [arg4], [`bool` trackSourceEntity] [arg5], [`Json` parameters] [arg6])

		local position = activeItem.handPosition(animator.transformPoint(v,i))
		local end_position = activeItem.handPosition(animator.transformPoint(v + vec2(1,0), i))

		--inaccuracy
		local direction = end_position - position
		if self.inaccuracy ~= 0 then
			local rand = math.random(math.floor(-self.inaccuracy * 100), math.ceil(self.inaccuracy * 100)) / 100
			direction = direction:rotate(math.rad(rand))
		end

		local projectileArgs = ammo:projectileArgs(position + mcontroller.position(), direction)
		if not projectileArgs[1] then return end

		projectileArgs[3] = activeItem.ownerEntityId()

		--damageMultplier
		if self.damageMultplier ~= 1 and projectileArgs[6] then
			projectileArgs[6].power = (projectileArgs[6].power or 1) * self.damageMultplier
		end

		world.spawnProjectile(table.unpack(projectileArgs))
	end
end

function muzzle:fireProjectile(projectileName, projectileConfig)
	local ownerId = activeItem.ownerEntityId()
	for i,v in pairs(self._parts) do
		-- world.spawnProjectile(`String` projectileName [arg1], `Vec2F` position [arg2], [`EntityId` sourceEntityId] [arg3], [`Vec2F` direction] [arg4], [`bool` trackSourceEntity] [arg5], [`Json` parameters] [arg6])

		local position = activeItem.handPosition(animator.transformPoint(v,i))
		local end_position = activeItem.handPosition(animator.transformPoint(v + vec2(1,0), i))

		--inaccuracy
		local direction = end_position - position
		if self.inaccuracy ~= 0 then
			local rand = math.random(math.floor(-self.inaccuracy * 100), math.ceil(self.inaccuracy * 100)) / 100
			direction = direction:rotate(math.rad(rand))
		end

		--damageMultplier
		if self.damageMultplier ~= 1 and projectileConfig and projectileConfig.power then
			projectileConfig.power = (projectileConfig.power or 1) * self.damageMultplier
		end

		world.spawnProjectile(projectileName, position + mcontroller.position(), ownerId, direction, false, projectileConfig)
	end
end

updateable:add("muzzle")