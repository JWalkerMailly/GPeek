
local EXT = {}

EXT.Icon = "icon16/image.png"

local function removeFirstFolder(path)
	return path:match("^[^/]+/(.+)$") || path
end

EXT.Initialize = function(browser, name, path, dir)

	if (IsValid(EXT.Container)) then return end

	EXT.Container = vgui.Create("DPanel")

	EXT.FileName = vgui.Create("DLabel", EXT.Container)
	EXT.FileName:Dock(TOP)
	EXT.FileName:DockMargin(0, 0, 0, 5)

	EXT.Image = vgui.Create("DImageButton", EXT.Container)
	EXT.Image:Dock(FILL)

	EXT.Image.PerformLayout = function(this, w, h)

		local mat = this.Material
		if (mat == nil || mat == NULL) then return end

		local tw, th = mat:Width(), mat:Height()
		if (tw == 0 || th == 0) then return end

		local scale = math.min(w / tw, h / th)
		local fw = math.min(tw, tw * scale)
		local fh = math.min(th, th * scale)

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

	browser:SetContent(EXT.Container)

	return EXT.Image
end

EXT.Browse = function(browser, name, path, dir)

	EXT.FileName:SetText("/" .. dir .. "/" .. name)

	local image = removeFirstFolder(dir .. "/" .. name)

	EXT.Image.Material = Material(image)
	EXT.Image:SetImage(image)
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT