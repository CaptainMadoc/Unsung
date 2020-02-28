include "config"
include "attachment"
include "localAnimator"
include "animator"

attachmentSystem = {}
attachmentSystem.currentSpecial = false
attachmentSystem.list = {}
attachmentSystem.specials = {}

--[[
"attachments" : {
	"attachname" : <attachment>
}
]]


function attachmentSystem:init()
	if config.giveback then
		for i,v in pairs(config.giveback) do
			player.giveItem(v)
		end
		config.giveback = {}
	end

	for attachname,aconfig in pairs(config.attachments) do
		self.list[attachname] = attachment:new(attachname, aconfig)
	end

	for i,v in pairs(self.list) do
		if self.list[i].init then
			self.list[i]:init()
		end
	end
end

function attachmentSystem:update(dt)
	for i,v in pairs(self.list) do
		if v.update then
			self.list[i]:update(dt)
		end
	end

	if self.uishow > 0 and self.currentSpecial then
		self.uishow = math.max(self.uishow - dt, 0)
		self.uiposlerp = self.uiposlerp + (activeItem.handPosition(self.list[self.specials[self.currentSpecial].name]:position()) - self.uiposlerp) / vec2(8)

		localAnimator.addDrawable(
			{
				image = "/unsunggunsimage/select.png",
				color = {255,255,255,math.floor(255 * self.uishow)},
				fullbright = true,
				centered = true,
				scale = 0.5,
				position = activeItem.handPosition(self.list[self.specials[self.currentSpecial].name]:position())
			},
			"overlay"
		)
		localAnimator.addDrawable(
			{
				line = {activeItem.handPosition(self.list[self.specials[self.currentSpecial].name]:position()), self.uiposlerp + vec2(4,4)},
				width = 0.5,
				color = {255,255,255,math.floor(128 * self.uishow)},
				fullbright = true,
				position = {0,0}
			},
			"overlay"
		)
		localAnimator.addDrawable(
			{
				line = {self.uiposlerp + vec2(9,4), self.uiposlerp + vec2(4,4)},
				width = 8,
				color = {0,0,0,math.floor(172 * self.uishow)},
				fullbright = true,
				position = {0,0}
			},
			"overlay"
		)
		localAnimator.addDrawable(
			{
				image = "/unsunggunsimage/selected.png",
				color = {255,255,255,math.floor(255 * self.uishow)},
				fullbright = true,
				scale = 0.5,
				position = self.uiposlerp + vec2(6.5,4)
			},
			"overlay"
		)
	end
end

function attachmentSystem:save()
	local attachments = {}
	for i,v in pairs(self.list) do
		if v.save then
			attachments[i] = self.list[i]:save()
		end
	end
	config.attachments = attachments
end

function attachmentSystem:uninit()
	for i,v in pairs(self.list) do
		if v.uninit then
			self.list[i]:uninit()
		end
	end
	self:save()
end

-- for systems Scripts
function attachmentSystem:addSpecial(name, callbackFunction)
	self.specials[#self.specials + 1] = {name = name, func = callbackFunction}

	if not self.currentSpecial then
		self.currentSpecial = 1
		self.uishow = 1
	end
end

function attachmentSystem:activate()
	if self.currentSpecial and self.specials[self.currentSpecial] and self.specials[self.currentSpecial].func then
		self.specials[self.currentSpecial].func()
	end
end

attachmentSystem.uishow = 0
attachmentSystem.uiposlerp = vec2(0)
function attachmentSystem:switch()
	if self.currentSpecial then
		self.currentSpecial = self.currentSpecial + 1

		if self.currentSpecial > #self.specials then
			self.currentSpecial = 1
			self.uishow = 1
		end
	end
end

function attachmentSystem:remove(name)
	if self.list[name] then
		local config = self.list[name]:save()
		if config.item then
			player.giveItem(config.item)
			config.item = nil
		end
		self.list[name] = attachment:new(name, config)
	end
end

function attachmentSystem:supressFiresound(sound)
	local soundName = settings:get("fireSound")
	if soundName and animator.hasSound(soundName) then
		if type(sound) == "string" then
			animator.setSoundPool(soundName, {sound})
		elseif type(sound) == "table" and sound.path then
			animator.setSoundPool(soundName, {sound.path})
			if sound.pitchMultiplier then
				animator.setSoundPitch(soundName, sound.pitchMultiplier)
			end
			if sound.volume then
				animator.setSoundVolume(soundName, sound.volume)
			end
		end
	end
end