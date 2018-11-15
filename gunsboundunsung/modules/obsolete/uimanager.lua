uimanager = {}

function uimanager:init()
end

function uimanager:lateinit()
	local uiShell =  config.getParameter("uiShell")
	if uiShell then
		activeItem.setScriptedAnimationParameter("uiShell", vDir(uiShell, selfItem.rootDirectory))
		
	end
end

function uimanager:update(dt)
	
	activeItem.setScriptedAnimationParameter("load", type(weapon.load))
	
	
	--to fix
	local t = false
	
	if weapon.load and weapon.load.parameters.fired then
		t = true
		activeItem.setScriptedAnimationParameter("fired", true)
	end
	
	if not t then
		activeItem.setScriptedAnimationParameter("fired", false)
	end
	
	activeItem.setScriptedAnimationParameter("fireSelect",  weapon.fireTypes[weapon.fireSelect])
	activeItem.setScriptedAnimationParameter("inAccuracy",  weapon:getInAccuracy())
	activeItem.setScriptedAnimationParameter("althanded",  activeItem.hand() == "alt")
	activeItem.setScriptedAnimationParameter("muzzleDistance",  world.distance(activeItem.ownerAimPosition(),weapon:rel(animator.partPoint("gun", "muzzle_begin"))))

end

function uimanager:uninit()
end

addClass("uimanager", 620)