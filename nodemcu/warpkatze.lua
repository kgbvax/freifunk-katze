myname="atomic-winkekatze-"..node.chipid()

print(myname)
 
-- BROKER="broker.mqttdashboard.com"
BROKER="m2m.eclipse.org"
-- BROKER="broker.hivemq.com"
BRPORT=1883 -- TCP wihtout TLS
BRUSER=""
BRPWD=""


-- PWM frequency 50Hz
PWM_freq = 50
-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
servo1_pin=4 -- GPIO2
seek_delay=30000 --usec
servo_max=35
servo_min=120
servo_idle=55
pwm.setup(servo1_pin,PWM_freq,0)

mytopic_out="/warpzone.ms/winkekatze/%winkekatze"  -- 
mytopic="/warpzone.ms/winkekatze/%winkekatze/messages" --



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


function shake() 
    for i=1,4 do
        pwm.setduty(servo1_pin,servo_max)
        tmr.delay(70000)
        pwm.setduty(servo1_pin,servo_min)
        tmr.delay(70000)
    end
    pwm.setduty(servo1_pin,servo_idle)
end

function mosh() 
    for i=1,6 do
        pwm.setduty(servo1_pin,servo_max)
        tmr.delay(290000)
        pwm.setduty(servo1_pin,servo_min)
        tmr.delay(290000)
    end
    pwm.setduty(servo1_pin,servo_idle)
end
--actions
actions={}
actions.katzup=     function()  pwm.setduty(servo1_pin,servo_idle) end
actions.katzdown=   function()  pwm.setduty(servo1_pin,servo_min) end
actions.katzshake=   shake
actions.katzmosh=    mosh
actions.katzreboot = function() say("Deine Mudder!") end
actions.katzwave=   function() 
   for v = 50,110,1 do
      pwm.setduty(servo1_pin,v)
      tmr.delay(17000)
    end
    for v= 110,50,-1 do
      pwm.setduty(servo1_pin,v)
      tmr.delay(17000)
    end

end


help = "I can do: "
for key,value in pairs(actions) do help= help .. "'" .. key .."'" .. " " end
print(help)

function say(what)
  print(what)
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
       say("I did: " .. actionName)
    else
      -- say("I don't know how to do: " .. "'".. data .. "'. " .. help)
    end
  end
end)

mqtt:connect(BROKER, BRPORT, 0, 
  function(conn) 
    print("connect:")
    -- subscribe topic with qos = 0
    mqtt:subscribe(mytopic,0, 
       function(conn) 
         say("Die Katze ist erwacht.")
         intro()
    end)
end)

function intro() 
 say("Ich bin Katze.")
 say("MQTT: ".. BROKER .. " topic:" .. mytopic)
 say(help)
 tmr.alarm(0,1200000,0,startup)
end






