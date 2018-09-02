module = {
	
}

function module:create(attachment)
	local newClass = {} 
	
	for i,v in pairs(attachment.stats) do
		if i == "fireSounds" then
			animator.setSoundPool("fireSounds", v)
		elseif weapon.stats[i] then
			weapon.stats[i] = math.max(v, 0)
		end
	end

	animator.setGlobalTag("magazine","/assetmissing.png")
	
	function newClass:update(dt)
	
	end
	
	function newClass:uninit()
		animator.setGlobalTag("magazine", "mag.png")
	end
	
	return newClass
end
