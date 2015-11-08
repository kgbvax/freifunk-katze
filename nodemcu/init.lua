print("initial heap: "..node.heap())
node.setcpufreq(node.CPU160MHZ)


--globals
MYTOPIC="/warpzone.ms/winkekatze" --base 

local STARTUP_DELAY=25000
local SSID="foo"
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID,"finetobaccos")
-- wifi.sta.autoconnect(0)
wifi.sta.connect()
print("Wifi initalized ",wifi.sta.getmac() .. " " .. SSID)


function errorHandler() 
 print("error : " .. error)
end

function runF(name)
  print ("running "..name .. " heap before "..node.heap())
  pcall(loadfile(name),errorHandler)
end

function startup() 
    runF('co2.lua') 
    runF('actions.lua')
    runF('script-mtt.lua')
end

print("startup in " .. STARTUP_DELAY/1000)
tmr.alarm(0,STARTUP_DELAY,0,startup)

