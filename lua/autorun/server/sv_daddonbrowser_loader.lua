
resource.AddWorkshop("3705662940")

AddCSLuaFile("includes/modules/ttfname.lua")

for k,v in pairs(file.Find("vgui/daddonbrowser/*", "LUA")) do
	AddCSLuaFile("vgui/daddonbrowser/" .. v)
end