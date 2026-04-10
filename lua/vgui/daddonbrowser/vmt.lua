
local EXT = {}

EXT.Icon = "icon16/script_palette.png"

local function removeFirstFolder(path)
	return path:match("^[^/]+/(.+)$") || path
end

EXT.Initialize = function(browser, name, path, dir)

	if (IsValid(EXT.Container)) then return end

	EXT.Container = vgui.Create("DPanel")

	EXT.FileName = vgui.Create("DLabel", EXT.Container)
	EXT.FileName:Dock(TOP)
	EXT.FileName:DockMargin(0, 0, 0, 5)

	EXT.Tabs = vgui.Create("DPropertySheet", EXT.Container)
	EXT.Tabs:Dock(FILL)

	local textureTab = vgui.Create("DPanel")
	EXT.Tabs:AddSheet("Texture", textureTab, "icon16/image.png")

	local txtScale = vgui.Create("DNumSlider", textureTab)
	txtScale:SetText("Scale")
	txtScale:SetMinMax(1, 20)
	txtScale:SetDecimals(0)
	txtScale:SetValue(1)
	txtScale:SetDark(true)
	txtScale:SizeToContents()
	txtScale:Dock(TOP)
	txtScale:DockMargin(0, 0, 0, 10)
	txtScale.OnValueChanged = function(this, val)
		EXT.Image.Scale = val
	end

	EXT.Image = vgui.Create("DImageButton", textureTab)
	EXT.Image:Dock(FILL)
	EXT.Image.Scale = 1

	EXT.Image.PerformLayout = function(this, w, h)

		local mat = this.Material
		if (mat == nil || mat == NULL) then return end

		local tw, th = mat:Width(), mat:Height()
		if (tw == 0 || th == 0) then return end

		local scale = math.min(w / tw, h / th)
		local fw = math.min(tw, tw * scale) * this.Scale
		local fh = math.min(th, th * scale) * this.Scale

		this:SetSize(fw, fh)

		for k,v in pairs(this:GetChildren()) do
			v:SetSize(fw, fh)
		end
	end

	EXT.Image.DoRightClick = function(this)

		local menu = DermaMenu()

		menu:AddOption("Copy to clipboard", function()
			SetClipboardText(this:GetImage())
		end):SetIcon("icon16/page_copy.png")

		menu:Open()
	end

	local materialTab = vgui.Create("DPanel")
	EXT.Tabs:AddSheet("Material", materialTab, "icon16/palette.png")

	EXT.CodeViewer = vgui.Create("DCodeViewer", materialTab)
	EXT.CodeViewer:Dock(FILL)

	browser:SetContent(EXT.Container)

	return EXT.Image
end

EXT.Browse = function(browser, name, path, dir, hideMat)

	EXT.FileName:SetText("/" .. dir .. "/" .. name)

	local image = removeFirstFolder(dir .. "/" .. name)

	EXT.Image.Material = Material(image)
	EXT.Image:SetImage(image)

	if (hideMat) then
		EXT.Tabs:SetActiveTab(EXT.Tabs:GetItems()[1].Tab)
		EXT.Tabs:GetItems()[2].Tab:SetVisible(false)
	else
		EXT.Tabs:GetItems()[2].Tab:SetVisible(true)
	end

	local vmt = file.Read(dir .. "/" .. name, "GAME")
	EXT.CodeViewer:SetContent(vmt, "json")
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT