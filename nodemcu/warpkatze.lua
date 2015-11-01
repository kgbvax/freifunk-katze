myname="warpkatze-"..node.chipid()

print(myname)
 
BROKER="broker.mqttdashboard.com"
BRPORT=1883 -- TCP wihtout TLS
BRUSER="total"
BRPWD="egal"


-- PWM frequency 50Hz
PWM_freq = 50
-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
servo1_pin=4 -- GPIO2
seek_delay=30000 --usec
servo_max=35
servo_min=150

pwm.setup(servo1_pin,PWM_freq,0)
mytopic_out="/warpzone.ms/warpkatze/%winkekatze"  -- 
mytopic="/warpzone.ms/warpkatze/%winkekatze/messages" --

 


-- IRC Bridge
-- Subscribed (mid: 1): 0
--Client mosqsub/55267-kgbvx.fri received PUBLISH (d0, q0, r1, m0, '/warpzone/winkekatze2/%ffms/topic', ... (118 bytes))
--Client mosqsub/55267-kgbvx.fri received PUBLISH (d0, q0, r0, m0, '/warpzone/winkekatze2/%ffms/messages', ... (9 bytes))
 

 
-- wait for ip
repeat
   tmr.delay(50000)
   ip =wifi.sta.getip()
until ip ~= nil   
print(ip)


 
-- initiate the mqtt client and set keepalive timer to 120sec
mqtt = mqtt.Client(myname, 120,BRUSER,BRPWD)

mqtt:on("connect", function(con) print ("connected") end)
mqtt:on("offline", function(con) print ("offline") end)

--actions
actions={}
actions.katzup=     function()  pwm.setduty(servo1_pin,servo_max) end
actions.katzdown=   function()  pwm.setduty(servo1_pin,servo_min) end
actions.katzinfo=   function()  sayHelp() end


help = "I can do: "
for key,value in pairs(actions) do help= help .. "'" .. key .."'" .. " " end
print(help)

function sayHelp() 
 say("Die Katze ist wach.")
 say("MQTT: " .. BROKER .. " topic:" .. mytopic)
 -- say("SSID: " .. 
 say(help)
end
        
function say(what)
  mqtt:publish(mytopic_out, what,0,0)
end

-- on receive message
mqtt:on("message", function(conn, topic, data)
  if data ~= nil then
    action=nil
    for key,value in pairs(actions) do --see whether text contains an action
       if data:find(key) ~= nil then
          action=value
          actionName=key
       end
    end
    if action ~= nil then
       action()
       say("I did: " .. actioName)
    else
      -- say("I don't know how to do: " .. "'".. data .. "'. " .. help)
    end
  end
end)

mqtt:connect(BROKER, BRPORT, 0, function(conn) 
  print("connected")
  -- subscribe topic with qos = 0
  mqtt:subscribe(mytopic,0, 
     function(conn) 
       sayInfo()   
     end)
  end)
