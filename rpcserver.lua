
socket = require("socket")

servants = {}
pool = {}

function criaObjeto(nomeInterface, indiceObj)
	indice = indiceObj
	g = assert(loadfile(nomeInterface))
	g()
	assert(loadstring("servants[indice] = " .. nomeInterface))()
end

function interpretaChamada(interface, chamada)
	chamada = string.gsub(chamada, ":", "\"].", 1)
	fun = "return servants[\"" .. string.gsub(chamada, ",", "(", 1) .. ")"
	f = assert(loadstring(fun))
	resultado = {f()}
	local resp = ""
	for i, value in pairs(resultado) do
		if resp ~= "" then
			resp = resp .. "," .. value
		else
			resp = value
		end
	end
	return(resp .. "\n")
end

ip = "*"
porta = 15000
maxPoolSize = 2
function waitIncomingRPC()
	local server = assert(socket.bind(ip, porta))
	socks = {server}

	oldest = 0
	
	while true do
		recvt, dummy, err = assert(socket.select(socks, nil, 0))

		-- Coloca o cliente no pool
		for i, serv in ipairs(recvt) do
			local client = serv:accept()
			
			if #pool == maxPoolSize then
				pool[oldest]:close()
				pool[oldest] = client
				if oldest >= #pool then
					oldest = 1
				else
					oldest = oldest + 1
				end
			else
				oldest = oldest + 1
				pool[oldest] = client
			end
		end

		-- Le o pool
		for j, client in ipairs(pool) do
			--if client ~= nil then
				chamada, err = client:receive("*l")
				if chamada ~= nil then
					if chamada == "" then 
						client:send("ACK\n")
					else
						local resposta = interpretaChamada(interface, chamada)
						local err = client:send(resposta)
						--client:close()
					end
				end
			--end
		end
	end
end

-- inicia as interfaces
criaObjeto("myinterface", "1000")
criaObjeto("myinterface", "1001")
criaObjeto("myinterface", "1002")

-- divulga informacao de acesso a serv 
waitIncomingRPC()




