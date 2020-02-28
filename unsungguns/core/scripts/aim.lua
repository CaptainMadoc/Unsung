include "activeItem"

local function lerp(a,b,r)
	return a + (b - a) * r
end

local function round(n)
	if n % 1 > 0.5 then
		return math.ceil(n)
	end
	return math.floor(n)
end

aim = {}
aim._recoillerp = 0
aim._recoil = 0
aim.recoilRecovery = 8
aim.recoilResponse = 8

aim.offset = 0

aim.enabled = true
aim.current = 0
aim.angle = 0
aim.facing = 0

function aim:init()
	activeItem.setArmAngle(0)
	message.setHandler("enableAim", function(_,loc) if not loc then return end self.enabled = true end)
	message.setHandler("disableAim", function(_,loc) if not loc then return end self.enabled = false end)
end

function aim:update(dt)
	if self.enabled then
		self._recoillerp = lerp(self._recoillerp, self._recoil, 1 / self.recoilResponse)
		if round(self._recoil) ~= 0 then
			self._recoil = lerp(self._recoil, 0, 1 / self.recoilRecovery)
			if round(self._recoil) == 0 then
				self._recoil = 0
			end
		end

		self.current = self.angle
		activeItem.setArmAngle(math.rad(self.current + self.offset + self._recoillerp))
		activeItem.setFacingDirection(self.facing)
	else
		activeItem.setArmAngle(math.rad(self.offset))
	end
end

function aim:at(at)
	local aim, facing = activeItem.aimAngleAndDirection(0, at)
	self.angle = aim * 180/math.pi
	self.facing = facing
end

local antilock = false
function dualwieldrecoil(angle)
	if antilock then return end
	antilock = true
	aim:recoil(angle)
	antilock = false
end

function aim:recoil(angle)
	if self.current < -45 then
		angle = -angle
	end
	self._recoil = self._recoil + angle
	if not config.twoHanded then
		local otherhandfunc = activeItem.callOtherHandScript("dualwieldrecoil", angle)
	end
end

function aim:getRecoil()
	return self._recoil
end
