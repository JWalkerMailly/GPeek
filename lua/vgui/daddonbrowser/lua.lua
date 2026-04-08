
local EXT = {}

EXT.Icon = "icon16/script_code.png"

local function removeFirstFolder(path)
	return path:match("^[^/]+/(.+)$") || path
end

EXT.Initialize = function(browser, name, path, dir)

	if (IsValid(EXT.Container)) then return end

	EXT.Container = vgui.Create("DPanel")

	EXT.FileName = vgui.Create("DLabel", EXT.Container)
	EXT.FileName:Dock(TOP)
	EXT.FileName:DockMargin(0, 0, 0, 5)

	EXT.CodeViewer = vgui.Create("DCodeViewer", EXT.Container)
	EXT.CodeViewer:Dock(FILL)

	browser:SetContent(EXT.Container, EXT)

	return EXT.CodeViewer
end

EXT.Browse = function(browser, name, path, dir, code, lang)

	EXT.FileName:SetText("/" .. dir .. "/" .. name)

	code = code || file.Read(removeFirstFolder(dir .. "/" .. name), "LUA")
	if (code == "") then
		code = "This file is empty"
		lang = "plaintext"
	end

	EXT.CodeViewer:SetContent(code, lang || "glua")
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT