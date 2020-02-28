updateable = {}
updateable.list = {}
updateable.hasInited = false

function updateable:add(name)
	self.list[#self.list + 1] = name
	if self.hasInited then
		local name = self.list[#self.list]
		local t = type(name)
		if t == "table" and t.init then
			name:init()
		elseif t == "string" and type(_ENV[name]) == "table" and _ENV[name].init then
			_ENV[name]:init()
		end
	end
	return #self.list
end

function updateable:init()
	for i=1,#self.list do
		local name = self.list[i]
		local t = type(name)
		if t == "table" and t.init then
			name:init()
		elseif t == "string" and type(_ENV[name]) == "table" and _ENV[name].init then
			local st, e = pcall(function() _ENV[name]:init() end)
			if not st then
				sb.logError(e)
			end
		end
	end
	self.hasInited = true
end

function updateable:update(...)
	for i=1,#self.list do
		local name = self.list[i]
		local t = type(name)
		if t == "table" and name.update then
			name:update(...)
		elseif t == "string" and type(_ENV[name]) == "table" and _ENV[name].update then
			_ENV[name]:update(...)
		end
	end
end

function updateable:uninit()
	for i=1,#self.list do
		local name = self.list[i]
		local t = type(name)
		if t == "table" and name.uninit then
			name:uninit()
		elseif t == "string" and type(_ENV[name]) == "table" and _ENV[name].uninit then
			_ENV[name]:uninit()
		end
	end
end

function updateable:activate(...)
	for i=1,#self.list do
		local name = self.list[i]
		local t = type(name)
		if t == "table" and name.activate then
			name:activate(...)
		elseif t == "string" and type(_ENV[name]) == "table" and _ENV[name].activate then
			_ENV[name]:activate(...)
		end
	end
end

local oldinit = init or function() end
local oldupdate = update or function() end
local olduninit = uninit or function() end
local oldactivate = activate or function() end

function init(...)
	oldinit(...)
	if not updateable.hasInited then
		updateable:init(...)
	end
end

function update(...)
	if not updateable.hasInited then
		updateable:init(...)
	end
	oldupdate(...)
	updateable:update(...)
end

function uninit(...)
	olduninit(...)
	updateable:uninit(...)
end

function activate(...)
	oldactivate(...)
	updateable:activate()
end