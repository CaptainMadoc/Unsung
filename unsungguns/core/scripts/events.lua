events = {}
events.binded = {}

function events:fire(name, ...)
    if self.binded[name] then
        for uuid, func in pairs(self.binded[name]) do
            func(...)
        end
    end
end

function events:add(name, func)
    if not self.binded[name] then
        self.binded[name] = {}
    end

    local uuid = sb.makeUuid()
    while self.binded[name][uuid] do
        uuid = sb.makeUuid()
    end

    self.binded[name][uuid] = func

    return uuid
end

function events:remove(name, uuid)
    if self.binded[name] then
        self.binded[name][uuid] = nil
    end
end