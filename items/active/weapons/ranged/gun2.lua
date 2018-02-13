require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

function init()
  activeItem.setCursor("/cursors/reticle0.cursor")
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))

  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.weapon:addTransformationGroup("muzzle", self.weapon.muzzleOffset, 0)

  local primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(primaryAbility)

  local secondaryAbility = getAltAbility(self.weapon.elementalType)
  if secondaryAbility then
    self.weapon:addAbility(secondaryAbility)
  end

  if self.gunConfig.returnAmmo and type(self.gunConfig.returnAmmo)=="table" then
  for k,v in pairs(self.gunConfig.returnAmmo) do
	activeItem.giveOwnerItem({name = k, count = v})
	self.gunConfig.returnAmmo[v] = nil
  end
	self.gunConfig.returnAmmo = nil
  else
	self.gunConfig.returnAmmo = nil
  end

  self.weapon:init()
end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
end

function uninit()
  self.weapon:uninit()
end

function shoot() --Shooting request
	if self.gunConfig.compatibleAmmo and not self.reloading then
		
		local itemammo = nil
		
		if self.gunConfig.magazineMax then
			if self.gunConfig.magazineCurrent > 0 then
				self.gunConfig.magazineCurrent = self.gunConfig.magazineCurrent - 1
				itemammo = true
			elseif player.hasItem(self.gunConfig.compatibleAmmo[1]) and cooldown <= 0 then
				magreload()
				return
			else
				animator.playSound("dry")
				smoke = 0
				activeItem.setRecoil(false)
				if self.gunConfig.magazineCurrent == 0 then
					cooldown = 0.5
				end
				return
			end
		else
			itemammo = player.consumeItem(self.gunConfig.compatibleAmmo[1])
		end
		
		if itemammo then --Ammo found!!
		
			local projectile = "bullet-2" --projectile default name
			local projectileconf = {}
			
			projectile = self.gunConfig.projectileType or "bullet-2"	--get projectile name **Might make some changes here
			projectileconf = copy(self.gunConfig.projectileConfig or {})	--multiplier dmg
			projectileconf.powerMultiplier = activeItem.ownerPowerMultiplier()	--multiplier dmg

		else --Ammo not found
			if animator.hasSound("dry") then --sound empty
				animator.playSound("dry")
			end
			smoke = 0
			activeItem.setRecoil(false)
			if self.gunConfig.magazineCurrent == 0 then
				cooldown = 0.1
			end
			recoil = recoil + 1
		end
		
	end
end