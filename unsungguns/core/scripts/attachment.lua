include "itemConfig"
include "tableutil"
include "attachmentSystem"
include "module"
include "vec2"
include "mcontroller"

attachment = {}

attachment.item = nil
attachment.part = nil
attachment.transform = nil

attachment.name = nil
attachment.config = nil
attachment.instance = nil

--[[
"config" : {
	"item" : <Item>,
	"storage" : {},
	"part" : "<partname>",
	"transform" : "<transformname>" //defaults to his own name ex: "attachment_attachname"
}
]]

function attachment:new(name, config)
	local n = table.copy(self)
	sb.logInfo(name.." = "..sb.printJson(config))
	if config.item then
		n.item = config.item
		n.itemconfig = sb.jsonMerge(itemConfig(config.item), config.item.parameters)
	end
	n.part = config.part or "attachment_"..name
	n.transform = config.transform or "attachment_"..name
	n.name = name
	n.config = config
	if n.itemconfig and n.itemconfig.attachment.script then
		n.instance = module(n.itemconfig.attachment.script)
		n.instance.storage = config.storage or {}
		n.instance.config = n.itemconfig.attachment or {}
		n.instance.transform = n.transform
		n.instance.partName = n.part
		n.instance.directory = itemDirectory(n.item)
		n.instance.name = name
		if n.instance.activate then
			attachmentSystem:addSpecial(name, function() n.instance:activate() end)
		end
	end

	return n
end

function attachment:init()
	if self.instance and self.instance.init then 
		self.instance:init()
	end
end

function attachment:update()
	if self.instance and self.instance.update then 
		self.instance:update()
	end
end

function attachment:uninit()
	if self.instance and self.instance.uninit then 
		self.instance:uninit()
	end
end

function attachment:position(offset)
	return animator.transformPoint(offset or {0,0},self.part)
end

function attachment:save()
	local conf = {}
	conf.item = self.item
	conf.part = self.part
	if self.instance and self.instance.storage then
		conf.storage = self.instance.storage
	end
	conf.transform = self.transform
	return conf
end