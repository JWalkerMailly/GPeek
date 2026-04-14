
local EXT = {}

EXT.BaseClass = "vmt" -- resolved at runtime
EXT.Icon = "icon16/image.png"

EXT.Initialize = function()
	EXT.Base.Initialize()
end

EXT.Browse = function(filePath)
	EXT.Base.Browse(filePath, true)
end

EXT.RightClick = function(menu, filePath)
	EXT.Base.RightClick(menu, filePath)
end

EXT.Invalidate = function()
	EXT.Base.Invalidate()
end

return EXT