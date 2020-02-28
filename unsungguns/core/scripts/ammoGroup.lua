include "directory"

ammoGroup = {}

--returns compatibleAmmo types
function ammoGroup:types()
	local compat = config.getParameter("ammoType", jarray())
	local itemList = {}
	
	if type(compat) == "string" then
		compat = root.assetJson(directory(compat, "/ammo/group/", ".ammogroup"))
	end

	for i,v in pairs(compat) do
		if v.list then
			for i2 = 1,#v.list do
				itemList[#itemList + 1] = v.list[i2]
			end
		end
	end
	
	--error
	if #itemList == 0 then
		return {"jstestammo"}
	end

	return itemList
end

--return true if player has compatible ammo
function ammoGroup:available()
	for i,v in ipairs(self:types()) do
		local finditem = {name = v, count = 1}
		if type(v) == "table" then 
			finditem = v
		end
		if player.hasItem(finditem, true) then
			return true
		end
	end
	return false
end

--returns a array of ammos with item data
function ammoGroup:get(amount)
	local gotten = {}
	if not amount then 
		amount = 1
	end

	for i,v in ipairs(self:types()) do
		if amount > 0 then

			local finditem = {name = v, count = 1}
			if type(v) == "table" then
				finditem = v
				finditem.count = 1
			end
			--player has ammo
			if player.hasItem(finditem) then
				finditem.count = amount

				--take the found item
				local con = player.consumeItem(finditem, true, true)
				if con then
					table.insert(gotten, con)
					--decrease the amount found
					amount = amount - con.count
				end

			end
		else
			break
		end
	end

	return gotten
end