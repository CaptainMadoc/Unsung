include "activeItem"
include "updateable"

localAnimatorApplier = {}
localAnimatorApplier.set = {}

function localAnimatorApplier:update()
    local hand = activeItem.hand()
    player.setProperty("unsungguns_"..hand.."Hand", self.set)
    self.set = {}
end

function localAnimatorApplier:add(func, ...)
    self.set[#self.set + 1] = {func = func, args = {...}}
end

updateable:add("localAnimatorApplier")

localAnimator = {}
setmetatable(localAnimator, 
    {
        __index = function(self, key)
            return function(...)
                localAnimatorApplier:add(key, ...)
            end
        end
    }
)