wifi.setmode(wifi.STATION)
wifi.sta.config("warpzone","Er20TUp+13soS")
-- wifi.sta.autoconnect(0)
wifi.sta.connect()

print("Wifi initalized ",wifi.sta.getmac(), wifi.sta.getip())

 

function startup()
    print('in startup')
    dofile("warpkatze.lua")
end

tmr.alarm(0,10000,0,startup)


