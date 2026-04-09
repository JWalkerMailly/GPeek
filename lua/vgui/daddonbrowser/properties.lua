
-- passthrough
local lua = include("lua.lua")

local EXT = {}

EXT.Icon = "icon16/script_key.png"

EXT.Initialize = function(browser, name, path, dir)
	lua.Initialize(browser, name, path, dir)
end

EXT.Browse = function(browser, name, path, dir)
	local code = file.Read(dir .. "/" .. name, "GAME")
	lua.Browse(browser, name, path, dir, code, "properties")
end

EXT.RightClick = function(menu, name, path, dir)
	lua.RightClick(menu, name, path, dir)
end

EXT.Invalidate = function()
	lua.Invalidate()
end

return EXT