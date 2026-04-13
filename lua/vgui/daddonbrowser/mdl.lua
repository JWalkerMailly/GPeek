--[[
DPanel (EXT.Container)
├── DScrollPanel (EXT.Scroll)
│     └── DSizeToContents (EXT.Controls)
│           ├── DComboBox (Animation)
│           │
│           ├── DNumSlider (Skin)
│           │
│           └── DNumSlider (Bodygroups)
│
└── DPanel (container)
      ├── Paint:
      │     - Background color toggle (EXT.ColorPalette)
      │
      └── DAdjustableModelPanel (EXT.ModelViewer)
            ├── Displays model from filePath
            │
            ├── Camera configuration
            │
            └── DColorPalette (EXT.ColorPalette)
]]

local EXT = {}

EXT.Icon = "icon16/brick.png"

local function sendAnimation(model, anim, speed)

	if (!IsValid(model)) then return; end
	model:ResetSequence(model:LookupSequence(anim));
	model:ResetSequenceInfo();
	model:SetCycle(0);
	model:SetPlaybackRate(math.Clamp(tonumber(speed || 1), 0.05, 3.05));
end

local function buildControls(model, modelInfo)

	EXT.Controls:Clear()

	local height = 35

	local sequences = model:GetSequenceList()
	local animations = vgui.Create("DComboBox", EXT.Controls)
	animations:Dock(TOP)
	animations:DockMargin(0, 0, 0, 5)
	animations:SetValue("#gpeek.extensions.mdl.animations.placeholder")

	for k,v in pairs(sequences) do
		animations:AddChoice(v)
	end

	animations.OnSelect = function(this, id, val, data)
		sendAnimation(model, val)
	end

	if (modelInfo.SkinCount > 1) then

		local skins = vgui.Create("DNumSlider", EXT.Controls)
		skins:SetText("#gpeek.extensions.mdl.skin")
		skins:SetMinMax(0, modelInfo.SkinCount - 1)
		skins:SetValue(0)
		skins:SetDecimals(0)
		skins:SetDark(true)
		skins:SizeToContents()
		skins:Dock(TOP)
		skins.OnValueChanged = function(this, val)
			model:SetSkin(math.Round(val))
		end

		height = height + 30
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

		height = height + 30
	end

	EXT.Controls:InvalidateLayout(true)
	EXT.Scroll:SetTall(math.Clamp(height, 0, 125))
	EXT.Scroll:PerformLayout()
end

local gpeek_background_r = GetConVar("gpeek_background_r")
local gpeek_background_g = GetConVar("gpeek_background_g")
local gpeek_background_b = GetConVar("gpeek_background_b")

EXT.Initialize = function()

	EXT.Scroll = vgui.Create("DScrollPanel", EXT.Container)
	EXT.Scroll:Dock(TOP)

	EXT.Controls = vgui.Create("DSizeToContents", EXT.Scroll)
	EXT.Controls:Dock(TOP)
	EXT.Controls:DockMargin(5, 0, 5, 0)
	EXT.Controls:SetSizeX(false)

	local container = vgui.Create("DPanel", EXT.Container)
	container:Dock(FILL)
	container.Paint = function(this)
		surface.SetDrawColor(gpeek_background_r:GetInt(), gpeek_background_g:GetInt(), gpeek_background_b:GetInt())
		this:DrawFilledRect()
	end

	EXT.ModelViewer = vgui.Create("DAdjustableModelPanel", container)
	EXT.ModelViewer:Dock(FILL)
	EXT.ModelViewer.Paint = function(this)
		this.BaseClass.Paint(this)
		if (IsValid(this:GetEntity())) then this:GetEntity():FrameAdvance() end
	end
	EXT.ModelViewer.LayoutEntity = function()
		-- override
	end

	EXT.ColorPalette = vgui.Create("DColorPalette", EXT.ModelViewer)
	EXT.ColorPalette:Dock(TOP)
	EXT.ColorPalette:DockMargin(5, 5, 0, 0)
	EXT.ColorPalette:SetConVarR("gpeek_background_r")
	EXT.ColorPalette:SetConVarG("gpeek_background_g")
	EXT.ColorPalette:SetConVarB("gpeek_background_b")
end

EXT.Browse = function(filePath)

	EXT.ModelViewer:SetModel(filePath)

	local model  = EXT.ModelViewer:GetEntity()
	local pos    = model:GetPos()
	local camera = PositionSpawnIcon(model, pos, true)

	if (camera) then
		EXT.ModelViewer:SetCamPos(camera.origin)
		EXT.ModelViewer:SetFOV(camera.fov)
		EXT.ModelViewer:SetLookAng(camera.angles)
	end

	local modelInfo = util.GetModelInfo(filePath)
	if (!modelInfo) then return end

	EXT.Scroll:SetTall(0)
	buildControls(model, modelInfo)
end

EXT.RightClick = function(menu, filePath)

	menu:AddOption("#spawnmenu.menu.spawn_with_toolgun", function()
		RunConsoleCommand("gmod_tool", "creator")
		RunConsoleCommand("creator_type", "4")
		RunConsoleCommand("creator_name", filePath)
	end):SetIcon("icon16/brick_add.png")
end

EXT.Invalidate = function()
	-- override
end

return EXT