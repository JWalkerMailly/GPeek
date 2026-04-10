
local EXT = {}

EXT.Icon = "icon16/fire.png"

EXT.Initialize = function()

	if (!PEPlus_ProcessedPCFs) then return end

	EXT.Scroll = vgui.Create("DScrollPanel", EXT.Container)
	EXT.Scroll:Dock(FILL)

	EXT.Layout = vgui.Create("DIconLayout", EXT.Scroll)
	EXT.Layout:Dock(FILL)
	EXT.Layout:SetSpaceX(2.5)
	EXT.Layout:SetSpaceY(2.5)
end

EXT.Browse = function(filePath)

	if (!PEPlus_ProcessedPCFs) then

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