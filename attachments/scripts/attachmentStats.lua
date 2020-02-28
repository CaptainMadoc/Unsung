include "directory"
include "vec2"
include "animator"
include "stats"

module = {}
module.storage = {}
module.config = {}
module.transform = {}
module.directory = "/"
module.partName = ""
module.anchorPart = ""
module.name = {}

function module:init()
	animator.setPartTag(self.partName, "partImage", directory(self.config.image, self.directory) or "/assetmissing.png")
    self:updateTransform()
    self:applyStats()
end

function module:update(dt)
	self:updateTransform()
end

function module:uninit()

end

function module:applyStats()
    for i,v in pairs(self.config.statsRatio or {}) do
        local currentStat = stats:get(i)
        if type(currentStat) == "number" then
            currentStat = currentStat * v
            stats:set(i, currentStat)
        end
    end
end

function module:updateTransform()
	animator.resetTransformationGroup(self.transform)

	--reverse scale applied from parent aka "gun"
	local a = animator.transformPoint({0,0},self.partName)
	local b = animator.transformPoint({1,1},self.partName)
	local c = animator.transformPoint({0,1},self.partName)
	
	if a ~= vec2(0) then
		local cs = vec2(1,1) / (b - a):rotate((c - a):angle())
	
		animator.scaleTransformationGroup(self.transform, cs, animator.partProperty(self.partName, "offset"))
	end
	--
	animator.translateTransformationGroup(self.transform, self.config.offset or vec2(0,0))
	animator.scaleTransformationGroup(self.transform, self.config.scale or 1, animator.partProperty(self.partName, "offset"))
end