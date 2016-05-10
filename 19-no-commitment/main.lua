-- PRE: config, words, frequencys devem existir.
--      words e frequencys devem estar devidamente pre-compiladas
-- POS: twords e tffreqs devem ter carregado as funções esperadas por esse programa.
-- ARG: é esperado que isso seja seguido por ser a proposta do estilo do código.
-- @note: nomes foram seguidos por serem os originais e alterá-los poderia ser confuso.
--        em outra situação os nomes seriam alterados para outros mais legiveis.
function load_plugins()
	local config  = require("config")
	tfwords = require(config.words)
	tffreqs = require(config.frequencys)
end

-- main
load_plugins()
ordered_words = tffreqs.top25(tfwords.extract_words(arg[1]))

for k,v in pairs(ordered_words) do
	print(v[1], v[2])
end
