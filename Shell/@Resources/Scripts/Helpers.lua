-- Funcoes chamadas inline nos textos: [&ScriptHelpers:Bar('MeasureCPU')]
-- Retorna so ASCII (F/E): o Lua do Rainmeter passa texto em ANSI, entao os
-- caracteres unicode da barra sao aplicados por Substitute no .ini.

function Initialize()
end

-- barra de texto proporcional ao valor (0-100) de uma medida
function Bar(name)
	local m = SKIN:GetMeasure(name)
	local pct = m and m:GetValue() or 0
	local len = tonumber(SKIN:GetVariable('BarLen')) or 18
	local n = math.max(0, math.min(len, math.floor(pct / 100 * len + 0.5)))
	return string.rep('F', n) .. string.rep('E', len - n)
end

-- frase do dia: Quote1..QuoteN, muda a cada dia
function Quote()
	local count = tonumber(SKIN:GetVariable('QuoteCount')) or 1
	local idx = (os.date('*t').yday % count) + 1
	return SKIN:GetVariable('Quote' .. idx) or ''
end
