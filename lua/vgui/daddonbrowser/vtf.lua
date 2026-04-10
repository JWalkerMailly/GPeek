
local EXT = {}

EXT.Icon = "icon16/image.png"

EXT.Initialize = function(browser, name, path, dir)
	-- override
end

EXT.Browse = function(browser, name, path, dir)
	-- override
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT