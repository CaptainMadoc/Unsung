weapon = {
	recoil = 0,
	recoilCamera = {0,0},
	delay = 0.5,
	load = nil,
	stats = {},
	global = {autoCock = true},
	animations = {}, --animation Names
	burstCount = 0,
	burstDelay = 0.4,
	fireSelect = 1
}

function weapon:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end
function weapon:lerpr(value, to, ratio)
	return value + ((to - value ) * ratio ) 
end

function weapon:init()
	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())
	self.stats = config.getParameter("gunStats")
	self.load = config.getParameter("gunLoad")
	self.animations = config.getParameter("gunAnimations")
	activeItem.setCursor("/Unsung-gunsbound/crosshair/white.cursor")
end

function weapon:activate(fireMode, shiftHeld)
end

function weapon:rel(pos)
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

function weapon:debug(dt)
	--world.debugPoint(self:rel(animator.partPoint("gun", "muzzle_begin")), "green")
	--world.debugPoint(self:rel(animator.partPoint("gun", "muzzle_end")), "red")
	--world.debugLine(self:rel(animator.partPoint("gun", "muzzle_begin")),self:rel(weapon:calculateInAccuracy(animator.partPoint("gun", "muzzle_end"))), "red")
	
	world.debugLine(self:rel(animator.partPoint("gun", "muzzle_begin")), vec2.add(self:rel(vec2.rotate(vec2.sub(animator.partPoint("gun", "muzzle_end"),animator.partPoint("gun", "muzzle_begin")), math.rad(weapon:getInAccuracy() ))), animator.partPoint("gun", "muzzle_begin")), "red")
	world.debugLine(self:rel(animator.partPoint("gun", "muzzle_begin")), vec2.add(self:rel(vec2.rotate(vec2.sub(animator.partPoint("gun", "muzzle_end"),animator.partPoint("gun", "muzzle_begin")), math.rad(-weapon:getInAccuracy() ))),animator.partPoint("gun", "muzzle_begin")), "red")
	--world.debugText("inAccuracy = "..(self:getInAccuracy()), "", vec2.add(mcontroller.position(), {0,1}), "green")
end

function weapon:angle()
	return vec2.sub(self:rel(animator.partPoint("gun", "muzzle_end")),self:rel(animator.partPoint("gun", "muzzle_begin")))
end

function whichhigh(a,b)
	if a > b then
		return a
	else
		return b
	end
end

function weapon:getInAccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return self:lerpr(self.stats.standingInaccuracy, self.stats.movingInaccuracy, percent) * crouchMult
end

function weapon:calculateInAccuracy(pos)
	local angle = (math.random(0,2000) - 1000) / 1000
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	if not pos then
		return math.rad((angle * self:getInAccuracy()))
	end
	return vec2.rotate(pos, math.rad((angle * self:getInAccuracy())))
end

function weapon:fire()
	if self.load then
		self.recoil = self.recoil + self.stats.recoil
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 5) ^ 1.25), self.recoil / 2}
		world.spawnProjectile(
			self.load.parameters.projectile or "bullet-4", 
			self:rel(animator.partPoint("gun", "muzzle_begin")), 
			activeItem.ownerEntityId(), 
			self:calculateInAccuracy(self:angle()), 
			false,
			self.load.parameters.projectileConfig or {}
		)
		stance:play(self.animations.shoot)
	end
	
end

function weapon:lateinit()
	stance:addEvent("eject_ammo", function() weapon:eject_ammo() end)
	stance:addEvent("load_ammo", function() weapon:load_ammo() end)
	stance:play(self.animations.init)
end

function weapon:eject_ammo()
	if self.load then
		self.load = nil
		activeItem.setInstanceValue("gunLoad", self.load)
	end
	if #magazine.storage == 0 then
		stance:play(self.animations.dry)
	end
end

function weapon:load_ammo()
	self.load = magazine:take()
	activeItem.setInstanceValue("gunLoad", self.load)
end

function weapon:update(dt)

	if updateInfo.shiftHeld and updateInfo.moves.up and not stance:isAnyPlaying() then
		stance:play(self.animations.reload)
	end
	
	if not updateInfo.shiftHeld and updateInfo.moves.up and not stance:isAnyPlaying() then
		stance:play(self.animations.cock)
	end
	
	if not self.load and magazine and magazine.storage and #magazine.storage > 0 and not stance:isAnyPlaying() and self.global.autoCock then
		stance:play(self.animations.cock)
	end
	
	if updateInfo.fireMode == "primary" and self.stats.fireTypes[self.fireSelect] == "auto" and not stance:isAnyPlaying() then
		self:fire()
	end
	
	if updateInfo.fireMode == "primary" and updateLast.fireMode ~= "primary" and self.stats.fireTypes[self.fireSelect] == "semi" and not stance:isAnyPlaying() then
		self:fire()
	end
	
	if updateInfo.fireMode == "primary" and self.stats.fireTypes[self.fireSelect] == "burst" and self.burstCount <= 0 and self.delay <= 0 then
		self.burstCount = self.stats.burst or 3
	end
	
	if self.burstCount > 0 and not stance:isAnyPlaying() then
		self:fire()
		self.burstCount = self.burstCount - 1
		if self.burstCount == 0 then
			self.delay = self.burstDelay
		end
	end
	
	--camerasystem
	local distance = world.distance(activeItem.ownerAimPosition(), mcontroller.position())
	camera.target = vec2.add({distance[1] * self.stats.aimLookRatio,distance[2] * self.stats.aimLookRatio}, self.recoilCamera)
	camera.smooth = 4
	self.recoilCamera = {self:lerp(self.recoilCamera[1],0,2),self:lerp(self.recoilCamera[2],0,2)}
	self.recoil = self:lerp(self.recoil, 0, self.stats.recoilRecovery + self.delay)
	
	--aiming system
	local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
	aim.target = math.deg(angle)
	aim.dir = dir
	
	--timers
	self.delay = math.max(self.delay - dt, 0)
	
	activeItem.setScriptedAnimationParameter("load", type(self.load))
	activeItem.setScriptedAnimationParameter("fireSelect",  self.stats.fireTypes[self.fireSelect])
	activeItem.setScriptedAnimationParameter("inAccuracy",  self:getInAccuracy())
	activeItem.setScriptedAnimationParameter("muzzleDistance",  world.distance(activeItem.ownerAimPosition(),self:rel(animator.partPoint("gun", "muzzle_begin"))))
	weapon:debug(dt)
end

function weapon:uninit()
	activeItem.setInstanceValue("gunLoad", self.load)
end

addClass("weapon", 1)