include "vec2"
include "world"

rays = {}

function rays.collide(from, angle, range) --bigger range can mean big lag
	return world.lineCollision( from, from + vec2(1 * range,0):rotate(angle) ) 
		or from + vec2(1 * range,0):rotate(0)
end