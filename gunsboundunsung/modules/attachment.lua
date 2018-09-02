attachment = {
	statsInited = false,
	config = {},
	modules = {},
	loadedScripts = {},
	special = nil
}

function attachment:activate(fireMode, shiftHeld)
	if fireMode == "alt" and not shiftHeld then
		if self.special and self.modules[self.special] and self.modules[self.special].fireSpecial then
			self.modules[self.special]:fireSpecial(fireMode, shiftHeld)
		end
	end
end

function attachment:init()
	self.gunPart = config.getParameter("attachments_gunPart")
	self.config = config.getParameter("attachments")

	for i,v in pairs(config.getParameter("giveback", {})) do
		player.giveItem(v)
	end
	activeItem.setInstanceValue("giveback", jarray())
end

function attachment:createTransform(namee, offset, scale, attachPart, gunTag, gunTagEnd) -- for transforms.lua
	if not animator.partPoint(attachPart, gunTag) or not animator.partPoint(attachPart, gunTagEnd) then return end

	local somenewTransform = function(name, this, dt)

		if animator.hasTransformationGroup(name) then --Check to prevent crashing
			local setting  = {
				position = vec2.add(animator.partPoint(attachPart, gunTag), vec2.mul(offset or {0,0}, scale or {1,1})),
				scale = scale or {1,1},
				scalePoint = {0,0},
				rotation = vec2.angle(vec2.sub(animator.partPoint(attachPart, gunTagEnd), animator.partPoint(attachPart, gunTag))) or 0,
				rotationPoint = vec2.mul(offset or {0,0}, -1)
			}
			--debug purposes

			animator.resetTransformationGroup(name) 
			animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
			animator.rotateTransformationGroup(name, setting.rotation, vec2.mul(setting.rotationPoint,setting.scale))
			animator.translateTransformationGroup(name, setting.position)

			local pos = animator.partPoint(attachPart, gunTag)
			
			world.debugPoint(weapon:rel(pos), "blue")
			world.debugText(name.." = "..sb.printJson(pos,0), vec2.add(weapon:rel(pos), {0.05, 0.05}), "#00000010")
			world.debugText(name.." = "..sb.printJson(pos,0), vec2.add(weapon:rel(pos), {0,0}), "#ffffff40")
		end

	end

	transforms:lateAdd(namee, {}, somenewTransform)
end

function attachment:lateinit() --item check
	local attachmentsConfig = root.itemConfig({name = item.name(), count = 1}).config.attachments -- original attachment config from weapon

	for i,v in pairs(self.config) do
		if (attachmentsConfig[i] or not v) and not animator.partPoint(v.attachPart or attachmentsConfig[i].attachPart, v.gunTag or attachmentsConfig[i].gunPart) then
			self.config[i] = nil
		else
			if v.item then
				local originalItem = root.itemConfig({name = v.item.name, count = 1})
				local fp = {}

				if originalItem and 
					((attachmentsConfig[i] and attachmentsConfig[i].part) or (v and v.part)) and 
					((attachmentsConfig[i] and attachmentsConfig[i].attachPart) or (v and v.attachPart)) and 
					((attachmentsConfig[i] and attachmentsConfig[i].gunPart) or (v and v.gunTag)) and 
					((attachmentsConfig[i] and attachmentsConfig[i].transformationGroup) or (v and v.transformationGroup)) and
					((attachmentsConfig[i] and attachmentsConfig[i].gunTagEnd) or (v and v.gunTagEnd)) then

					fp = sb.jsonMerge(root.itemConfig(v.item).config, v.item.parameters) -- v.item.parameters
					local current;
					if fp.attachment then
						animator.setPartTag(v.part or attachmentsConfig[i].part, "selfimage", vDir(fp.attachment.image, originalItem.directory))
						attachment:createTransform(
							v.transformationGroup or attachmentsConfig[i].transformationGroup,
							fp.attachment.offset,
							fp.attachment.scale,
							v.attachPart or attachmentsConfig[i].attachPart,
							v.gunTag or attachmentsConfig[i].gunPart,
							v.gunTagEnd or attachmentsConfig[i].gunTagEnd
						)
						fp.attachment.directory = originalItem.directory
						if fp.attachment.script then
							self.modules[i] = requireUni:load(vDir(fp.attachment.script, originalItem), fp.attachment.class or "module"):create(fp.attachment, i)
							if self.modules[i].special then
								self.special = i
							end
						end
					end
				end
			end
		end
	end
end

function attachment:debug(dt)

end

function attachment:update(dt)
	self:debug(dt)
	for i,v in pairs(self.modules) do
		if self.modules[i].update then
			self.modules[i]:update(dt)
		end
	end
end

function attachment:uninit()
	for i,v in pairs(self.modules) do
		if self.modules[i].uninit then
			self.modules[i]:uninit(dt)
		end
	end
end

addClass("attachment", 25)
