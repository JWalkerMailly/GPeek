
-- passthrough
local vmt = include("vmt.lua")

local EXT = {}

EXT.Icon = "icon16/image.png"

EXT.Initialize = function(browser, name, path, dir)
	vmt.Initialize(browser, name, path, dir)
end

EXT.Browse = function(browser, name, path, dir)
	vmt.Browse(browser, name, path, dir)
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	vmt.Invalidate()
end

return EXT