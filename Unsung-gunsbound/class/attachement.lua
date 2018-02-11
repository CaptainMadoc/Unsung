attachement = {
	config = {}
}

function attachement:init()
	self.config = config.getParameter("attachements")
end

function attachement:lateinit()
	for i,v in pairs(self.config) do
		animator.setPartTag(v.part, "selfimage", v.item.parameters.attachement.image)
	end
end

function attachement:debug(dt)
	for i,v in pairs(self.config) do
		world.debugPoint(weapon:rel(animator.partPoint(v.part, "offset")), "blue")
	end
end

function attachement:update(dt)
	self:debug(dt)
end

function attachement:uninit()
	
end

addClass("attachement", 25)