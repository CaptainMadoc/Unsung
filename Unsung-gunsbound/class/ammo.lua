ammo = {
	count = 0,
	type = "nil" --projectile name
	parameters = {}
}

function ammo:init()
	if config.getParameter("ammo") then
		ammo = config.getParameter("ammo")
	end
end

function ammo:build()
	local bullet = {type = self.type, parameters = {}}
	if self.parameters then
		bullet.parameters = self.parameters
	end
	return bullet
end

function ammo:use()
	if self.count > 0 then
		local bullet = self:build()
		self.count = self.ammo - 1
		return bullet
	end
	return false
end

function ammo:refill(item)
	if self.count > 0 then
		local toreturn = {name = "", count = self.count, parameters = self.parameters}
	end
	
	self.count = item.count
	self.parameters = item.parameters.parameters
	self.type = item.parameters.type
end

function ammo:update(dt)
	
end

function ammo:uninit()
	activeItem.setInstanceValue("ammo", {count = self.ammo, type = self.type, parameters = self.parameters})
end

addClass("ammo", -1)