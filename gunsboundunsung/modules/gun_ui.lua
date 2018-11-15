--requires ui.lua

gun_ui = {
	disable = false,
	elementID = ""
}

function gun_ui:init()
	self.elementID = ui:newElement(self:createElement_FireMode())
end

function gun_ui:createElement_FireMode()
	local element = {
		althand = activeItem.hand() == "alt"
	}

	function element:init()
		self.althand = activeItem.hand() == "alt"
	end

	function element:draw()
		local todraw = {}
		if gun_ui.disable then return todraw end
		local fireSelected = gun:fireMode()

		if fireSelected then
			self.althand = activeItem.hand() == "alt"
			
    	    local offset = {-1.5,-6}
			local directive = ""
			
			if self.althand then
    	        offset[1] = 1.5
    	        directive = "?flipx"
			end

			table.insert(todraw, 
				{
					func = "addDrawable",
					args = {
						{
							image = "/gunsboundunsung/gunUI/"..fireSelected..".png"..directive,
							position = vec2.add( mcontroller.position(), offset ),
							fullbright = true
						},
						"overlay"
					}
				}
			)
		end

		return todraw
	end

	return element
end



addClass("gun_ui")