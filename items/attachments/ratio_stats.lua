module = {
	
}

function module:create(attachment)
	local newClass = {} 
	
	for i,v in pairs(attachment.stats) do
		if i == "fireSounds" then
			animator.setSoundPool("fireSounds", v)
		elseif weapon.stats[i] then
			weapon.stats[i] = math.max(weapon.stats[i] * v, 0)
		end
	end	
	
	function newClass:update(dt)
	
	end
	
	function newClass:uninit()
	
	end
	
	return newClass
end
