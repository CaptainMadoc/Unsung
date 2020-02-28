include "config"
include "vec2"
include "vec2tableparser"
include "animator"

settings = {}
settings.default = {
    drySound = "null",
    fireSound = "null",
    fireTypes = {"auto", "burst", "semi"},
    showCasings = true,
    chamberEjection = true,
}
settings._values = {}
settings.inited = false

function settings:init()
	self:reset()
	self.inited = true
end

function settings:reset()
	self._values = config.parseValue("settings", "table") or {}
end

function settings:get(i)
    if not self.inited then self:init() end
    if type(self._values[i]) ~= "nil" then
        return self._values[i]
    end
	return self.default[i]
end

function settings:setFireSound(sound)
    animator.setSoundPool(self:get("fireSound"), {sound})
end

function settings:setDrySound(sound)
    animator.setSoundPool(self:get("drySound"), {sound})
end

