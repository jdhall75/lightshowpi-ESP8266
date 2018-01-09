-- listen port 
local port = 8888

-- power level in the json array from lightshowpi to turn on
local turnon = .4

-- channels 1-4 in the json array
local chans = {1,2,3,4}

-- pins to opperate the relays
local pins = {4,3,2,1}

-- map the channels to pins in a lua table
local chan_to_pin = {}
for idx, chan in ipairs(chans) do
	chan_to_pin[chan] = pins[idx]
end

-- bool return true if local channel in 
-- json array(table)
function has_key(tab, val)
	if tab[val] ~= nil then
		return true
	end
	return false
end


-- emulate the arduino map function for 
-- generating pwm duty cycle values
function map(val, in_min, in_max, out_min, out_max)
	return (val - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

			

local function decodeMSG(s, data, port, ip)
	
	-- decode json into lua table
	local t = sjson.decode(data)
	-- lightshowpi tends to send out small arrays for channel data
	-- test if the table is larger than 3 values
	if table.getn(t) > 3 then
		for chan, brightness in ipairs(t) do
			if brightness >= turnon and has_key(chan_to_pin, chan)  then
			--	print("Turning pin %d on", chan_to_pin[chan])
				gpio.write(chan_to_pin[chan], gpio.HIGH)
			elseif has_key(chan_to_pin, chan)  then
			--	print("Turning pin %d off", chan_to_pin[chan])
				gpio.write(chan_to_pin[chan], gpio.LOW)
			end
		end
	end
end

local udp = net.createUDPSocket()
udp:listen(port)
udp:on("receive", decodeMSG)
