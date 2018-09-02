module = {
	
}

function module:create(c, name)
	local newClass = {special = true, config = c, type = name, canFire = os.clock() + 1} 
	
	function newClass:update(dt)
	
	end
	
	function newClass:getAmmo()
		local listComp = root.assetJson(self.config.compatibleAmmo, {})
		for i,v in pairs(listComp) do
			if player.hasItem({name = v, count = 1}) then
				local taken = player.consumeItem({name = v, count = 1})
				local item = root.itemConfig(taken)
				local fitem = sb.jsonMerge(item.config, item.parameters)
				return fitem
			end
		end
	end
	
	function newClass:fireSpecial(a)
		if animation:isAnyPlaying() then
			return
		end
		if self.canFire < os.clock() then
			local ammo = newClass:getAmmo()
			if ammo then
				animator.playSound("grenadeSound")
				world.spawnProjectile(
					ammo.projectile or "grenadeimpact", 
					vec2.add(mcontroller.position(),activeItem.handPosition(animator.partPoint(attachment.config[self.type].attachPart, attachment.config[self.type].gunTag))),
					activeItem.ownerEntityId(),
					vec2.sub(activeItem.handPosition(animator.partPoint(attachment.config[self.type].attachPart, attachment.config[self.type].gunTagEnd)),activeItem.handPosition(animator.partPoint(attachment.config[self.type].attachPart, attachment.config[self.type].gunTag))),
					false,
					ammo.projectileConfig or {}
					)
			else
				animator.playSound("dry")
			end
			self.canFire = os.clock() + 1
		end
	end
	
	function newClass:uninit()
	
	end
	
	return newClass
end
