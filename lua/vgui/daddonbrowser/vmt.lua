--[[
DPanel (EXT.Container)
└── DPropertySheet (EXT.Tabs)
     ├── Texture Tab (DPanel)
     │     ├── DNumSlider (Scale)
     │     │
     │     ├── DPanel (imageContainer)
     │     │     ├── Paint:
     │     │     │     - Background color toggle (white/black via EXT.Background)
     │     │     │
     │     │     └── DImageButton (EXT.Image)
     │     │           - Displays material texture
     │     │
     │     └── DCheckBoxLabel (EXT.Background)
     │           - Toggles background inversion
     │
     └── Material Tab (DPanel)
           └── DCodeViewer (EXT.CodeViewer)
                 - Displays VMT/material file contents
]]

local EXT = {}

EXT.Icon = "icon16/script_palette.png"

local function removeFirstFolder(path)
	return path:match("^[^/]+/(.+)$") || path
end

EXT.Initialize = function()

	EXT.Tabs = vgui.Create("DPropertySheet", EXT.Container)
	EXT.Tabs:Dock(FILL)

	local textureTab = vgui.Create("DPanel")
	EXT.Tabs:AddSheet("#gpeek.extensions.vmt.texture", textureTab, "icon16/image.png")

	local txtScale = vgui.Create("DNumSlider", textureTab)
	txtScale:SetText("#gpeek.extensions.vmt.scale")
	txtScale:SetMinMax(1, 20)
	txtScale:SetDecimals(0)
	txtScale:SetValue(1)
	txtScale:SetDark(true)
	txtScale:SizeToContents()
	txtScale:Dock(TOP)
	txtScale:DockMargin(5, 0, 0, 5)
	txtScale.OnValueChanged = function(this, val)
		EXT.Image.Scale = val
	end

	local imageContainer = vgui.Create("DPanel", textureTab)
	imageContainer:Dock(FILL)
	imageContainer.Paint = function(this)
		surface.SetDrawColor(EXT.Background:GetChecked() && color_white || color_black)
		this:DrawFilledRect()
	end

	EXT.Image = vgui.Create("DImageButton", imageContainer)
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
		this:Center()

		for k,v in pairs(this:GetChildren()) do
			v:SetSize(fw, fh)
		end
	end

	EXT.Image.DoRightClick = function(this)

		local menu = DermaMenu()

		menu:AddOption("#spawnmenu.menu.copy", function()
			SetClipboardText(this:GetImage())
		end):SetIcon("icon16/page_copy.png")

		menu:Open()
	end

	EXT.Background = vgui.Create("DCheckBoxLabel", imageContainer)
	EXT.Background:Dock(BOTTOM)
	EXT.Background:DockMargin(5, 0, 0, 5)
	EXT.Background:SetText("#gpeek.extensions.vmt.invert")
	EXT.Background:SetValue(false)
	EXT.Background:SetDark(false)
	EXT.Background.OnChange = function(this, val)
		this:SetDark(val)
		this:InvalidateChildren()
	end

	local materialTab = vgui.Create("DPanel")
	EXT.Tabs:AddSheet("#gpeek.extensions.vmt.material", materialTab, "icon16/palette.png")

	EXT.CodeViewer = vgui.Create("DCodeViewer", materialTab)
	EXT.CodeViewer:Dock(FILL)
end

EXT.Browse = function(filePath, hideMat)

	local image = removeFirstFolder(filePath)

	EXT.Image.Material = Material(image)
	EXT.Image:SetImage("gpeek_fouc.png")
	timer.Create("gpeek_fouc_fix", 0, 1, function()
		if (!IsValid(EXT.Image)) then return end
		EXT.Image:SetImage(image)
	end)

	if (hideMat) then
		EXT.Tabs:SetActiveTab(EXT.Tabs:GetItems()[1].Tab)
		EXT.Tabs:GetItems()[2].Tab:SetVisible(false)
	else
		EXT.Tabs:GetItems()[2].Tab:SetVisible(true)
		EXT.Tabs:InvalidateChildren()
	end

	local vmt = file.Read(filePath, "GAME")
	EXT.CodeViewer:SetContent(vmt, "json")
end

EXT.RightClick = function(menu, filePath)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT