--[[
DPanel (EXT.Container)
└── DCodeViewer (EXT.CodeViewer)
     - Displays file contents
     - Syntax highlighting via lang (default: glua)
]]

local EXT = {}

EXT.Icon = "icon16/script_code.png"

local function removeFirstFolder(path)
	return path:match("^[^/]+/(.+)$") || path
end

EXT.Initialize = function()
	EXT.CodeViewer = vgui.Create("DCodeViewer", EXT.Container)
	EXT.CodeViewer:Dock(FILL)
end

EXT.Browse = function(filePath, code, lang)

	EXT.Code = code || file.Read(removeFirstFolder(filePath), "LUA")
	if (EXT.Code == nil || EXT.Code == "") then
		EXT.Code = language.GetPhrase("gpeek.extensions.lua.empty")
		lang = "plaintext"
	end

	EXT.CodeViewer:SetContent(EXT.Code, lang || "glua")
end

EXT.RightClick = function(menu, filePath)

	menu:AddOption("#gpeek.extensions.lua.copy", function()
		SetClipboardText(EXT.Code || "")
	end):SetIcon("icon16/page_paste.png")
end

EXT.Invalidate = function()
	-- override
end

return EXT