-- import the wifi credentials
-- dofile("cred.lua")

local SSID = "lightShow"
local PWD = "lightshowpi"

local wifi_trys = 15	-- Counter of trys to connect to wifi
local NUMWIFITRYS = 200	-- Maximum number of wifi testings while waiting for connection

local function launch()
	-- initialize all the pins low
	for x=1,8,1 do
		gpio.mode(x, gpio.OUTPUT, gpio.PULLUP)
		gpio.write(x, gpio.LOW)
	end

	-- optimize garbage collection
	node.egc.setmode(node.egc.ON_ALLOC_FAILURE)

	-- set the cpu freq to 11
	node.setcpufreq(node.CPU160MHZ)

	-- Call our command file. Note: If you foul this up you'll brick the device!!
	dofile("lightshowclnt.lua")
end

local function check_WIFI()
	if( wifi_trys > NUMWIFITRYS ) then
		print("Sorry, not able to connect")
	else
		local ip_addr = wifi.sta.getip()
		if ( ( ip_addr ~= nil ) and ( ip_addr ~= "0.0.0.0" ) ) then
			tmr.alarm(1, 500, 0, launch)
		else
			-- reset alarm
			tmr.alarm(0, 2500, 0, check_WIFI)
			print("Checking WIFI.. " .. wifi_trys)
			wifi_trys = wifi_trys + 1
		end
	end
end

-- check if we are already connected
local ip_addr = wifi.sta.getip()
if ( ( ip_addr == nil ) or ( ip_addr == "0.0.0.0" ) ) then
	-- We arent connected, so lets connect
	wifi.setmode(wifi.STATION)
	wifi.sta.config( {ssid=SSID, pwd=PWD, save=true} )
	tmr.alarm(0,2500,0,check_WIFI)
else
	-- we are connected, just launch the code
	launch()
end
