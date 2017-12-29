
socket = require("socket")


ip = "localhost"
port = 15000

interface = "lalala"
function criaRPCProxy()
	local client = assert(socket.connect(ip, port))
	tempos = ""
	for i = 1, 1000 do
	
		begin = socket.gettime()
		
		err = client:send("\n")
		data, err = client:receive("*l")
		while data ~= "ACK" do			
			client = assert(socket.connect(ip, port))
			err = client:send("\n")
			data, err = client:receive("*l")
		end
		
		err = client:send("1002:foo,3,2,1\n")
	
		data, err = client:receive("*l")
		
		duration = socket.gettime() - begin
		tempos = tempos.."\n"..duration
	end
end

criaRPCProxy()
--rpc.foo(1,2,3)

print("fim")

local file = assert(io.open("tempos"..arg[1], "wb"))
	
	if file == nil then
		print("Erro ao abrir arquivo " .. filename)
		return
	end
	
	file:write(tempos)
	file:close()