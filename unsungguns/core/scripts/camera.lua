include "vec2"
include "activeItem"
include "updateable"
include "mcontroller"
include "world"

camera = {}
camera.position = vec2(0)
camera.target = vec2(0)
camera.lerpRatio = 0.5

function camera:init()
	self:checkAlive()
end

function camera:update()
	self:checkAlive()
	if world.entityExists(self.projectileId) then
		self.position = self.position:lerp(self.target, self.lerpRatio)
		world.callScriptedEntity(self.projectileId, "mcontroller.setPosition", mcontroller.position() + self.position)
		world.callScriptedEntity(self.projectileId, "mcontroller.setVelocity", {0,0})
	end
end

function camera:uninit()
	if self.projectileId and world.entityExists(self.projectileId) then
		world.callScriptedEntity(self.projectileId, "projectile.die")
	end
end

function camera:checkAlive()
	if not self.projectileId then
		self:respawnProjectile()
	elseif not world.entityExists(self.projectileId) then
		self:respawnProjectile()
	end
end

function camera:respawnProjectile()
	self.projectileId = world.spawnProjectile(
		"scouteye",
		mcontroller.position() + self.position,
		activeItem.ownerEntityId(),
		{0,0},
		false,
		{
			timeToLive = 10000, 
			power = 0,
			damageType = "NoDamage",
			universalDamage = false,
			processing = "?setcolor=ffffffff?replace;ffffffff=00000000",
			actionOnReap = jarray(),
			periodicActions = jarray()
		}
	)
	activeItem.setCameraFocusEntity(self.projectileId)
end

updateable:add("camera")