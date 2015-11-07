identity="warpkatze-"..node.chipid()
print("id:"..identity)

BROKER="mqtt.kgbvax.net"
-- BROKER="broker.hivemq.com"
BRPORT=1883 -- TCP wihtout TLS
BRUSER=""
BRPWD=""

servo_paw_low=35
servo_paw_high=120
mytopic_out="/warpzone.ms/winkekatze/%winkekatze"  -- 
mytopic="/warpzone.ms/winkekatze/%winkekatze/messages" --

paw_idle_value=0

-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
pwm.setup(4,50,0) -- GPIO2, 50Hz

--move to paw to position 0..99 (0 being top)
function paw(val) 
  local val=servo_paw_low+(servo_paw_high-servo_paw_low)*val/100
  pwm.setduty(4,val)
  tmr.wdclr()
end

function paw_idle()
  paw(paw_idle_value)
  v=0
  b=2/v
end

-- IRC Bridge
-- Subscribed (mid: 1): 0
--Client mosqsub/55267-kgbvx.fri received PUBLISH (d0, q0, r1, m0, '/warpzone/winkekatze2/%ffms/topic', ... (118 bytes))



function intro() 
  say("Ich bin Katze.")
  say("MQTT: ".. BROKER .. " topic:" .. mytopic)
  say(getHelp())
  tmr.alarm(0,2400000,0,intro)
end

function pollConnect()
    local ip =wifi.sta.getip()
    if ip == nil then
       print("waiting for IP")
       tmr.alarm(0,5000,0,pollConnect)
       return
    end
    
    mqtt:connect(BROKER, BRPORT, 0, 
      function(conn) 
        print("connect:")
        -- subscribe topic with qos = 1
        mqtt:subscribe(mytopic,1, 
          function(conn) 
            intro()
          end)
      end)
end


-- initiate the mqtt client and set keepalive timer to 120sec
mqtt = mqtt.Client(identity, 120,BRUSER,BRPWD)

mqtt:on("connect", function(con) 
   print ("connected") 
end)

mqtt:on("offline", function(con) 
   print ("offline")  
   tmr.alarm(0,5000,0,pollConnect) 
end)


pollConnect()

-- build help message 
function getHelp()
  local help = "I can do: "
  for key,value in pairs(actions) do 
    help= help .. "'" .. key .."'" .. " " 
  end   
  return help
end

-- emit string to "user"
function say(what)
  if what == nil then what="nil" end
  print(what)
  mqtt:publish(mytopic_out, what,0,0)
end

--say("Die Katze ist erwacht.")

-- on receive message
mqtt:on("message", function(conn, topic, data)
    if data ~= nil then
      local action=nil
      local actionName=nil
      for key,value in pairs(actions) do --check whether text contains an action
        if data:find(key) ~= nil then
           action=value
           actionName=key
          local sucess,err=pcall(action,data)
         
            say("success is")
            say(success)
          
        end
      end
    end
  end)









