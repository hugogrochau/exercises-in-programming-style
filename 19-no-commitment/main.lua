function load_plugins()
	local config  = require("config")
	tfwords = require(config.words)
	tffreqs = require(config.frequencys)
end

load_plugins()
ordered_words = tffreqs.top25(tfwords.extract_words(arg[1]))

for k,v in pairs(ordered_words) do
	print(v[1], v[2])
end
