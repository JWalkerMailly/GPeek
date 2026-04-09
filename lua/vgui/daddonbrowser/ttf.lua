
require("ttfname")

local EXT = {}
local FONTS = {}

EXT.Icon = "icon16/font.png"

local preview = [[
ABCDEFGHIJKLM
NOPQRSTUVWXYZ
abcdefghijklm
nopqrstuvwxyz
0123456789
!@#$%^&*()[]{}|
_+-=;:'",.<>/?~
]]

local fontRT  = GetRenderTarget("GPeekFontPreview", 1024, 512)
local fontMat = CreateMaterial("GPeekFontPreview", "UnlitGeneric", {
	["$basetexture"] = "GPeekFontPreview",
	["$translucent"] = 1,
	["$vertexcolor"] = 1
})

local function fontDrawPass(context)

	if (context.DrawPass) then

		render.PushRenderTarget(fontRT)
		cam.Start2D()
		render.Clear(0, 0, 0, 0, true, true)

		if (context.Font) then

			local font = "GPeek " .. context.Font

			EXT.FontEntry:SetFont(font)
			EXT.FontEntry:SetTall(draw.GetFontHeight(font))
			EXT.FontEntry:ApplySchemeSettings()
			EXT.FontEntry:InvalidateLayout(true)
			draw.DrawText(preview, font)
		end

		cam.End2D()
		render.PopRenderTarget()

		EXT.FontEntry:SetVisible(context.Font != nil)
		context.DrawPass = false
	end

	return fontMat
end

EXT.Initialize = function(browser, name, path, dir)

	if (IsValid(EXT.Container)) then return end

	EXT.Container = vgui.Create("DPanel")

	EXT.FileName = vgui.Create("DLabel", EXT.Container)
	EXT.FileName:Dock(TOP)
	EXT.FileName:DockMargin(0, 0, 0, 5)

	local controls = vgui.Create("DSizeToContents", EXT.Container)
	controls:SetSizeX(false)
	controls:Dock(TOP)
	controls:DockMargin(0, 0, 0, 5)

	EXT.FontName = vgui.Create("DLabel", controls)
	EXT.FontName:Dock(TOP)
	EXT.FontName:DockMargin(0, 0, 0, 5)

	local fontScale = vgui.Create("DNumSlider", controls)
	fontScale:SetText("Font Scale")
	fontScale:SetMinMax(0.4, 1.6)
	fontScale:SetValue(1)
	fontScale:SetDark(true)
	fontScale:SizeToContents()
	fontScale:Dock(TOP)
	fontScale:DockMargin(0, 0, 0, 10)
	fontScale.OnValueChanged = function(this, val)
		EXT.Preview.FontScale = math.Clamp(val, 0.4, 1.6)
	end

	EXT.FontEntry = vgui.Create("DTextEntry", controls)
	EXT.FontEntry:Dock(TOP)
	EXT.FontEntry:SetText("The quick brown fox jumps over the lazy dog.")

	EXT.Preview = vgui.Create("DPanel", EXT.Container)
	EXT.Preview:Dock(FILL)
	EXT.Preview.FontScale = 1

	browser:SetContent(EXT.Container)

	return EXT.Preview
end

EXT.Browse = function(browser, name, path, dir)

	EXT.FileName:SetText("/" .. dir .. "/" .. name)

	local font = ttfname.readFromFile(dir .. "/" .. name)
	if (font && !FONTS[font]) then

		surface.CreateFont("GPeek " .. font, {
			font = font,
			size = 48
		})

		FONTS[font] = true
	end

	EXT.FontName:SetText(font || "Could not load font.")
	EXT.Preview.Font = font
	EXT.Preview.DrawPass = true
	EXT.Preview.Paint = function(this)
		surface.SetMaterial(fontDrawPass(this))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, 1024 * this.FontScale, 512 * this.FontScale)
	end
end

EXT.RightClick = function(menu, name, path, dir)

	if (!EXT.Preview || !EXT.Preview.Font) then return end

	menu:AddOption("Copy font name", function()
		SetClipboardText(EXT.Preview.Font || "")
	end):SetIcon("icon16/font.png")
end

EXT.Invalidate = function()
	-- override
end

return EXT