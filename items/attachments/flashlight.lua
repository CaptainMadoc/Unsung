module = {
	
}

function module:create(config, name)
	local newClass = {}
	
	flashlightmanager:add(attachment.config[name].attachPart, attachment.config[name].gunTag, attachment.config[name].gunTagEnd, config.lightColor)
	
	function newClass:uninit()
	
	end
	
	return newClass
end
