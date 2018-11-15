gun = {
	features = {
		recoilRecovery = true,
		cameraAim = true,
		aim = true --disable this if you want to override things
	},

	camera = {0,0},
    fireModeInt = 1,
	recoil = 0,
	cooldown = 0,
	aimPos = nil,
}
		--For debug ui

function gun:gbDebug()
	if _GBDEBUG then
		_GBDEBUG:newTestUnit("gun:fire()", function() return self:fire() end)
		_GBDEBUG:newTestUnit("gun:load_chamber()", function() return self:load_chamber() end)
	end
end

		--CALLBACKS

function gun:init()
    dataManager:load("gunLoad", true)
    dataManager:load("gunScript", false, "/gunsboundunsung/base/default.lua")
	dataManager:load("gunStats", false, 
		{
			damageMultiplier = 1,
			bulletSpeedMultiplier = 1,
			maxMagazine = 30,
			aimLookRatio = 0,
			burst = 3,
			recoil = 4,
			recoilRecovery = 2,
			movingInaccuracy = 5,
			standingInaccuracy = 1,
			crouchInaccuracyMultiplier = 0.25,
			muzzleFlash = 1,
			rpm = 600
		}
	)

	--old gun settings 
	    dataManager:load("fireTypes", false, {"auto"})
	    dataManager:load("casingFX", false, true)
	    dataManager:load("bypassShellEject", false, false)
	    dataManager:load("muzzlePosition", false, {part = "gun", tag = "muzzle_begin", tag_end = "muzzle_end"})
	    dataManager:load("casing", false, {part = "gun", tag  = "casing_pos"})

	dataManager:load("gunSettings", false, 
		{
			fireSounds = jarray(),
			fireTypes = data.fireTypes,
			chamberEjection = not data.bypassShellEject,
			muzzlePosition = data.muzzlePosition,
			showCasings = data.casingFX,
			casingPosition = data.casing
		}
	)

    dataManager:load("gunAnimations")
	activeItem.setCursor("/gunsboundunsung/crosshair/crosshair2.cursor")

    self.fireSounds = config.getParameter("fireSounds", data.gunSettings.fireSounds or jarray())
	for i,v in pairs(self.fireSounds) do
		self.fireSounds[i] = processDirectory(v)
	end
	
	self:setFireSound( self.fireSounds )

	animation:addEvent("eject_chamber", function() self:eject_chamber() end)
	animation:addEvent("load_ammo", function() self:load_chamber() end)

	if magazine then magazine.size = data.gunStats.maxMagazine end

	self:gbDebug()

	require(processDirectory(data.gunScript))
end

function gun:lateinit(...)
	if main and main.init then
		main:init(...)
	end
end

function gun:uninit(...)
	if main and main.uninit then
		main:uninit(...)
	end
	dataManager:save("gunLoad")
end

function gun:activate(...)
	if main and main.activate then
		main:activate(...)
	end
end

function gun:update(dt, fireMode, shiftHeld, moves)

	--camerasystem
	if self.features.cameraAim then
		local distance = world.distance(activeItem.ownerAimPosition(), mcontroller.position())
		camera.target = vec2.add({distance[1] * util.clamp(data.gunStats.aimLookRatio, 0, 0.5),distance[2] * util.clamp(data.gunStats.aimLookRatio, 0, 0.5)}, self.camera)
		camera.smooth = 8
		self.camera = {lerp(self.camera[1],0,data.gunStats.recoilRecovery),lerp(self.camera[2],0,data.gunStats.recoilRecovery)}
	end
	
	if self.features.recoilRecovery then
	self.recoil = lerp(self.recoil, 0, data.gunStats.recoilRecovery)	
	end

	if self.features.aim then
		local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(self.aimPos or activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
		aim.target = math.deg(angle) + self.recoil
		aim.direction = dir
	end

	if self.hasToLoad and gun:ready() then
		self.hasToLoad = false
		self:load_chamber()
		self.cooldown = 0.016
    end

	if main and main.update then
		main:update(dt, fireMode, shiftHeld, moves)
	end

	self.cooldown = math.max(self.cooldown - updateInfo.dt, 0)
	
end

		--API--

--Use for calculation RPM to shots timer
function gun:rpm()
    return math.max((60/(data.gunStats.rpm or 666)) - 0.016, 0.016)
end

--i think its for the angle RNG -/+
function gun:inaccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = data.gunStats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return lerpr(data.gunStats.standingInaccuracy, data.gunStats.movingInaccuracy, percent) * crouchMult
end

--RNG
function gun:calculateInAccuracy(pos)
	local angle = (math.random(0,2000) - 1000) / 1000
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = data.gunStats.crouchInaccuracyMultiplier
	end
	if not pos then
		return math.rad((angle * self:inaccuracy()))
	end
	return vec2.rotate(pos, math.rad((angle * self:inaccuracy())))
end

--Quick relativepos from hand + pos
function gun:rel(pos)	
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

--vec2 angle from muzzlePosition
function gun:angle()
	return vec2.sub(self:rel(animator.partPoint(data.muzzlePosition.part, data.muzzlePosition.tag_end)),self:rel(animator.partPoint(data.muzzlePosition.part, data.muzzlePosition.tag)))
end

--vec2 angle from casing
function gun:casingPosition()
	local offset = {0,0}
	if data.casing then
		offset = animator.partPoint(data.casing.part, data.casing.tag)
	end
	return vec2.add(mcontroller.position(), activeItem.handPosition(offset))
end

--overrides from cursor aim if you want to make aimbot attachments
function gun:aimAt(pos)
	if not pos then self.aimPos = nil return end self.aimPos = pos
end

function gun:canFire()
	if data.gunLoad and not data.gunLoad.parameters.fired then
		return true
	else
		return false
	end
end

--base damage of the current bullet
function gun:rawDamage(projectilename)
	local dmg = 0
	if data.gunLoad then

		return root.projectileConfig(projectilename or (data.gunLoad.parameters or {}).projectile or "bullet-4").power or 5.0
	end
	return dmg
end

--You know
function gun:fire(overrideStats)
	if not overrideStats then overrideStats = {} end

	if data.gunLoad and not data.gunLoad.parameters.fired then -- data.gunLoad must be a valid bullet without a parameter fired as true
		
		local newConfig = root.itemConfig({name = data.gunLoad.name, count = 1, parameters = data.gunLoad.parameters})		
		if not newConfig then self:eject_chamber() return end

		data.gunLoad.parameters = sb.jsonMerge(newConfig.config, newConfig.parameters)

		-- apply bullet projectile stuff
		local finalProjectileConfig = data.gunLoad.parameters.projectileConfig or {}
		if not finalProjectileConfig.power then -- we calculate the gun x bullet power
			finalProjectileConfig.power = self:rawDamage() * (overrideStats.damageMultiplier or data.gunStats.damageMultiplier or 1.0)
		end
		finalProjectileConfig.speed = (finalProjectileConfig.speed or 5.0) * (overrideStats.bulletSpeedMultiplier or data.gunStats.bulletSpeedMultiplier or 1.0)

		--spawns bullet
		for i=1,data.gunLoad.parameters.projectileCount or 1 do
			world.spawnProjectile(
				data.gunLoad.parameters.projectile or "bullet-4", 
				self:rel(animator.partPoint(data.muzzlePosition.part, data.muzzlePosition.tag)), 
				activeItem.ownerEntityId(), 
				self:calculateInAccuracy(self:angle()), 
				false,
				finalProjectileConfig
			)
		end

		--marks ammo as a fired bullet
		data.gunLoad.parameters.fired = true
		
		--used by action lever style
		if not data.bypassShellEject then
			self:eject_chamber()
			if magazine:count() > 0 then
				self.hasToLoad = true
			end
		end
		--
		
		--emits FX muzzle flash sometimes changed by a silencer/flash hider
		if (overrideStats.muzzleFlash or data.gunStats.muzzleFlash) == 1 then
			animator.setAnimationState("firing", "on")
		end

		--firesounds
		animator.playSound("fireSounds")
		
		--local status
		self.cooldown = self:rpm()
		self:addRecoil()
		
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 8) ^ 1.25), self.recoil / 8}
		dataManager:save("gunLoad") --Save as we changed something in gunLoad 
		
		return true
	else --else plays a dry sound
		animator.playSound("dry")
		self.cooldown = self:rpm()
		return false
	end
end
--sets our gun firesounds
function gun:setFireSound(soundpool)
	animator.setSoundPool("fireSounds", soundpool or jarray())
end

--Gets bullet out from the internal gun
function gun:eject_chamber()
	if data.gunLoad then

		local itemConfig = root.itemConfig(data.gunLoad)
		local finalItemParameters = sb.jsonMerge(itemConfig.config, data.gunLoad.parameters or {})

		local projectileParam = finalItemParameters.casingProjectileConfig or {speed = 10, timeToLive = 1}


		if not itemConfig.parameters.fired then
			projectileParam.actionOnReap = projectileParam.actionOnReap or {}
			table.insert(projectileParam.actionOnReap, {action = "item", name = data.gunLoad.name,count = data.gunLoad.count, data = itemConfig.parameters})
			--player.giveItem(data.gunLoad)
		end

		world.spawnProjectile(
			finalItemParameters.casingProjectile or "invisibleprojectile", 
			self:casingPosition(), 
			activeItem.ownerEntityId(), 
			vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
			false,
			projectileParam
		)

		data.gunLoad = nil

		dataManager:save("gunLoad")
	end
end

--Gets bullet in from the internal gun; can be manual loaded with 'bullet'
function gun:load_chamber(bullet)
	if data.gunLoad then 
		self:eject_chamber()
	end
	data.gunLoad = bullet or magazine:take()
	dataManager:save("gunLoad")
end

--See if nothing is loaded
function gun:chamberDry()
	if type(data.gunLoad) ~= "table" then
		return true
	elseif data.gunLoad.parameters and data.gunLoad.parameters.fired then
		return true
	end
	return false
end

function gun:dry()
	return self:chamberDry() and magazine:count() == 0
end

--Adding armOffsets
function gun:addRecoil(custom)
	local a = custom
	if not custom then
		a = data.gunStats.recoil
	end
	self.recoil = self.recoil + a * 2
end

--Gets Current Firemode
function gun:fireMode()
	return data.fireTypes[self.fireModeInt]
end

--todo
function gun:switchFireModes(custom)
	if not data.fireTypes then data.fireTypes = {"semi"} end --verify
	animator.playSound("dry")
	if self.fireModeInt == #data.fireTypes then
		self.fireModeInt = 1
	else
		self.fireModeInt = math.max(math.min((custom or self.fireModeInt + 1),#data.fireTypes),1)
	end
end

--Gun full ready
function gun:ready()
	if self.cooldown == 0 then
		return true
	end
	return false
end


addClass("gun")