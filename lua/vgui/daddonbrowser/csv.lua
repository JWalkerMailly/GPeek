
local EXT = {}

EXT.Base = "lua" -- resolved at runtime
EXT.Icon = "icon16/page_white_excel.png"

EXT.Initialize = function()
	EXT.Base.Initialize()
end

EXT.Browse = function(filePath)
	local code = file.Read(filePath, "GAME")
	EXT.Base.Browse(filePath, code, "csv")
end

EXT.RightClick = function(menu, filePath)
	EXT.Base.RightClick(menu, filePath)
end

EXT.Invalidate = function()
	EXT.Base.Invalidate()
end

return EXT