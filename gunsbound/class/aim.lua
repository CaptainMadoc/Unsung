aim = {
	current = 0,
	target = 0,
	dir = 1,
	anglesmooth = 2,
	armoffset = 0,
	lockEntity = nil
}

function aim:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function aim:entityLock(id)
	if world.entityExists(id) then
		self.lockEntity = id
		activeItem.setScriptedAnimationParameter("lockID", self.lockEntity)
	end
end

function aim:unlock()
	self.lockEntity = nil
	activeItem.setScriptedAnimationParameter("lockID", nil)
end

function aim:update(dt)
	if self.lockEntity then
		if world.entityExists(self.lockEntity) then
			if drawable and drawable.transforms and drawable.transforms.aimoffset then
				self.armoffset = drawable.transforms.aimoffset.rotation / 2
			end
			local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(world.entityPosition(self.lockEntity), vec2.div(world.entityVelocity(self.lockEntity), 28)))
			self.target = math.deg(angle)
			self.dir = dir
		else --self.lockEntity
			activeItem.setScriptedAnimationParameter("lockID", nil)
			self.lockEntity = nil
		end
	else
		if drawable and drawable.transforms and drawable.transforms.aimoffset then
			self.armoffset = drawable.transforms.aimoffset.rotation
		end
	end
	self.current = self:lerp(self.current, self.target, math.max(self.anglesmooth / (dt * 60), 1)) --smoothing aim
	activeItem.setArmAngle(math.rad(self.current + self.armoffset)) --applies aiming
	activeItem.setFacingDirection(self.dir)
end

addClass("aim", 999)