--[[
DPanel (EXT.Container)
├── DLabel (warning message) [if PEPlus_ProcessedPCFs missing]
│
├── DButton (See in Workshop) [if PEPlus_ProcessedPCFs missing]
│     - Opens Particle Effects+ workshop page
│
└── DScrollPanel (EXT.Scroll) [if PEPlus_ProcessedPCFs exists]
      └── DIconLayout (EXT.Layout)
            - Grid layout for particle entries
]]

local EXT = {}

EXT.Icon = "icon16/fire.png"

EXT.Initialize = function()

	if (!PEPlus_ProcessedPCFs) then

		local msg = vgui.Create("DLabel", EXT.Container)
		msg:Dock(TOP)
		msg:DockMargin(5, 0, 5, 5)
		msg:SetText("#gpeek.extensions.pcf.message")
		msg:SetDark(true)

		local workshop = vgui.Create("DButton", EXT.Container)
		workshop:Dock(TOP)
		workshop:SetText("#gpeek.extensions.pcf.workshop")
		workshop.DoClick = function()
			steamworks.ViewFile("3684885115")
		end

		return
	end

	EXT.Scroll = vgui.Create("DScrollPanel", EXT.Container)
	EXT.Scroll:Dock(FILL)

	EXT.Layout = vgui.Create("DIconLayout", EXT.Scroll)
	EXT.Layout:Dock(FILL)
	EXT.Layout:SetSpaceX(2.5)
	EXT.Layout:SetSpaceY(2.5)
end

EXT.Browse = function(filePath)

	if (!PEPlus_ProcessedPCFs) then return end

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