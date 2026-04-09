
AddCSLuaFile()

--- ttfname.lua
-- Reads the font name from a TTF file by parsing the OpenType name table.
-- Prioritizes English (Windows platform, UTF-16BE) with Mac platform as fallback.
-- Returns the full font name; nameID 4, falling back to family name; nameID 1.
-- https://learn.microsoft.com/en-us/typography/opentype/spec/name
ttfname = {}

local function readU16(data, offset)

	local hi = string.byte(data, offset)
	local lo = string.byte(data, offset + 1)

	if (!hi || !lo) then return nil end

	return hi * 256 + lo
end

local function readU32(data, offset)

	local b1 = string.byte(data, offset)
	local b2 = string.byte(data, offset + 1)
	local b3 = string.byte(data, offset + 2)
	local b4 = string.byte(data, offset + 3)

	if (!b1 || !b2 || !b3 || !b4) then return nil end

	return b1 * 16777216 + b2 * 65536 + b3 * 256 + b4
end

-- Decode a UTF-16BE encoded binary string into a plain ASCII/Latin string.
-- Strips null bytes and keeps only printable characters.
-- Also handles accented characters.
local function decodeUTF16BE(data)

	local chars = {}
	for i = 1, #data - 1, 2 do

		local hi = string.byte(data, i)
		local lo = string.byte(data, i + 1)
		local codepoint = hi * 256 + lo

		if (codepoint >= 32) then
			if (codepoint < 128) then
				chars[#chars + 1] = string.char(codepoint)
			elseif (codepoint < 2048) then
				chars[#chars + 1] = string.char(
					192 + math.floor(codepoint / 64),
					128 + (codepoint % 64)
				)
			else
				chars[#chars + 1] = string.char(
					224 + math.floor(codepoint / 4096),
					128 + math.floor((codepoint % 4096) / 64),
					128 + (codepoint % 64)
				)
			end
		end
	end

	return table.concat(chars)
end

local function decodeMacRoman(data)

	local chars = {}

	for i = 1, #data do

		local b = string.byte(data, i)

		if (b >= 32 && b < 128) then
			chars[#chars + 1] = string.char(b)
		end
	end

	return table.concat(chars)
end

-- Find the bytes offset of the name table.
-- TTF offset table: sfVersion, numTables, searchRange, entrySelector, rangeShift
-- Each table record: tag, checksum, offset, length
local function findNameTableOffset(data)

	if (#data < 12) then return nil end

	local numTables = readU16(data, 5)
	if (!numTables) then return nil end

	-- Table records start at byte 13 (1-indexed)
	local recordBase = 13
	for i = 0, numTables - 1 do

		local base = recordBase + i * 16
		local tag = string.sub(data, base, base + 3)

		if (tag == "name") then
			return readU32(data, base + 8)
		end
	end

	return nil
end

--- Read the font name from a TTF file's binary data.
-- Searches all name records, prioritizing Windows platform
-- Unicode BMP, English US, nameID 4
-- @param data string Raw binary contents of the TTF file.
-- @return string|nil The font name, or nil.
function ttfname.readFromData(data)

	if (!data || #data < 12) then return nil end

	local nameOffset = findNameTableOffset(data)
	if (!nameOffset) then return nil end

	-- Name table header: format, count, stringOffset
	local nameBase    = nameOffset + 1
	local format      = readU16(data, nameBase)
	local count       = readU16(data, nameBase + 2)
	local strOffset   = readU16(data, nameBase + 4)

	if (!format || !count || !strOffset) then return nil end

	local storageBase = nameBase + strOffset

	-- Parse all name records into a structured list.
	-- Each record is 12 bytes: platformID, encodingID, languageID, nameID, length, offset
	local records = {}
	local recordBase = nameBase + 6
	for i = 0, count - 1 do

		local base       = recordBase + i * 12
		local platformID = readU16(data, base)
		local encodingID = readU16(data, base + 2)
		local languageID = readU16(data, base + 4)
		local nameID     = readU16(data, base + 6)
		local length     = readU16(data, base + 8)
		local offset     = readU16(data, base + 10)

		if (platformID && nameID && length && offset) then
			records[#records + 1] = {
				platformID = platformID,
				encodingID = encodingID,
				languageID = languageID,
				nameID     = nameID,
				length     = length,
				offset     = offset,
			}
		end
	end

	local function getString(record)

		local start = storageBase + record.offset
		local raw   = string.sub(data, start, start + record.length - 1)

		if (#raw == 0) then return nil end

		if (record.platformID == 3) then
			return decodeUTF16BE(raw)
		end

		if (record.platformID == 1) then
			return decodeMacRoman(raw)
		end

		if (record.platformID == 0) then
			return decodeUTF16BE(raw)
		end

		return nil
	end

	-- Candidate resolution, try each strategy in priority order.
	local strategies = {
		-- 1. Windows, Unicode BMP, English US, full name
		function(r) return r.platformID == 3 && r.encodingID == 1 && r.languageID == 0x0409 && r.nameID == 4 end,
		-- 2. Windows, Unicode BMP, English US, family name
		function(r) return r.platformID == 3 && r.encodingID == 1 && r.languageID == 0x0409 && r.nameID == 1 end,
		-- 3. Windows, any encoding, English US, full name
		function(r) return r.platformID == 3 && r.languageID == 0x0409 && r.nameID == 4 end,
		-- 4. Windows, any encoding, any language, full name
		function(r) return r.platformID == 3 && r.nameID == 4 end,
		-- 5. Mac, Roman, English, full name
		function(r) return r.platformID == 1 && r.encodingID == 0 && r.languageID == 0 && r.nameID == 4 end,
		-- 6. Mac, Roman, English, familly name
		function(r) return r.platformID == 1 && r.encodingID == 0 && r.languageID == 0 && r.nameID == 1 end,
		-- 7. Any platform, full name
		function(r) return r.nameID == 4 end,
		-- 8. Any platform, family name
		function(r) return r.nameID == 1 end,
	}

	for _, strategy in ipairs(strategies) do
		for _, record in ipairs(records) do
			if (strategy(record)) then
				local name = getString(record)
				if (name && #name > 0) then
					return name
				end
			end
		end
	end

	return nil
end

--- Read the font name directly from a TTF file path.
-- @param filePath string Path to the TTF file.
-- @param searchPath string GLua search path.
-- @return string|nil The font name, or nil on failure.
function ttfname.readFromFile(filePath, searchPath)

	local data = file.Read(filePath, searchPath || "GAME")
	if (!data) then return nil end

	return ttfname.readFromData(data)
end

return ttfname