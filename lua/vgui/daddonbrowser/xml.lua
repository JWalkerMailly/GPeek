
-- passthrough
local lua = include("lua.lua")

local EXT = {}

EXT.Icon = "icon16/script.png"

EXT.Initialize = function(browser, name, path, dir)
	lua.Initialize(browser, name, path, dir)
end

EXT.Browse = function(browser, name, path, dir)
	local code = file.Read(dir .. "/" .. name, "GAME")
	lua.Browse(browser, name, path, dir, code, "xml")
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	lua.Invalidate()
end

return EXT