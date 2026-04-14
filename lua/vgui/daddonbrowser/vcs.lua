
local EXT = {}

EXT.BaseClass = "error"
EXT.Icon = "icon16/script_code_red.png"

EXT.Initialize = function(container)
	EXT.Base.Initialize(container)
end

EXT.Browse = function(filePath)
	-- override
end

EXT.RightClick = function(menu, filePath)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT