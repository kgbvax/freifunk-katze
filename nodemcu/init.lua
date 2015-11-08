print("initial heap: "..node.heap())
node.setcpufreq(node.CPU160MHZ)

NET=false -- true if mqtt client connected
-- globals
local STARTUP_DELAY=25000
local SSID="foo"
local WIFIPWD="finetobaccos"
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID,WIFIPWD)
-- wifi.sta.autoconnect(0)
wifi.sta.connect()
-- print("Wifi initalized ",wifi.sta.getmac() .. " " .. SSID)
 
function errorHandler() 
 print("error : " .. error)
end

function runF(name)
  print ("running "..name .. " heap before "..node.heap())
  pcall(loadfile(name..".lua"),errorHandler)
end

function startup() 
    runF('actions')
    runF('co2') 
    runF('script-mtt')
end

print("startup in " .. STARTUP_DELAY/1000)
tmr.alarm(0,STARTUP_DELAY,0,startup)

