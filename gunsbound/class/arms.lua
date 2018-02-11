arms = {
	curdirection = 1,
	inited = false,
	twohand_current = false,
	twohand_target = false
}

function arms:setTwoHandedGrip(bool)
	self.twohand = bool
	self.curdirection = -arms.curdirection
	activeItem.setTwoHandedGrip(bool)
end

function arms:init()
	activeItem.setFrontArmFrame("rotation?scale=0")
	activeItem.setBackArmFrame("rotation?scale=0")
	
	self.current = config.getParameter("twoHanded", true)
	self.target = config.getParameter("twoHanded", true)
	self.twohand = config.getParameter("twoHanded", false)
	
	self.specie = world.entitySpecies(activeItem.ownerEntityId())
	
	if not self.specie then
		return
	end
	
	local handhold = activeItem.hand()
	local aim, direction = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
	local port = portrait:auto(activeItem.ownerEntityId())
	self.directives = portrait:skinDirectives(port)
	
	if self.directives then
		--if handhold == self:flipped("alt", direction) or self.twohand then
		animator.setGlobalTag("R_a1", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=0;0;24;43")
		animator.setGlobalTag("R_a2", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=23;0;27;43")
		animator.setGlobalTag("R_hand", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=26;0;31;43")
		--end
		
		if self.twohand then
			animator.setAnimationState("left", "back")
			animator.setAnimationState("right", "front")
			animator.setGlobalTag("L_a1", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=0;0;24;43")
			animator.setGlobalTag("L_a2", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=23;0;27;43")
			animator.setGlobalTag("L_hand", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=26;0;31;43")
		else
			animator.setGlobalTag("L_a1", "")
			animator.setGlobalTag("L_a2", "")
			animator.setGlobalTag("L_hand", "")
			animator.setAnimationState("left", arms:whatlayer(direction, handhold))
			animator.setAnimationState("right", arms:whatlayer(-direction, handhold))
		end
	end
	
	if port.FrontArmArmor then
		self.directory = portrait:getDirectory(port, "FrontArmArmor")
		self.armordirectives = portrait:getDirectives(port, "FrontArmArmor")
		
		animator.setGlobalTag("R_af1", self.directory..":rotation"..self.armordirectives.."?crop=0;0;24;43")
		animator.setGlobalTag("R_af2", self.directory..":rotation"..self.armordirectives.."?crop=23;0;27;43")
		animator.setGlobalTag("R_handf", self.directory..":rotation"..self.armordirectives.."?crop=26;0;31;43")
		
		if self.twohand then
			animator.setGlobalTag("L_af1", self.directory..":rotation"..self.armordirectives.."?crop=0;0;24;43")
			animator.setGlobalTag("L_af2", self.directory..":rotation"..self.armordirectives.."?crop=23;0;27;43")
			animator.setGlobalTag("L_handf", self.directory..":rotation"..self.armordirectives.."?crop=26;0;31;43")
		end
	else
		animator.setGlobalTag("R_af1",  "")
		animator.setGlobalTag("R_af2",  "")
		animator.setGlobalTag("R_handf", "")
		animator.setGlobalTag("L_af1", 	 "")
		animator.setGlobalTag("L_af2", 	 "")
		animator.setGlobalTag("L_handf", "")
	end
	self.inited = true
end

function arms:flipped(arm, dir)
	if dir > 0 then
		return arm
	end
	if arm == "alt" then
		return "primary"
	else
		return "alt"
	end
end

function arms:whatlayer(dir, arm)
	if arm == "alt" then dir = -dir end

	if dir > 0 then
		return "front"
	else
		return "back"
	end
end

function arms:update(dt)
	if not self.inited then
		self:init()
		return
	end
	
	if self.twohand_current ~= self.twohand_target then
		self:setTwoHandedGrip(self.twohand_target)
		self.twohand_current = self.twohand_target
	end
	
	local aim, direction = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
	if self.curdirection ~= direction then
		self.curdirection = direction
		local handhold = activeItem.hand()
		
		if self.twohand then
			animator.setAnimationState("left", "back")
			animator.setAnimationState("right", "front")
			animator.setGlobalTag("L_a1", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=0;0;24;43")
			animator.setGlobalTag("L_a2", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=23;0;27;43")
			animator.setGlobalTag("L_hand", "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives.."?crop=26;0;31;43")
		else
			animator.setGlobalTag("L_a1", "")
			animator.setGlobalTag("L_a2", "")
			animator.setGlobalTag("L_hand", "")
			animator.setAnimationState("left", arms:whatlayer(direction, handhold))
			animator.setAnimationState("right", arms:whatlayer(-direction, handhold))
		end
		
		if self.armordirectives then
			
			if self.twohand then
				animator.setGlobalTag("L_af1", self.directory..":rotation"..self.armordirectives.."?crop=0;0;24;43")
				animator.setGlobalTag("L_af2", self.directory..":rotation"..self.armordirectives.."?crop=23;0;27;43")
				animator.setGlobalTag("L_handf", self.directory..":rotation"..self.armordirectives.."?crop=26;0;31;43")
			else
				animator.setGlobalTag("L_af1", "")
				animator.setGlobalTag("L_af2", "")
				animator.setGlobalTag("L_handf", "")
			end
		end
		
	end
end

addClass("arms", -48)