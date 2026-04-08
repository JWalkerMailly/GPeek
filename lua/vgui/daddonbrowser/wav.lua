
local EXT = {}

EXT.Icon = "icon16/sound.png"

EXT.Initialize = function(browser, name, path, dir)
	-- override
end

EXT.Browse = function(browser, name, path, dir)

	local fft = {}
	sound.PlayFile(dir .. "/" .. name, "noblock", function(channel)

		if (!IsValid(channel)) then return end

		EXT.Channel = channel
		EXT.Channel:EnableLooping(false)
		EXT.Channel:Play()

		local content = vgui.Create("DPanel")
		content.Paint = function(s, w, h)

			if (!IsValid(EXT.Channel)) then return end

			local bands = EXT.Channel:FFT(fft, FFT_256) / 2.0
			local barWidth = math.ceil(w / bands)

			for i = 1, bands do

				local amplitude = fft[i] || 0
				local barHeight = amplitude * h
				local x = (i - 1) * barWidth
				local y = h - barHeight

				surface.SetDrawColor(HSVToColor(i / bands * 360, 1, 1))
				surface.DrawRect(x, y, barWidth, barHeight)
			end
		end

		local fileName = EXT.Channel:GetFileName()
		local bitsPerSample = EXT.Channel:GetBitsPerSample()
		local averageBitRate = EXT.Channel:GetAverageBitRate()
		local length = EXT.Channel:GetLength()
		local tags = EXT.Channel:GetTagsID3() || ""

		local test1 = vgui.Create("DLabel", content)
		test1:SetText(fileName)
		test1:Dock(TOP)

		local test2 = vgui.Create("DLabel", content)
		test2:SetText(bitsPerSample)
		test2:Dock(TOP)

		local test3 = vgui.Create("DLabel", content)
		test3:SetText(averageBitRate)
		test3:Dock(TOP)

		local test4 = vgui.Create("DLabel", content)
		test4:SetText(length)
		test4:Dock(TOP)

		local test5 = vgui.Create("DLabel", content)
		test5:SetText(tags)
		test5:Dock(TOP)

		local test6 = vgui.Create("DButton", content)
		test6:SetText("Stop")
		test6.DoClick = function()
			EXT.Invalidate()
		end

		browser:SetContent(content)
	end)
end

EXT.RightClick = function(menu, name, path, dir)
	-- override
end

EXT.Invalidate = function()
	if (IsValid(EXT.Channel)) then
		EXT.Channel:Stop()
	end
end

return EXT