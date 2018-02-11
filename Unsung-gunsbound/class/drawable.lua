drawable = {
	transforms = {}
}

function drawable:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function drawable:init()
	for i,v in pairs(root.assetJson(config.getParameter("animation")).transformationGroups) do
		self.transforms[i] = v
		sb.logInfo("animation: "..i)
	end
	for i,v in pairs(config.getParameter("animationCustom").transformationGroups) do
		self.transforms[i] = v
		sb.logInfo("animationC: "..i)
	end
	self.transforms.aimoffset = {
		smoothness 			= 4,
		
		--Position stuff
		position 			= {0,0},
		setposition 		= {0,0},
		
		--Rotation stuff
		rotation 			= -90,	
		setrotation 		= 0,	
		rPoint 				= {0,0},
		setrPoint 			= {0,0},
		
		--Scale stuff
		scale 				= {1,1},
		sPoint 				= {0,0},
		setscale 			= {1,1},
		setsPoint 			= {0,0},
		
	}
end

function drawable:get()
	local draws = {}
	for i,v in pairs(root.assetJson(config.getParameter("animation")).transformationGroups) do
		if i ~= "interpolated" then
			draws[i] = v
		end
	end
	for i,v in pairs(config.getParameter("animationCustom").transformationGroups) do
		if i ~= "interpolated" then
			draws[i] = v
		end
	end
	draws.aimoffset = {
		smoothness 			= 4,
		
		--Position stuff
		position 			= {0,0},
		setposition 		= {0,0},
		
		--Rotation stuff
		rotation 			= 0,	
		setrotation 		= 0,	
		rPoint 				= {0,0},
		setrPoint 			= {0,0},
		
		--Scale stuff
		scale 				= {1,1},
		sPoint 				= {0,0},
		setscale 			= {1,1},
		setsPoint 			= {0,0},
		
	}
	return draws
end

function drawable:update(dt) --Do not mess with the settings unless you know what are doing.
	for i,v in pairs(self.transforms) do --Seeks every data set by the user.
		local smoothnessdt = math.max(v.smoothness / (dt * 60), 1)
		self.transforms[i].position[1] 	= self:lerp(v.position[1]	, 	v.setposition[1]	, 	smoothnessdt)
		self.transforms[i].position[2] 	= self:lerp(v.position[2]	, 	v.setposition[2]	, 	smoothnessdt)
		self.transforms[i].rPoint[1] 	= self:lerp(v.rPoint[1]		, 	v.setrPoint[1]		, 	smoothnessdt)
		self.transforms[i].rPoint[2] 	= self:lerp(v.rPoint[2]		,	v.setrPoint[2]		, 	smoothnessdt)
		self.transforms[i].rotation 		= self:lerp(v.rotation		,	v.setrotation	,	smoothnessdt)
		self.transforms[i].scale[1] 		= self:lerp(v.scale[1]		,	v.setscale[1]	, 	smoothnessdt)
		self.transforms[i].scale[2] 		= self:lerp(v.scale[2]		,	v.setscale[2]	, 	smoothnessdt)
		self.transforms[i].sPoint[1] 	= self:lerp(v.sPoint[1]		, 	v.setsPoint[1]		, 	smoothnessdt)
		self.transforms[i].sPoint[2] 	= self:lerp(v.sPoint[2]		,	v.setsPoint[2]		, 	smoothnessdt)
		
		--Applies new position
		if animator.hasTransformationGroup(i) then --Check to prevent crashing
			animator.resetTransformationGroup(i) 
			animator.rotateTransformationGroup(i, util.toRadians(v.rotation), v.rPoint)
			animator.scaleTransformationGroup(i, v.scale, v.sPoint)
			animator.translateTransformationGroup(i, v.position)
		elseif i ~= "aimoffset" then
			sb.logWarn("Transform %s does not exists in the animation!", i)
			self.transforms[i] = nil --Deletes the invalid transform
		end
	end
end

addClass("drawable", -50)