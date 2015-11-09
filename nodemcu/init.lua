print("initial heap: "..node.heap())

-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
servo1_pin=4 -- GPIO2
led_pin=1 -- GPIO5
servo_idle=55

--TIMER
--0 init startup, script-mtt connect
--6 auto disable servo
--2 CO2 sensor polling

NET=false -- true if mqtt client connected
MYTOPIC="/warpzone.ms/winkekatze" --base 
BROKER="mqtt.kgbvax.net"
 
do
    local STARTUP_DELAY=25000  --msec
    local SSID="foo" -- "Freifunk" --"foo"
    local WIFIPWD="finetobaccos" --"finetobaccos"
    local PWM_freq = 75 --Hz
    
    local initHW=function() 
        node.setcpufreq(node.CPU160MHZ)
        pwm.setup(servo1_pin,PWM_freq,servo_idle)
        pwm.setup(led_pin,PWM_freq,200)
        pwm.start(servo1_pin)
        pwm.start(led_pin)
        wifi.setmode(wifi.STATION)
        wifi.sta.config(SSID,WIFIPWD)
        wifi.sta.connect() 
    end
     
    
    
    local runF = function(name)
      print ("running "..name)
      local f=loadfile(name..".lc")
      local res,err=pcall(f)
      if res then 
        print(err)
      end
    end
    
    local startup =function() 
        require('actions')  
        require('co2')   
        require('script-mtt') collectgarbage()
        errorHandler=nil
        runF,initHW,startup=nil,nil,nil
    end

    initHW()
    
    print("startup in " .. STARTUP_DELAY/1000)
    tmr.alarm(0,STARTUP_DELAY,0,startup)
end 
