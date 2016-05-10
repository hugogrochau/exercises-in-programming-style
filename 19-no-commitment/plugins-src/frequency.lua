local frequencies = {}

-- PRE: words_list list é uma tabela de palavras
-- POS: words é uma tabela ordenada por frequencia de pares { palavra, frequencia } com até 25 elementos
-- ARG: sort garante que a tabela é ordenada e o ultimo for de que apenas as primeiras 25 estão na tabela
function frequencies.top25(words_list)

	local count = {}
	for k,v in pairs(words_list) do
		count[v] = (count[v] or 0)+1
	end

	local words = {}
	for k,v in pairs(count) do
		table.insert(words, {k,v})
	end

	local function by_freq(a,b)
		return a[2] > b[2]
	end
	table.sort(words, by_freq)
	for i=25,#words do
		words[i] = nil
	end
	return words
end

return frequencies
