function whole(aitem)
	local a = root.itemConfig(aitem)
	return sb.jsonMerge(a.config, a.parameters)
end

function apply(input)
	local attachType = config.getParameter("attachmentType")
	local originalItem = whole(input)

	--check if the item has a attachment table
	if not input.parameters.attachments and originalItem.attachments then
		input.parameters.attachments = {}
	elseif not originalItem.attachments then -- fail
		return
	end

	if originalItem.attachments and originalItem.attachments[attachType] then
		if not input.parameters.attachments then
			input.parameters.attachments = {}
		end

		if not input.parameters.attachments[attachType] then
			input.parameters.attachments[attachType] = {}
		end

		-- has a item in the slot
		if input.parameters.attachments[attachType].item then
			if not input.parameters.giveback then
				input.parameters.giveback = {}
			end
			input.parameters.giveback[#input.parameters.giveback + 1] = input.parameters.attachments[attachType].item
		end

		input.parameters.attachments[attachType].item = item.descriptor()
	end
	return input
end