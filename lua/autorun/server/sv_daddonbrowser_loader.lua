
for k,v in pairs(file.Find("vgui/daddonbrowser/*", "LUA")) do
	AddCSLuaFile("vgui/daddonbrowser/" .. v)
end