local oldInit = init or function () end
local oldUpdate = update or function() localAnimator.clearDrawables() end

-- this hooks into the player deployment

function init()

    x, e = pcall(oldInit)
    if not x then
        sb.logError(e)
        oldInit = function() end
    end
end

function update(...)
    x, e = pcall(oldUpdate, ...)
    if not x then
        sb.logError(e)
        oldUpdate = function() localAnimator.clearDrawables() end
    end

    local altHand = player.getProperty("unsungguns_altHand", {})
    local primaryHand = player.getProperty("unsungguns_primaryHand", {})

    for i,v in pairs(altHand) do
        if v.func and localAnimator[v.func] then
            localAnimator[v.func](table.unpack(v.args))
        end
    end

    for i,v in pairs(primaryHand) do
        if v.func and localAnimator[v.func] then
            localAnimator[v.func](table.unpack(v.args))
        end
    end

    player.setProperty("unsungguns_altHand", {})
    player.setProperty("unsungguns_primaryHand", {})
end