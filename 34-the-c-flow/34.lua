--Pré condições:
----Os arquivos stops_words.txt e input.txt devem estar na pasta a cima de onde encontra-se o arquivo de script.
--Pós condições: Uma lista ordenada com as 25 palavras mais frequentes.
function has_value (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end

--Recebe um caminho para um arquivo de onde lerá o texto.
--Se o parâmetro não for uma string, não faz nada.
--Se o caminho for nulo, não faz nada.
--Se o caminho for inválido, "lança exceção"
--Retorna um conjunto de strings como cada palavra do texto que não é stop_word.
--Pre condições: path_to_file = arquivo de leitura e stop_words deve existir.
--Pos condições: Uma lista de palavras filtradas é retornada.
function extract_words(path_to_file)
  local fail = false
  local word_list = {}
  local str_data = ""
  local stop_words = {}
  if type(path_to_file) == "string" and path_to_file ~= nil then
    if pcall(function()
      local f = io.open(path_to_file,"r")
      str_data = f:read("*all")
      f:close()
    end) then
    else
      io.write("I/O error when opening " .. path_to_file)
      fail = true
    end
  end

  if fail == false then
    str_data = string.lower(string.gsub(str_data, "%W", " "))
    for w in string.gmatch(str_data, "%w+") do
      table.insert(word_list, w)
    end

    if pcall(function()
      local f = io.open("stop_words.txt","r")
      for w in string.gmatch(string.gsub(f:read(), ",", " "), "%w+") do
        table.insert(stop_words, w)
      end
    end) then
    else
      io.write("I/O error when opening stops_words.txt")
      fail = true
    end
  end

  local filtered = {}
  for k, v in pairs(word_list) do
    if not has_value(stop_words, v) then
      table.insert(filtered,v)
    end
  end

  return filtered
end
--Pre condições: Uma lista de palavras que não seja vazia.
--Pos condições: uma lista com as palavras e o numero de vezes que ocorrem.
function frequencies(word_list)
  if type(word_list) == "table" and next(word_list) ~= nil then
    local word_freqs = {}
    for k, v in pairs(word_list) do
      if word_freqs[v] ~= nil then
        word_freqs[v] = word_freqs[v] + 1
      else
        word_freqs[v] = 1
      end
    end
    return word_freqs
  else
    return {}
  end
end

function comparator(a, b)
  return a[1] > b[1]
end
--Pre condições: Uma lista de palavras com o numero de ocorrencias.
--Pos condições: Uma lista ordenada em ordem decrescente de palavras com a frequencia de cada uma.
function sort(word_freqs)
  if type(word_freqs) == "table" and next(word_freqs) ~= nil then
    table.sort(word_freqs, comparator)
    return word_freqs
  else
    return {}
  end
end

--Checa se recebeu como parâmetro o nome espécifico do arquivo a ser lido.
--Caso não tenha recebido lê do araquivo "../input.txt"
if #arg > 0 then
  filename = arg[1]
else
  filename = "input.txt"
end


for k,v in pairs(sort(frequencies(extract_words(filename)))) do print(k,v) end
