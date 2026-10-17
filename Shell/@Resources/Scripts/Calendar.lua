-- Preenche um calendario mensal de 42 celulas (MeterDay1..MeterDay42)
-- e posiciona o destaque do dia atual (MeterToday).

function Initialize()
	last = ''
	runs = 0
end

function Update()
	local t = os.date('*t')
	local key = t.year .. '-' .. t.month .. '-' .. t.day
	runs = runs + 1
	-- as posicoes dos meters so existem depois do primeiro ciclo
	if key == last and runs > 2 then return end
	last = key

	local first = os.time{ year = t.year, month = t.month, day = 1, hour = 12 }
	local offset = tonumber(os.date('%w', first)) -- 0 = domingo
	local days = os.date('*t', os.time{ year = t.year, month = t.month + 1, day = 0, hour = 12 }).day
	local prev = os.date('*t', os.time{ year = t.year, month = t.month, day = 0, hour = 12 }).day

	local normal = SKIN:GetVariable('TileText')
	local other = SKIN:GetVariable('TileDim')
	local today = SKIN:GetVariable('F2')

	for i = 1, 42 do
		local d = i - offset
		local text, color = d, normal
		if d < 1 then
			text, color = prev + d, other
		elseif d > days then
			text, color = d - days, other
		elseif d == t.day then
			color = today
			local meter = SKIN:GetMeter('MeterDay' .. i)
			SKIN:Bang('!SetOption', 'MeterToday', 'X', meter:GetX())
			SKIN:Bang('!SetOption', 'MeterToday', 'Y', meter:GetY())
		end
		SKIN:Bang('!SetOption', 'MeterDay' .. i, 'Text', tostring(text))
		SKIN:Bang('!SetOption', 'MeterDay' .. i, 'FontColor', color)
	end
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end
