-- Logica compartilhada das telas de configuracoes

function Initialize()
	inc = SKIN:ReplaceVariables('#@#Variables.inc')
	root = SKIN:GetVariable('ROOTCONFIG')
	group = SKIN:GetVariable('Group')
end

local function write(key, value)
	SKIN:Bang('!WriteKeyValue', 'Variables', key, tostring(value), inc)
end

local function refresh()
	SKIN:Bang('!RefreshGroup', group)
end

-- incrementa/decrementa uma variavel numerica dentro de [min, max]
function Step(key, delta, min, max)
	local v = tonumber(SKIN:GetVariable(key)) or 0
	v = math.max(min, math.min(max, v + delta))
	v = math.floor(v * 100 + 0.5) / 100
	write(key, v)
	refresh()
end

-- inverte uma variavel 0/1
function Flip(key)
	write(key, tonumber(SKIN:GetVariable(key)) == 1 and 0 or 1)
	refresh()
end

-- liga/desliga um widget (carrega ou descarrega a config)
function Toggle(key, name)
	local on = tonumber(SKIN:GetVariable(key)) == 1
	local config = root .. '\\' .. name
	if on then
		SKIN:Bang('!DeactivateConfig', config)
	else
		SKIN:Bang('!ActivateConfig', config, name .. ((SKIN:GetVariable('Lang') == 'en') and '_en.ini' or '.ini'))
	end
	write(key, on and 0 or 1)
	SKIN:Bang('!Refresh')
end

-- aplica um tema: copia T<i>_<chave> para <chave> em todas as ThemeKeys
function ApplyTheme(i)
	for key in string.gmatch(SKIN:GetVariable('ThemeKeys'), '[^|]+') do
		local v = SKIN:GetVariable('T' .. i .. '_' .. key)
		if v then write(key, v) end
	end
	write('ThemeIndex', i)
	refresh()
end

-- Rainmeter pode entregar a string em ANSI (Latin-1); garante UTF-8
local function toUtf8(s)
	local i, n = 1, #s
	while i <= n do
		local c = s:byte(i)
		local len = (c < 0x80 and 1) or (c >= 0xF0 and 4) or (c >= 0xE0 and 3) or (c >= 0xC2 and 2) or 0
		if len == 0 then break end
		for j = 1, len - 1 do
			local cc = s:byte(i + j)
			if not cc or cc < 0x80 or cc > 0xBF then len = 0 break end
		end
		if len == 0 then break end
		i = i + len
	end
	if i > n then return s end
	return (s:gsub('[\128-\255]', function(ch)
		local b = ch:byte()
		return string.char(0xC0 + math.floor(b / 64), 0x80 + b % 64)
	end))
end

local function urlencode(s)
	return (s:gsub('[^%w%-_%.~]', function(c)
		return string.format('%%%02X', c:byte())
	end))
end

-- dispara a busca de coordenadas para a cidade digitada
function SearchCity()
	local city = SKIN:GetVariable('City') or ''
	if city == '' then return end
	write('GeoQuery', urlencode(toUtf8(city)))
	write('GeoPending', 1)
	SKIN:Bang('!Refresh')
end

-- chamado quando o geocoding termina
function GeoDone()
	local lat = SKIN:GetMeasure('MeasureGeoLat'):GetStringValue()
	local lon = SKIN:GetMeasure('MeasureGeoLon'):GetStringValue()
	write('GeoPending', 0)
	if lat ~= '' and lon ~= '' then
		write('Latitude', lat)
		write('Longitude', lon)
	end
	refresh()
end
