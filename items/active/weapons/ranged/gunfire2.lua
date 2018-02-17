require "/scripts/util.lua"
require "/scripts/interp.lua"

-- Base gun fire ability
GunFire = WeaponAbility:new()

function GunFire:init()
  self.weapon:setStance(self.stances.idle)

  self.ammoConfig = config.getParameter("ammoConfig", false)

  self.cooldownTimer = self.fireTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function GunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end

--  if self.ammoconfig then
--    compatibleAmmo
--  end

  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

    if self.fireType == "auto" and status.overConsumeResource("energy", self:energyPerShot()) then
      self:setState(self.auto)
    elseif self.fireType == "burst" then
      self:setState(self.burst)
    end
  end
  
    if self.ammoConfig.magazineMax then
    	if not self.reloading then
    		local percent = self.ammoConfig.magazineCurrent/self.ammoConfig.magazineMax
    		--world.sendEntityMessage(activeItem.ownerEntityId(),"setBar",config.getParameter("itemName")..self.barUUID,percent,{255-math.ceil(255*percent),127+math.ceil(128*percent),0,255})
    	else
    		--world.sendEntityMessage(activeItem.ownerEntityId(),"setBar",config.getParameter("itemName")..self.barUUID,1-cooldown/self.ammoConfig.reloadCooldown,{255,128,0,255})
    	end
    end
  
end

function GunFire:consumeAmmo()
  if self.ammoConfig.compatibleAmmo and not self.reloading then
  	
  	local itemammo = nil
  	
  	if self.ammoConfig.magazineMax then
  		if self.ammoConfig.magazineCurrent > 0 then
  			self.ammoConfig.magazineCurrent = self.ammoConfig.magazineCurrent - 1
  			itemammo = true
  		elseif player.hasItem(self.ammoConfig.compatibleAmmo[1]) and cooldown <= 0 then
  			magreload()
  			return
  		else
  			if self.ammoConfig.magazineCurrent == 0 then
  				cooldown = 0.5
  			end
  			return
  		end
  	else
  		itemammo = player.consumeItem(self.ammoConfig.compatibleAmmo[1])
  	end
  	
  	if itemammo then --Ammo found!!
  		if self.ammoConfig.magazineCurrent == 0 then
  			cooldown = 0.1
  		end
  	end
  	
  end
end

function GunFire:auto()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = self.fireTime
  self:setState(self.cooldown)
end

function GunFire:burst()
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
    self:fireProjectile()
    self:muzzleFlash()
    shots = shots - 1

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

    util.wait(self.burstTime)
  end

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount
end

  function magreload()
    while activeItem.ownerHasItem(self.ammoConfig.compatibleAmmo[1]) and self.ammoConfig.magazineCurrent < self.ammoConfig.magazineMax do
        activeItem.takeOwnerItem(self.ammoConfig.compatibleAmmo[1])
        self.ammoConfig.magazineCurrent = self.ammoConfig.magazineCurrent + 1
    end
    if self.ammoConfig.reloadCooldown then
        cooldown = self.ammoConfig.reloadCooldown
    end
    if animator.hasSound("reload") then
        animator.playSound("reload")
    end
    self.ammoConfig.reloadForce = false
    self.reloading = true
end

function GunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()
  
  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function GunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound("fire")

  animator.setLightActive("muzzleFlash", true)
end

function GunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
    projectileType = self.projectileType
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end
  return projectileId
end

function GunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function GunFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function GunFire:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0)
end

function GunFire:damagePerShot()
  return (self.baseDamage or (self.baseDps * self.fireTime)) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount
end

function GunFire:uninit()
	if self.ammoConfig.magazineMax then
		local changedammoConfig = config.getParameter("ammoConfig")
		changedammoConfig.magazineCurrent = self.ammoConfig.magazineCurrent 
		activeItem.setInstanceValue("ammoConfig", changedammoConfig)
		--world.sendEntityMessage(activeItem.ownerEntityId(),"removeBar",config.getParameter("itemName")..self.barUUID) --deletes bar
	end
end