identity="atomic-winkekatze-"..node.chipid()

print("id:"..identity)
 
-- BROKER="broker.mqttdashboard.com"
-- BROKER="m2m.eclipse.org"
BROKER="mqtt.kgbvax.net"
-- BROKER="broker.hivemq.com"
BRPORT=1883 -- TCP wihtout TLS
BRUSER=""
BRPWD=""


-- PWM frequency 50Hz
PWM_freq = 50
-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
servo1_pin=4 -- GPIO2
led_pin=1 -- GPIO5

seek_delay=30000 --usec
servo_max=35
servo_min=120
servo_idle=55

pwm.setup(servo1_pin,PWM_freq,0)
--pwm.setup(led_pin,200,500)


mytopic_out=MYTOPIC .. "/%winkekatze"  -- 
mytopic="/warpzone.ms/winkekatze/%winkekatze/messages" --


servo_paw_low=35
servo_paw_high=120
paw_idle_value=0

--move to paw to position 0..99 (0 being top)
function paw(val) 
  local val=servo_paw_low+(servo_paw_high-servo_paw_low)*val/100
  print("v pwm " .. val)
  pwm.setduty(servo1_pin,val)
  tmr.wdclr()
end

function paw_idle()
  paw(paw_idle_value)
end

-- IRC Bridge
-- Subscribed (mid: 1): 0
--Client mosqsub/55267-kgbvx.fri received PUBLISH (d0, q0, r1, m0, '/warpzone/winkekatze2/%ffms/topic', ... (118 bytes))
--Client mosqsub/55267-kgbvx.fri received PUBLISH (d0, q0, r0, m0, '/warpzone/winkekatze2/%ffms/messages', ... (9 bytes))
  
-- wait for ip
function waitForIp()
  local ip 
  repeat
     tmr.delay(10000)
     ip =wifi.sta.getip()
  until ip ~= nil   
  print("ip: "..ip)
end

waitForIp() -- wait for IP 
waitForIp=nil -- and forget the function

-- initiate the mqtt client and set keepalive timer to 120sec
m = mqtt.Client(myname, 120,BRUSER,BRPWD)

m:on("connect", function(con) print ("connected") end)
m:on("offline", function(con) print ("offline") end)

function helpStr() 
  local help = "I can do: "
  for key,value in pairs(actions) do help= help .. "'" .. key .."'" .. " " end
  return help
end


function say(what)
  print(what)
  m:publish(mytopic_out, what,0,0)
end

-- on receive message
m:on("message", function(conn, topic, data)
  if data ~= nil then
    action=nil 
    print (topic)
    for key,value in pairs(actions) do --see whether text contains an action
       if data:find(key) ~= nil then
          action=value
          actionName=key
       end
    end
    if action ~= nil then
       pcall(action,data)
       if error ~= nil then
         say("I did: " .. actionName)
       else
         say(error)
       end
    else
      -- say("I don't know how to do: " .. "'".. data .. "'. " .. help)
    end
  end
end)

m:connect(BROKER, BRPORT, 0, 
  function(conn) 
    print("connect:")
    -- subscribe topic with qos = 0
    m:subscribe(mytopic,0, 
       function(conn) 
         say("Die Katze ist erwacht.")
         intro()
    end)
end)

function intro() 
 say("Ich bin Katze.")
 say("MQTT: ".. BROKER .. " topic:" .. mytopic)
 say(helpStr())
 tmr.alarm(0,2400000,0,intro)
end






