include "config"
include "vec2"
include "vec2tableparser"

stats = {}
stats.default = {
	maxMagazine = 30,
	recoilRecovery = 7,
	burst = 3,
	burstCooldown = 0.2,
	movingInaccuracy = 20,
	standingInaccuracy = 0,
	crouchInaccuracyMultiplier = 0.5,
	damageMultiplier = 1.0,
	recoil = 10.0,
	rpm = 500.0,
	aimLookRatio = 0.125,
	muzzleFlash = 1,
}
stats._values = {}
stats.inited = false

function stats:init()
	self:reset()
	self.inited = true
end

function stats:reset()
	self._values = vec2tableparser(config.parseValue("stats", "table")) or {}
end

function stats:add(a)
	if not self.inited then self:init() end
	for i,v in pairs(a) do
		if self._values[i] and type(self._values[i]) == type(v) then
			self._values[i] = self._values[i] + v
		end
	end
end

function stats:get(i)
	if not self.inited then self:init() end
	return self._values[i] or self.default[i]
end

function stats:set(i,v)
	if not self.inited then self:init() end
	self._values[i] = v
end