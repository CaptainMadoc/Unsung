stance = {
	info = {
		editing = false,
		origin = {}
	},
	animations = {
		
	},
	events = {
	
	}
}

function stance:setPrev(tab)
	
	for i2,v2 in pairs(self.info.origin) do
		for i3,v3 in pairs(v2) do
			drawable.transforms[i2][i3] = self:copycat(v3)
		end
	end
	
	for i2,v2 in pairs(tab) do
		for i3,v3 in pairs(v2) do
			drawable.transforms[i2][i3] = self:copycat(v3)
		end
	end
	
end

function stance:setupMessages()
	message.setHandler("getTransforms", function(_, loc, arg) if loc then return drawable.get() end return false end)
	message.setHandler("setPrevStance", function(_, loc, arg) if loc then self:setPrev(arg) end return true end)
	message.setHandler("setEditing", function(_, loc, arg) if loc then self.info.editing = arg return drawable:get() end end)
	message.setHandler("setEditingWait", function(_, loc, arg) if loc then self.info.editingwait = arg end return true end)
	message.setHandler("setOrigin", function(_, loc, arg) if loc then self.info.origin = arg end return true end)
end

function stance:init()
	local animationStancesConfig = {}
	local animationStancesT = config.getParameter("animationStances")
	if type(animationStancesT) == "table" then
		animationStancesConfig = animationStancesT
	elseif type(animationStancesT) == "string" then
		animationStancesConfig = root.assetJson(processDirectory(animationStancesT))
	end
	--config loader
	for i,v in pairs(animationStancesConfig) do
		self.animations[i] = v
		self.animations[i].playing = false
		self.animations[i].keyframe = 1
		self.animations[i].wait = 0
	end
	self:setupMessages()
	self.info.origin = drawable:get()
end

function stance:addEvent(flag, func)
	self.events[flag] = func
end

function stance:set(info, transformonly) --keyframe for animations
	
	for i2,v2 in pairs(info.sprite or {}) do
		if drawable.transforms[i2] then
			for i3,v3 in pairs(info.sprite[i2]) do
				drawable.transforms[i2][i3] = self:copycat(v3)
			end
		else
			sb.logWarn("No Such Transform %s", i2)
		end
	end
	
	for i,v in pairs(info.animationState or {}) do
		animator.setAnimationState(i, v)
	end
	
	for i,v in pairs(info.lights or {}) do
		animator.setLightActive(i, v)
	end
	
	for i,v in pairs(info.flags or {}) do
		if self.events[v] then
			self.events[v]()
		end
	end
	
	if transformonly then
		return
	end
	
	for i,v in pairs(info.burstParticle or {}) do
		animator.burstParticleEmitter(v)
	end
	
	if #(info.sounds or {}) > 0 then
		self:sound(self:copycat(info.sounds))
	end
end

function stance:update(dt)
	for name, tab in pairs(self.animations) do
		if self.animations[name].playing then
			if self.animations[name].wait == 0 then
				if #self.animations[name].key > self.animations[name].keyframe then
					self:set(self.animations[name].key[self.animations[name].keyframe + 1])
					self.animations[name].wait = math.max(self.animations[name].key[self.animations[name].keyframe + 1].wait, 0)
					self.animations[name].keyframe = self.animations[name].keyframe + 1
				else
					self.animations[name].playing = false
				end
			else
				self.animations[name].wait = math.max(self.animations[name].wait - dt, 0)
			end
		end
	end
	--stance:debug(dt)
end

function stance:debug(dt)
	local y = 1
	for name, tab in pairs(self.animations) do
		world.debugText("("..tostring(tab.playing)..")"..name.." : "..tab.keyframe, 123, vec2.add(mcontroller.position(), {0, y}), "green")
		y = y + 1
	end
end

function stance:skip(name)
	if self.animations[name].playing then
		for i = self.animations[name].keyframe, #self.animations[name].key do
			self:set(self.animations[name].key[i], true)
		end
		self.animations[name].playing = false
		self.animations[name].wait = 0
		return true
	else
		return false
	end
end

function stance:isPlaying(name)
	local t = type(name)
	local f = false
	if t == "string" then 
		if self.animations[name] then
			return self.animations[name].playing
		end
	elseif t == "table" then 
		for i,v in pairs(name) do
			if self.animations[v] and self.animations[v].playing then
				f = true
			end
		end
	end
	return f
end

function stance:isAnyPlaying() --good for singular animation
	local f = false
	for i,v in pairs(self.animations) do
		if v.playing then
			f = true
		end
	end
	return f
end

function stance:busy()
	return not self.info.finished or self.info.editing
end

function stance:play(name)
	if name == nil then
		sb.logWarn("name == nil")
		return
	end
	if self.animations[name] then
		if self.animations[name].playing then
			self:skip(name)
		end
		if #self.animations[name].key > 0 then
			self.animations[name].playing = true
			self.animations[name].keyframe = 1
			self.animations[name].wait = math.max(self.animations[name].key[1].wait, 0)
			self:set(self.animations[name].key[1])
		else
			sb.logWarn("Cannot play animation %s since it doesnt contain any keys.", name)
		end
	end
end

--util
function stance:strStarts(str, start)
	return string.sub(str,1,string.len(start)) == start
end

function stance:remStart(str, start)
	return string.sub(str,start + 1,string.len(str))
end

function stance:sound(sounddata) --Multi Sound by projectile
	local actions = {}
	for i,v in pairs(sounddata) do
		if self:strStarts(v, "@") then
			animator.playSound(self:remStart(v, 1))
		else
			table.insert(actions, 
				{
					action = "sound",
					options = { v }
				}
			)
		end
	end
	
	if #actions == 0 then
		table.insert(actions, 
			{
				action = "sound",
				options = { "/assetmissing.ogg" }
			}
		)
	end
	
	local soundIde = world.spawnProjectile(
		"invisibleprojectile",
		mcontroller.position(),
		activeItem.ownerEntityId(),
		{0,0},
		true,
		{
			timeToLive = 1/60, 
			power = 0,
			damageType = "NoDamage",
			universalDamage = false,
			actionOnReap = actions,
			processing = "?replace;F7D5D3=F7D5D300;754C23=00000000;A47844=A4784400"
		}
	)
	return soundIde
end

function stance:copycat(var)
	if type(var) == "number" then
		return 0 + var
	end
	if type(var) == "table" then
		local newtab = {}
		for i,v in pairs(var) do
			newtab[i] = v
		end
		return newtab
	end
	return var
end

--

addClass("stance", -49)