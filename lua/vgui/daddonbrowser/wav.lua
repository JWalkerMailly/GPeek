
local EXT = {}
local FFT = {}

EXT.Icon = "icon16/sound.png"

local spectrumRT  = GetRenderTarget("GPeekSpectrumPreview", 256, 256)
local spectrumMat = CreateMaterial("GPeekSpectrumPreview", "UnlitGeneric", {
	["$basetexture"] = "GPeekSpectrumPreview",
	["$additive"]    = 1
})

local function spectrum(channel)

	if (!IsValid(channel)) then return end

	EXT.Channel = channel
	EXT.Channel:EnableLooping(false)
	EXT.Channel:Play()

	EXT.Container.Paint = function(s, w, h)

		if (!IsValid(EXT.Channel)) then return end

		render.PushRenderTarget(spectrumRT)
		cam.Start2D()
		render.Clear(0, 0, 0, 0, true, true)

		local bands = EXT.Channel:FFT(FFT, FFT_256) * 0.5
		for i = 1, bands do

			local amplitude = FFT[i] || 0
			local barHeight = amplitude * 256
			local x = (i - 1) * 4
			local y = 256 - barHeight

			surface.SetDrawColor(HSVToColor(i / bands * 360, 1, 1))
			surface.DrawRect(x, y, 4, barHeight)
		end

		cam.End2D()
		render.BlurRenderTarget(spectrumRT, 4, 4, 4)
		render.PopRenderTarget()

		surface.SetMaterial(spectrumMat)
		for i = 1, 4 do
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end
end

EXT.Initialize = function(browser, name, path, dir)

	if (IsValid(EXT.Container)) then return end

	EXT.Container = vgui.Create("DPanel")

	EXT.FileName = vgui.Create("DLabel", EXT.Container)
	EXT.FileName:Dock(TOP)
	EXT.FileName:DockMargin(0, 0, 0, 5)

	local stop = vgui.Create("DButton", EXT.Container)
	stop:Dock(TOP)
	stop:SetText("Stop")
	stop.DoClick = function()
		EXT.Invalidate()
	end

	browser:SetContent(EXT.Container)
end

EXT.Browse = function(browser, name, path, dir)
	EXT.FileName:SetText("/" .. dir .. "/" .. name)
	sound.PlayFile(dir .. "/" .. name, "noblock", spectrum)
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	if (IsValid(EXT.Channel)) then EXT.Channel:Stop() end
end

return EXT