magazine = {
	storage = {
		--{name = "9mm" parameters = {type = "9mm", casing = "9mm.png", projectile = "bullet-4", projectileConfig = {}}}
	}
}

function magazine:insert()
	for i,v in pairs(config.getParameter("compatibleAmmo", root.assetJson("/gunsbound/compatibleAmmo/default.json"))) do
		if #self.storage < weapon.stats.maxMagazine then
			if player.hasItem({name = v, count = 1}) then
				local con = player.consumeItem({name = v, count = weapon.stats.maxMagazine - #self.storage}, true)
				
				for i = 1,con.count do
					table.insert(self.storage, {name = v, count = 1, parameters = con.parameters})
				end
			end
		end
	end
	activeItem.setInstanceValue("magazine", self.storage)
end

function magazine:remove()
	local togive = jarray()
	for i,v in pairs(self.storage) do
		if #togive == 0 then
			table.insert(togive,v)
		else
			local matched = false
			for i2,v2 in pairs(togive) do
				if sb.printJson(v.parameters) == sb.printJson(v2.parameters) and v.name == v2.name then
					matched = true
					togive[i2].count = togive[i2].count + v.count
				end
			end
			if not matched then
				table.insert(togive, v)
			end
		end
	end
	for i,v in pairs(togive) do
		player.giveItem(v)
	end
	self.storage = jarray();
	activeItem.setInstanceValue("magazine", self.storage)
end

function magazine:init()
	self.storage = config.getParameter("magazine", jarray())
	
end

function magazine:lateinit()
	stance:addEvent("insert_mag", function() magazine:insert() end)
	stance:addEvent("remove_mag", function() magazine:remove() end)
	sb.logInfo("lateinit mag")
end

function magazine:take()
	if #self.storage > 0 then
		local ammoPull = self.storage[#self.storage]
		table.remove(self.storage,#self.storage)
		if not ammoPull.parameters then
			ammoPull.parameters = {}
		end
		
		if not ammoPull.parameters.type and not ammoPull.parameters.projectile then
			local newConfig = root.itemConfig({name = ammoPull.name, count = 1}).config
			
			ammoPull.parameters.type = newConfig.type
			ammoPull.parameters.casing = newConfig.casing
			ammoPull.parameters.projectile = newConfig.projectile
			ammoPull.parameters.projectileConfig = newConfig.projectileConfig
		end
		activeItem.setInstanceValue("magazine", self.storage)
		return ammoPull
	end
	return nil
end

function magazine:update(dt)
	activeItem.setScriptedAnimationParameter("magazine", #self.storage)
	activeItem.setScriptedAnimationParameter("maxMagazine", weapon.stats.maxMagazine or 30)
end

function magazine:uninit()
	activeItem.setInstanceValue("magazine", self.storage)
end

addClass("magazine", -2)