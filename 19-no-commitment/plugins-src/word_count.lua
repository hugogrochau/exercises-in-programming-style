local word_count = {}

-- PRE: path_to_file aponta para um aquivo com as palavras a serem contadas
-- POS: words contem uma tabela de palavras
-- ARG: gmatch quebra a entrada em palavras e table.insert as insere na tabela
function word_count.extract_words(path_to_file) 
	local words = {}
	file = io.open(path_to_file, "r")
	for w in string.gmatch(file:read("*all"), "%w+") do
		table.insert(words, string.lower(w))
	end
	return words
end

return word_count
