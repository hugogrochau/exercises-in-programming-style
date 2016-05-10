-- Title: Tantrum
-- Author: Michelle Valente and Tatiana Magdalena
-- Date: 09/05/2016
-- Version: 1.0


-- The functions
-- Extract words from file
-- Pre: path to file
-- Pos: a table with all the words.
-- The function reads each words from the file inserting in a table.
-- Assert function makes sure that the path is valid and pcall if it was open right
function extract_words(path_to_file)

	local content
	local words = {}

    assert(type(path_to_file) == "string", "I need a string!" )
    assert((path_to_file), "I need a non-empty string!" )

    if pcall(function ()
        local file = io.open(path_to_file,"r")
        content = file:read("*all")
        file:close()
        end) then
    else
        io.write(string.format("I/O error when opening {%s}: I quit!\n",path_to_file))
    end
    
    for word in string.gmatch(content, "%w+") do
        table.insert(words, string.lower(word))
    end
    return words
end


-- Remove words that are not going to be counted
-- Pre: list with all the words
-- Pos: List without the not used words
-- Assert and pcall checks if the file is valid and if the list
-- is valid.
function remove_stop_words(word_list)
    assert(type(word_list) == "table", "I need a table!")

    if pcall(function () 
        local f = io.open("stop_words.txt","r")
        local stop_words = f:read("*all")
        stop_words_final = {}
        for word in string.gmatch(stop_words, '([^,]+)') do
            table.insert(stop_words_final, word)
        end
        f:close()
        end) then
    else
        io.write(string.format("I/O error when opening ../stop_words.txt: I quit!\n",path_to_file))
    end

    words_list_final = {}
    for index, word in pairs(word_list) do
        lower_word = word:lower()
        if(not has_value(stop_words_final, lower_word))then 
            table.insert(words_list_final, lower_word)
        end
    end
    return words_list_final
end

-- Auxiliar function to check if there is value in the table
-- Pre: table and value that you are looking for
-- Pos: True if found the word and false if not
function has_value (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- Get the frequencie of each word
-- Pre: List with all the words
-- Pos: Table with word and frequency
-- Assert function makes sure its a table the input
-- and the new table is created in loop to all the table
function frequencies(word_list)
    assert(type(word_list) == "table", "I need a table!")

    word_freqs = {}
    for index, word in pairs( word_list ) do
        word_freqs[word] = 0
    end

    for index, word in pairs( word_list ) do
        word_freqs[word] = word_freqs[word] + 1
    end

    return word_freqs
end

-- Auxiliar function that takes a table and create an array of pairs
-- and sort it.
-- PRE: table and function to order.
-- POS: Sorted frequencies
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for key in pairs(t) do keys[#keys+1] = key end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- Sort the table
-- Pre: list with words and frequencies not sorted
-- Pos: list with words and frequencies sorted
-- Assert function makes sure the input is a table and not empty
-- xpcall makes sure the sort function works
function sort(word_freq)

	local sortedWords = {}
	assert(type(word_freq) == "table", "I need a table!")
	assert((word_freq), "I need a non-empty table!")

	xpcall(function()
                for key,value in spairs(word_freq, function(t,a,b) return t[b] < t[a] end) do
                    if(value > 200) then
                        print(key .. "-" .. value)
                    end
                end
			end,

			function(err)
				io.write("Sorted threw: " .. err)
			end)
	return word_freq
end

-- Auxiliar function to get the lenght of a table
-- Pre: Table that you want the lengh
-- Pos: Size of the table
function len(tab)
	local count = 0;
	for index in pairs(tab) do 
		count = count + 1
	end

	return count
end


--The main function
-- xpcall and assert makes sure every function works and gives 
-- the returned value expected.
xpcall(function () 

			local word_freqs

			assert((arg[1]), "You idiot! I need an input file!")
			word_freqs = sort(frequencies(remove_stop_words(extract_words(arg[1]))))

			assert(type(word_freqs) == "table", "OMG! This is not a table!")
			assert((len(word_freqs) > 25), "SRSLY? Less than 25 words!")

		end,

		function(err)

			io.write("Something wrong: " .. err)
			io.write(debug.traceback())

		end)
