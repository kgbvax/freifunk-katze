print("initial heap: "..node.heap())

servo1_pin=4 -- GPIO2
led_pin=1 -- GPIO5
servo_idle=55
NET=false -- true if mqtt client connected
MYTOPIC="/warpzone.ms/winkekatze" --base 
BROKER="mqtt.kgbvax.net"
 
do
    local STARTUP_DELAY=25000  --msec
    local SSID="Freifunk" --"foo"
    local WIFIPWD="" --"finetobaccos"
    local PWM_freq = 75 --Hz
    -- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
    
    local initHW=function() 
        node.setcpufreq(node.CPU160MHZ)
        pwm.setup(servo1_pin,PWM_freq,0)
        pwm.setup(led_pin,PWM_freq,0)
        pwm.setduty(led_pin,800)
        pwm.setduty(servo1_pin,servo_idle)
    end
     
     
    
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID,WIFIPWD)
    wifi.sta.connect()
    -- print("Wifi initalized ",wifi.sta.getmac() .. " " .. SSID)
     
    local errorHandler=function() 
     print("error : " .. error)
    end
    
    local runF = function(name)
      print ("running "..name)
      local f=loadfile(name..".lua")
      pcall(f,errorHandler)
      print("heap: " .. node.heap())
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
    initHW=nil
    print("startup in " .. STARTUP_DELAY/1000)
    tmr.alarm(0,STARTUP_DELAY,0,startup)
end 
