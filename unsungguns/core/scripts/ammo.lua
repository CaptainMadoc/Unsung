include "itemConfig"
include "tableutil"

ammo = {}
ammo.itemName = ""
ammo.config = {}
ammo.parameters = {}
ammo.count = 0

function ammo:new(item) -- loads from a item
	local n = table.copy(self)
	n.itemName = item.name
	n.config = itemConfig(item)
	n.parameters = item.parameters or {}
	n.count = item.count
	return n
end

--test placeholder
function ammo:create(projectileName, projectileConfig)
	self.parameters.projectile = projectileName
	self.parameters.projectileConfig = projectileConfig
end

function ammo:save() -- returns a item
	return {
		name = self.itemName,
		count = self.count,
		parameters = self.parameters
	}
end

function ammo:use()
	if self.count > 0 then
		self.count = self.count - 1
		local copy = table.copy(self)
		copy.count = 1
		return copy
	end
	return false
end

function ammo:projectileArgs(position, direction)
	return {
		self.parameters.projectile or self.config.projectile,
		position,
		0,
		direction,
		false,
		self.parameters.projectileConfig or self.config.projectileConfig
	}
end

function ammo:casing(position, direction)
	local projectileArgs = {
		self.parameters.casingProjectile or self.config.casingProjectile,
		position,
		0,
		direction,
		false,
		self.parameters.casingProjectileConfig or self.config.casingProjectileConfig
	}
	if self.count > 0 then
		projectileArgs[6] = projectileArgs[6] or {}
		projectileArgs[6].actionOnReap = projectileArgs[6].actionOnReap or jarray()
		local ammoitem = self:save()
		projectileArgs[6].actionOnReap[#projectileArgs[6].actionOnReap + 1] = {action = "item", name = ammoitem.name, count = ammoitem.count, parameters = ammoitem.parameters} 
	end
	return projectileArgs
end
