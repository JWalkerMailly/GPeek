
local EXT = {}

EXT.Icon = "icon16/fire.png"

local PEPlusSupport = nil

local function detectPEPlusSupport()

	if PEPlusSupport != nil then return PEPlusSupport end

	local ent = Entity(0)
	local fx = CreateParticleSystem(ent, "gpeek_particle_test", PATTACH_ABSORIGIN)

	if (!fx) then return end

	local set = type(fx.SetShouldSimulate) == "function"
	local get = type(fx.GetShouldSimulate) == "function"
	PEPlusSupport = set && get

	fx:StopEmission(false, true)
end

EXT.Initialize = function()

	if (!PEPlus_ProcessedPCFs) then return end

	detectPEPlusSupport()

	EXT.Scroll = vgui.Create("DScrollPanel", EXT.Container)
	EXT.Scroll:Dock(FILL)

	EXT.Layout = vgui.Create("DIconLayout", EXT.Scroll)
	EXT.Layout:Dock(FILL)
	EXT.Layout:SetSpaceX(2.5)
	EXT.Layout:SetSpaceY(2.5)
end

EXT.Browse = function(filePath)

	if (!PEPlus_ProcessedPCFs) then

		EXT.Container:Clear()

		local msg = vgui.Create("DLabel", EXT.Container)
		msg:Dock(TOP)
		msg:DockMargin(5, 0, 5, 5)
		msg:SetText("You need 'Particle Effects+' (3684885115) to view this file.")
		msg:SetDark(true)

		local workshop = vgui.Create("DButton", EXT.Container)
		workshop:Dock(TOP)
		workshop:SetText("See in Workshop")
		workshop.DoClick = function()
			steamworks.ViewFile("3684885115")
		end

		return
	end

	if (!PEPlusSupport) then

		EXT.Container:Clear()

		local msg = vgui.Create("DLabel", EXT.Container)
		msg:Dock(TOP)
		msg:DockMargin(5, 0, 5, 5)
		msg:SetText("'Particle Effects+' (3684885115) is currently not supported for this branch: " .. BRANCH .. ".")
		msg:SetDark(true)

		return
	end

	EXT.Layout:Clear()

	if (!PEPlus_ProcessedPCFs[filePath]) then return end
	for k,v in pairs(PEPlus_ProcessedPCFs[filePath]) do
		spawnmenu.CreateContentIcon("peplus", EXT.Layout, { pcf = filePath, name = k })
	end
end

EXT.RightClick = function(menu, filePath)
	-- override
end

EXT.Invalidate = function()
	-- override
end

return EXT