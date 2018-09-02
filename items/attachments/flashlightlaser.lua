module = {
	
}

function module:create(config, name)
	local newClass = {}
	
	flashlightmanager:add(attachment.config[name].attachPart, attachment.config[name].gunTag, attachment.config[name].gunTagEnd, config.lightColor)
	lasermanager:add(attachment.config[name].attachPart, attachment.config[name].gunTag, attachment.config[name].gunTagEnd, config.laserColor)
	weapon.stats.movingInaccuracy = weapon.stats.movingInaccuracy / 2
	weapon.stats.standingInaccuracy = weapon.stats.standingInaccuracy / 2
	weapon.stats.crouchInaccuracyMultiplier = weapon.stats.crouchInaccuracyMultiplier / 2
	
	function newClass:uninit()
	
	end
	
	return newClass
end
