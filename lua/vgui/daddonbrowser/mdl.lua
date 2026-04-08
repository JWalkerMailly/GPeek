
local EXT = {}

EXT.Icon = "icon16/brick.png"

EXT.Initialize = function(browser, name, path, dir)

	if (IsValid(EXT.Container)) then return end

	EXT.Container = vgui.Create("DPanel")

	EXT.FileName = vgui.Create("DLabel", EXT.Container)
	EXT.FileName:Dock(TOP)
	EXT.FileName:DockMargin(0, 0, 0, 5)

	local scroll = vgui.Create("DScrollPanel", EXT.Container)
	scroll:Dock(TOP)
	scroll:SetTall(95)

	EXT.Controls = vgui.Create("DSizeToContents", scroll)
	EXT.Controls:SetSizeX(false)
	EXT.Controls:Dock(TOP)

	EXT.ModelViewer = vgui.Create("DAdjustableModelPanel", EXT.Container)
	EXT.ModelViewer:Dock(FILL)

	browser:SetContent(EXT.Container)

	return EXT.ModelViewer
end

local function BuildControls(model, modelInfo)

	EXT.Controls:Clear()

	if (modelInfo.SkinCount > 1) then

		local skins = vgui.Create("DNumSlider", EXT.Controls)
		skins:SetText("Skin")
		skins:SetMinMax(0, modelInfo.SkinCount - 1)
		skins:SetValue(0)
		skins:SetDecimals(0)
		skins:SetDark(true)
		skins:SizeToContents()
		skins:Dock(TOP)
		skins.OnValueChanged = function(this, val)
			model:SetSkin(math.Round(val))
		end
	end

	for i = 0, model:GetNumBodyGroups() - 1 do

		local groupCount = model:GetBodygroupCount(i)
		if (groupCount <= 1) then continue end

		local bodygroups = vgui.Create("DNumSlider", EXT.Controls)
		bodygroups:SetText(model:GetBodygroupName(i))
		bodygroups:SetMinMax(0, groupCount - 1)
		bodygroups:SetValue(0)
		bodygroups:SetDecimals(0)
		bodygroups:SetDark(true)
		bodygroups:SizeToContents()
		bodygroups:Dock(TOP)
		bodygroups.OnValueChanged = function(this, val)
			model:SetBodygroup(i, math.Round(val))
		end
	end

	EXT.Controls:InvalidateLayout(true)
end

EXT.Browse = function(browser, name, path, dir)

	EXT.FileName:SetText("/" .. dir .. "/" .. name)

	EXT.ModelViewer:SetModel(dir .. "/" .. name)
	local model = EXT.ModelViewer:GetEntity()
	local pos = model:GetPos()
	local camera = PositionSpawnIcon(model, pos, true)
	if (camera) then
		EXT.ModelViewer:SetCamPos(camera.origin)
		EXT.ModelViewer:SetFOV(camera.fov)
		EXT.ModelViewer:SetLookAng(camera.angles)
	end

	local modelInfo = util.GetModelInfo(dir .. "/" .. name)
	if (!modelInfo) then return end

	BuildControls(model, modelInfo)
end

EXT.RightClick = function(menu, name, path, dir)

	menu:AddOption("#spawnmenu.menu.spawn_with_toolgun", function()
		RunConsoleCommand("gmod_tool", "creator")
		RunConsoleCommand("creator_type", "4")
		RunConsoleCommand("creator_name", dir .. "/" .. name)
	end):SetIcon("icon16/brick_add.png")
end

EXT.Invalidate = function()
	-- override
end

return EXT