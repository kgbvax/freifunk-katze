print("initial heap: "..node.heap())


PWM_freq = 50 --Hz
-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
servo1_pin=4 -- GPIO2
led_pin=1 -- GPIO5
 
servo_idle=55

local initHW=function() 
    node.setcpufreq(node.CPU160MHZ)
    pwm.setup(servo1_pin,PWM_freq,0)
    pwm.setup(led_pin,PWM_freq,0)
    pwm.setduty(led_pin,800)
    pwm.setduty(servo1_pin,servo_idle)
end

NET=false -- true if mqtt client connected
-- globals
local STARTUP_DELAY=25000
local SSID="Freifunk" --"foo"
local WIFIPWD="" --"finetobaccos"
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID,WIFIPWD)
-- wifi.sta.autoconnect(0) 
wifi.sta.connect()
-- print("Wifi initalized ",wifi.sta.getmac() .. " " .. SSID)
 
local errorHandler=function() 
 print("error : " .. error)
end

local runF = function(name)
  print ("running "..name .. " heap before "..node.heap())
  local f=loadfile(name..".lua")
  pcall(f,errorHandler)
end

local startup =function() 
    runF('actions')
    runF('co2') 
    runF('script-mtt')
    errorHandler=nil
    runF=nil
    initHW=nil
    startup=nil
end

initHW()
print("startup in " .. STARTUP_DELAY/1000)
tmr.alarm(0,STARTUP_DELAY,0,startup)

