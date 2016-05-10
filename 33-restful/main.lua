-- Split function
-- Pre: s = string, delimiter
-- Pos: array with the string split between the divisors
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--Initialize stops array
local letters = { 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q',
                  'r','s','t','u','v','x','y','z' };
local f            =  io.open("stop-words.txt", "r");
local file_content = f:read("*all");
local file_words   = split(file_content,",");
local stops        = {};
f:close();
local i = 1;
for idx, value in ipairs(file_words) do
	stops[i] = value;
	i = i + 1;
end

for idx, value in ipairs(letters) do
	stops[i] = value;
	i = i + 1;
end

-- The "database"
local data = {}

-- Internal functions of the "server"-side application
function error_state ()
	return "Something wrong", {"get", "default", nil}
end

-- The "server"-side application handlers
-- Pos: user instructions and links
function default_get_handler(args)
	local rep = "What would you like to do?";
	rep = rep .. "\n1 - Quit" .. "\n2 - Upload file";
    local links = {};
	links[1] = {"post", "execution", nil};
	links[2] = {"get", "file_form", nil};
    return rep, links;
end

-- Stops the server
function quit_handler (args)
    print("Goodbye cruel world...");
	os.exit();
end

-- Sends upload instructions
function upload_get_handler (args)
    return "Name of file to upload?", {"post", "file"};
end

-- Checks is a value exists in an array
-- Pre: Array and value
-- Pos: true if value in array else false
function value_exists_in (aArray, aValue)
	for i, value in pairs(aArray) do
		if value == aValue then
			return true;
		end
	end
	return false;
end

-- Handler for browsing through each of the most frequent words
-- Pre: args = {filename, word_index)
-- Pos: String with next most frequent word and links with options 
function word_get_handler(args)
    function get_word(filename, word_index)
        -- While there's still words
		if word_index < (# data[filename] + 1) then
            return data[filename][word_index];
        else
            return {"no more words", 0};
		end
	end

    local filename = args[1];
	local word_index = args[2];
    local word_info = get_word(filename, word_index);
    local rep = string.format("\n#%d: %s - %s", word_index, word_info[1], word_info[2]);
    rep   = rep .. "\n\nWhat would you like to do next?";
    rep   = rep .. "\n1 - Quit" .. "\n2 - Upload file";
    rep   = rep .. "\n3 - See next most-frequently occurring word";
    local links = {};
	links[1] = {"post", "execution", nil};
	links[2] = {"get", "file_form", nil};
	links[3] = {"get", "word", {filename, word_index+1}};
    return rep, links
end

-- Handles file upload simulation
-- Pre: args = filename
-- Pos: Fills the internal data table with word frequencies
function upload_post_handler (args)
	function create_data(filename)
		if value_exists_in(data, filename) then
			return;
		end

		local word_freqs = {};
		local f = io.open(filename, "r");
		local file_content = f:read("*all");
		f:close();
		local words_new = {};
		local index = 1;
        -- for each word in file
		for word in string.gmatch(file_content, "%S+") do
            -- if it isn't in the stopped words list and isn't a number
			if ( tonumber(word) == nil and (string.len(word) > 0) and (not value_exists_in(stops, string.lower(word))) ) then
				words_new[index] = word;
				index = index + 1;
			end
		end
        -- count each word's occurance
		for idx, word in pairs(words_new) do
			local added = false;
			for i, w in pairs(word_freqs) do
				if (i == word) then
					word_freqs[i] = word_freqs[i] + 1;
					added = true;
					break;
				end
			end
			if (not added) then
				word_freqs[word] = 1;
			end
		end
        -- sort by occurances (descending)
		local word_freqsl = {};
		for idx, word_count in pairs(word_freqs) do
			table.insert(word_freqsl, {idx,word_count});
		end
		table.sort(word_freqsl, function (a, b)
			return (a[2] > b[2]);
		end);
        data[filename] = word_freqsl;
	end

	if args == nil then
		return error_state();
	end

	filename = args;
	create_data(filename);
	return word_get_handler({filename, 1});
end


--Handler registration
local handlers = {
                   ["post_execution"] = quit_handler,
				   ["get_default"]    = default_get_handler,
				   ["get_file_form"]  = upload_get_handler,
				   ["post_file"]      = upload_post_handler,
				   ["get_word"]       = word_get_handler
				 };

--The "server" core
-- Pre: the action to execute and optional arguments
-- verb = post/get, uri = action
-- Pos: calls the proper function with the given arguments
function handle_request(verb, uri, args)
	local handlerKey = verb .. "_" .. uri;
	for idx, value in pairs(handlers) do
		if (idx == handlerKey) then
			return handlers[idx](args);
		end
	end
	return handlers["get" .. "_" .. "default"](args);
end

-- A very simple client "browser"
-- Pre: user instructions and links to possible actions
-- Pos: prints user instructions and links then receives the user selection and sends it to the server  
function render_and_get_input(state_representation, links)
	print(state_representation);
	io.flush();
	if (type(links[1]) == "table") then
		local input = io.read():gsub("^%s*(.-)%s*$", "%1"); -- remove whitespace before and after
		input = tonumber(input);
		for idx, value in pairs(links) do
			if (idx == input) then
				return links[input];
			end
		end
		return {"get", "default", nil};
	elseif type(links[1] == "string") then
		if (links[1] == "post") then -- get "form" data
			local input = io.read():gsub("^%s*(.-)%s*$", "%1"); -- remove whitespace before and after
			table.insert(links,input);
			return links;
		else -- get action, dont get user input
			return links;
		end
	else
		return {"get", "default", nil};
	end
end

local request = {"get", "default", nil};
while true do
	--"Server"-side computation
	local state_representation, links = handle_request(request[1], request[2], request[3]);
	--"Client"-side computation
	request = render_and_get_input(state_representation, links);
end
