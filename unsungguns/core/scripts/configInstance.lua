include "directory"

configInstance = {}
configInstance.config = {}
configInstance.parameters = {}
configInstance.directory = "/"
configInstance.notInited = true


function configInstance:init()
	if item then
		local itemConfig = root.itemConfig({name = item.name(), count = 1})
		self.config = itemConfig.config
		self.parameters = item.descriptor()
		self.directory = itemConfig.directory or "/"
	else
		self.config = {}
		self.parameters = config.getParameter("", {})
		self.directory = self.parameters.directory or "/"
	end
end

function configInstance:uninit()
	for i,v in pairs(self.parameters) do
		if type(v) ~= "function" and type(v) ~= "userdata" then
			--saving here
		end
	end
end

function configInstance:getAnimation()
	local animations = self:getParameterWithConfig("animation")
	if type(animations) == "string" then
		animations = root.assetJson(directory(animations), {})
	end
	local animationCustom = self:getParameterWithConfig("animationCustom")
	return sb.jsonMerge(animations, animationCustom)
end

function configInstance:getParameterWithConfig(name)
	if type(self.config[name]) == "table" and type(self.parameters[name]) == "table" then
		return sb.jsonMerge(self.config[name], self.parameters[name])
	end
	return self.parameters[name] or self.config[name]
end

setmetatable(configInstance,
	{
		__newindex = function(t, key, value)
			if not configInstance.notInited then configInstance.notInited = nil configInstance:init() end
			configInstance.parameters[key] = value
			--saving here
		end,
		__index = function(t, key)
			if not configInstance.notInited then configInstance.notInited = nil configInstance:init() end
			return configInstance.parameters[key] or configInstance.config[key]
		end
	}
)
