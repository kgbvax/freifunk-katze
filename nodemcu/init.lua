wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","password")
-- wifi.sta.autoconnect(0)
wifi.sta.connect()

print("Wifi initalized ",wifi.sta.getmac(), wifi.sta.getip())

 
function errorHandler() 
 print("error : " .. error)
end

function startup() 
    print('I')
    local fn_actions=loadfile('actions.lua')
    pcall(fn_actions,errorHandler)
    
    print('II')
    local fn_control=loadfile('script-mtt.lua')
    pcall(fn_control,errorHandler)
end

tmr.alarm(0,15000,0,startup)

