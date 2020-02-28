include "updateable"
include "localAnimator"
include "activeItem"
include "vec2"
include "muzzle"
include "mcontroller"

crosshair = {}
crosshair.primaryColor = {255,255,255,72}
crosshair.secondaryColor = {0,0,0,72}
crosshair.width = 2

local function circle(d, steps)
	local pos = vec2(d,0)
	local pol = {}
	for i=1,steps do
		table.insert(pol,pos)
		pos = pos:rotate(math.rad(360 / steps))
	end
	return pol
end

function crosshair:init()
	activeItem.setCursor("/unsungguns/cursor/crosshair.cursor")
end

function crosshair:update(dt)
	if crosshair.disable then return end

	local inAccuracy = muzzle.inaccuracy

	local muzzlePosition = vec2(0)
	for i,v in pairs(muzzle:getPositions()) do
		muzzlePosition = muzzlePosition:lerp(v)
	end
	
	local muzzleDistance = world.distance(activeItem.ownerAimPosition(), activeItem.handPosition(muzzlePosition) + mcontroller.position())
	local distance = (math.abs(muzzleDistance[2]) + math.abs(muzzleDistance[1])) / 2
	local cir = circle((0.125 + (inAccuracy / 45) * distance), 32)
	local position = (activeItem.ownerAimPosition() + vec2(0.03125,-0.03125) - mcontroller.position()):rotate(math.rad(aim:getRecoil()) * mcontroller.facingDirection())
	
	for i=2,#cir do
		localAnimator.addDrawable(
			{
				line = {cir[i - 1], cir[i]},
				width = self.width, 
				color = self.secondaryColor,
				fullbright = true, 
				position = position
			}, 
			"overlay"
		)
		localAnimator.addDrawable(
			{
				line = {cir[i - 1], cir[i]},
				width = self.width - 1, 
				color = self.primaryColor,
				fullbright = true, 
				position = position
			}, 
			"overlay"
		)
	end
	
	
	localAnimator.addDrawable(
		{
			line = {cir[1], cir[#cir]},
			width = self.width, 
			color = self.secondaryColor,
			fullbright = true, 
			position = position
		},
		"overlay"
	)
	
	localAnimator.addDrawable(
		{
			line = {cir[1], cir[#cir]},
			width = self.width - 1, 
			color = self.primaryColor,
			fullbright = true, 
			position = position
		},
		"overlay"
	)

end

updateable:add("crosshair")