
local wav = include("wav.lua")

local EXT = {}

EXT.Icon = "icon16/sound.png"

EXT.Initialize = function(browser, name, path, dir)
	wav.Initialize(browser, name, path, dir)
end

EXT.Browse = function(browser, name, path, dir)
	wav.Browse(browser, name, path, dir)
end

EXT.RightClick = function(menu, name, path, dir)
	wav.RightClick(menu, name, path, dir)
end

EXT.Invalidate = function()
	wav.Invalidate()
end

return EXT