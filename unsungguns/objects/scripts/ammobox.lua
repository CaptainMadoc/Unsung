remaining = 10
tier = ""

function init()
    remaining = config.getParameter("ammoRemaining", 10)
    tier = config.getParameter("tier", 10)

    object.setInteractive(true)

    check()
end

function check()
    if remaining <= 0 then
        object.smash(true)
    end
end

function save()
    check()
    object.setConfigParameter("ammoRemaining", remaining)
    object.setConfigParameter("description", "Remaining dispenses: ^green;"..remaining)
end

function procdir(str,dir)
    if str:sub(1,1) == "/" then return str end
    return dir..str
end

function getAmmoPool(hands)
    local pool = {}
    for i,v in pairs(hands) do
        local a = root.itemConfig(v)
        local Item = sb.jsonMerge(a.config, a.parameters)

        if Item.compatibleAmmo then
            local tierlist

            if type(Item.compatibleAmmo) == "string" then
                tierlist = root.assetJson(procdir(Item.compatibleAmmo, Item.directory or a.directory), jarray())
            end

            if tierlist and tierlist[tier] and tierlist[tier].list then
                local list = tierlist[tier].list
                for i=1,#list do
                    pool[#pool + 1] = list[i]
                end
            end
        end
    end
    return pool
end

--{1: {source: {1: -2.49744, 2: 2.5}, sourceId: -65536} }
function onInteraction(entity)
    hands = {world.entityHandItem(entity.sourceId, "primary"), world.entityHandItem(entity.sourceId, "alt")}
    playerpos = world.entityPosition(entity.sourceId)

    local candispense = getAmmoPool(hands)

    if #candispense == 0 then
       return 
    end
    
    local rand = candispense[math.random(1,#candispense)]
    world.spawnItem({name = rand, count = 60}, playerpos)

    remaining = remaining - 1
    save()
end