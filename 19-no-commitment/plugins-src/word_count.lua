local word_count = {}

function word_count.extract_words(path_to_file) 
	local words = {}
	file = io.open(path_to_file, "r")
	for w in string.gmatch(file:read("*all"), "%w+") do
		table.insert(words, string.lower(w))
	end
	return words
end

return word_count
