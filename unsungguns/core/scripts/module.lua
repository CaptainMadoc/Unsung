include "directory"
include "tableutil"

_nestedmodules = {}
function module(path)
	if _nestedmodules[path] then
		return table.copy(_nestedmodules[path])
	end
	
	local m = nil
	if module then
		m = module
		module = nil
	end

	_SBLOADED = {}
	require(directory(path, corePath))
	if module then
		_nestedmodules[path] = table.copy(module)
	end

	if m then
		module = m
	end
	return table.copy(_nestedmodules[path])
end