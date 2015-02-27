init start

	local Config = {
		MaxLines = 10,
		ShowNothing = false,
		Items = {'cheese'},
		Scroll = true,
		Length = 60,
	}

	-- DO NOT EDIT BELOW THIS LINE --

	LootMessages = LootMessages or {}

	local HUD = {
		Restart = -1,
		Start = 1,
		End = Config.MaxLines,
		strStart = 1,
		strEnd = 30,
		strMax = 30,
		Position = {$worldwin.right + 3, $worldwin.bottom - (Config.MaxLines * 16)},
		Auxiliar = {0, 0},
		ColumnWidth = {125, 12},
		Moving = false,
		Blue = {0.0, color(36, 68, 105, 20), 0.23, color(39, 73, 114, 20), 0.76, color(21, 39, 60, 20)},
		Black = {0.0, color(75, 75, 75, 20), 0.23, color(45, 45, 45, 20), 0.76, color(19, 19, 19, 20)},
		Orange = {0.0, color(145, 95, 0, 20), 0.23, color(158, 104, 0, 20), 0.76, color(84, 55, 0, 20)},
		Green = {0.0, color(65, 96, 12, 20), 0.23, color(67, 99, 13, 20), 0.76, color(36, 52, 6, 20)},
		Red = {0.0, color(90, 12, 15, 20), 0.23, color(98, 13, 17, 20), 0.76, color(52, 6, 9, 20)},
	}

	local tempPos = $chardb:getvalue('AWE.RL', 'POSITION')

	if tempPos then
		tempPos = tempPos:explode(":")
		HUD.Position = {tonumber(tempPos[1]), tonumber(tempPos[2])}
	end

	table.lower(Config.Items) filterinput(true, true, true, Config.Scroll) setfillstyle('gradient', 'linear', 2, 0, 0, 0, 14) setfontstyle('Tahoma', 8, 50, 0xFFFFFF, 1, color(0, 0, 0, 50))

	function inputevents(e)
		if e.type == IEVENT_RMOUSEDOWN or e.type == IEVENT_MMOUSEDOWN then
			HUD.Moving, HUD.Auxiliar = true, {$cursor.x - HUD.Position[1], $cursor.y - HUD.Position[2]}
		elseif e.type == IEVENT_RMOUSEUP or e.type == IEVENT_MMOUSEUP then
			HUD.Moving = false
		elseif e.type == IEVENT_MOUSEWHEEL then
			if iskeypressed(0x12) then
				if e.value2 < 0 then
					HUD.strStart, HUD.strEnd = HUD.strStart - 1, HUD.strEnd - 1
				elseif e.value2 > 0 then
					HUD.strStart, HUD.strEnd = HUD.strStart + 1, HUD.End + 1
				end
				if HUD.strStart > HUD.strMax then
					HUD.strStart, HUD.strEnd = 1, 30
				end
			else
				if #LootMessages > Config.MaxLines then
					if e.value2 < 0 then
						if HUD.Start <= #LootMessages - Config.MaxLines then
							HUD.Start, HUD.End = HUD.Start + 1, HUD.End + 1
						end
					elseif e.value2 > 0 then
						if HUD.End > Config.MaxLines then
							HUD.Start, HUD.End = HUD.Start - 1, HUD.End - 1
						end
					end
				end
			end
		elseif e.type == IEVENT_LMOUSEUP then
			if e.elementid == HUD.Restart then
				LootMessages = {}
			end
		end
	end

	local function displaytext(text, x, y, c)
		addgradcolors(unpack(c))
		local w, h = measurestring(text)
		HUD.ColumnWidth[1], HUD.ColumnWidth[2] = math.max(HUD.ColumnWidth[1], w or 0), math.max(HUD.ColumnWidth[2], h or 0)
		local t = drawroundrect(x, y, HUD.ColumnWidth[1] + 7, HUD.ColumnWidth[2], 2, 2)
		drawtext(text, x + 2, y + math.floor(HUD.ColumnWidth[2] / 4) - 2.4)
		return t
	end

init end

if HUD.Moving then
	auto(10)
	HUD.Position = {$cursor.x - HUD.Auxiliar[1], $cursor.y - HUD.Auxiliar[2]}
	$chardb:setvalue('AWE.RL', 'POSITION', table.concat(HUD.Position, ':'))
end

foreach newmessage m do
	if m.type == MSG_INFO then
		local Monster, Loot = m.content:match('Loot of a?n? (.+): (.+)')

		if Monster and (Loot ~= 'nothing' or Config.ShowNothing) then
			local tempLoot = Loot:lower()

			if HUD.End + #LootMessages >= Config.MaxLines * 2 then
				HUD.Start, HUD.End = HUD.Start + 1, HUD.End + 1
			end

			Monster = Monster:gsub('the ', '', 1)

			local Warn = false

			for _, Item in pairs(Config.Items) do
				if tempLoot:find(Item) then
					Warn = true
					break
				end
			end

			table.insert(LootMessages, {text = string.format("%s %s: %s", os.date("%H:%M"), Monster:gsub("(%a)([%w_']*)", function(s1, s2) return s1:upper() .. s2:lower() end), Loot), color = Warn and HUD.Orange or HUD.Black})
		end
	end
end

local x, y, w, h = 0, 0, 0, 0

displaytext(" Recent Loots:", x, y, HUD.Blue)
addgradcolors(unpack(#LootMessages > 0 and HUD.Green or HUD.Red))

w, h = measurestring("RESET")
HUD.ColumnWidth[1] = math.max(HUD.ColumnWidth[1], w)
HUD.Restart = drawroundrect(x - w + HUD.ColumnWidth[1], y, w + 7, h, 2, 2)

drawtext("RESET", 5 + x - w + HUD.ColumnWidth[1], y + math.floor(h / 4) - 2.4)

y = y + 20

for i = HUD.Start, HUD.End do
	if LootMessages[i] then
		local msg = LootMessages[i].text
		local h, j = math.max(1, HUD.strStart), math.max(msg:len(), HUD.strEnd)
		HUD.strMax = math.max(HUD.strMax, msg:len())
		if h == 2 then
			msg = "." .. msg:sub(h, j)
		elseif h == 3 then
			msg = ".." .. msg:sub(h, j)
		elseif h >= 4 then
			msg = "..." .. msg:sub(h, j)
		else
			msg = msg:sub(h, j)
		end
		displaytext(msg:fit(Config.Length or 60), x, y, LootMessages[i].color)

		y = y + 16
	end
end

setposition(unpack(HUD.Position))
