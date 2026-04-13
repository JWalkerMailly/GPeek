--[[
DPanel (EXT.Container)
├── DButton (Stop)
│     - Stops currently playing audio channel
│
└── Paint (EXT.Container overridden by spectrum(channel))
      ├── FFT Processing
      │     - EXT.Channel (FFT_256)
      │
      ├── RenderTarget (spectrumRT 256x256)
      │
      ├── Post Processing
      │
      └── Material Pass (spectrumMat)
]]

local EXT = {}
local FFT = {}

EXT.Icon = "icon16/sound.png"

local spectrumRT  = GetRenderTarget("gPeekSpectrumPreview", 256, 256)
local spectrumMat = CreateMaterial("gPeekSpectrumPreview", "UnlitGeneric", {
	["$basetexture"] = "gPeekSpectrumPreview",
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

EXT.Initialize = function()

	local stop = vgui.Create("DButton", EXT.Container)
	stop:Dock(TOP)
	stop:SetText("#gpeek.extensions.wav.stop")
	stop.DoClick = function()
		EXT.Invalidate()
	end
end

EXT.Browse = function(filePath)
	EXT.Invalidate()
	sound.PlayFile(filePath, "noblock", spectrum)
end

EXT.RightClick = function(menu, filePath)
	-- override
end

EXT.Invalidate = function()
	if (IsValid(EXT.Channel)) then EXT.Channel:Stop() end
end

return EXT