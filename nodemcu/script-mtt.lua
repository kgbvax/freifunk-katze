--timer 5,4
identity="winkekatze-"..node.chipid()
print("id:"..identity)

-- BROKER="m2m.eclipse.org"
BROKER="mqtt.kgbvax.net"


MYTOPIC="/warpzone.ms/winkekatze" --base 
mytopic_out=MYTOPIC .. "/%winkekatze"  -- 
mytopic_msg=MYTOPIC .. "/%winkekatze/messages" --
mytopic_eval=MYTOPIC .. "/eval"


servo_paw_low=35
servo_paw_high=120
paw_idle_value=0


--move to paw to position 0..99 (0 being top)
function paw(val) 
  local val=servo_paw_low+(servo_paw_high-servo_paw_low)*val/100
  --print("v pwm " .. val)
  pwm.setduty(servo1_pin,val)
  --tmr.wdclr()
end

function paw_idle()
  paw(paw_idle_value)
end

function paw_busy()
end


-- IRC Bridge
--Client mosqsub/55267-kgbvx.fri received PUBLISH (d0, q0, r1, m0, '/warpzone/winkekatze2/%ffms/topic', ... (118 bytes))

-- wait for ip
local waitForIp =function()
  local ip 
  repeat
    tmr.delay(10000)
    ip =wifi.sta.getip()
  until ip ~= nil   
  print("ip: "..ip)
end

waitForIp() -- wait for IP 
waitForIp=nil -- and forget the function


local eventConnected=function() 
  NET=true 
  pwm.setduty(led_pin,0) 
  print (">>connected") 
end

local eventDisconnected=function()
  NET=false 
  pwm.setduty(led_pin,700)
  print (">>offline") 
  tmr.alarm(3,1000,0,doConnect)
end

-- initiate the mqtt client and set keepalive timer to 60sec
m = mqtt.Client(myname, 60,"","")
m:on("connect", eventConnected)
m:on("offline", eventDisconnected)

local helpStr=function(act) 
  local help = "I can do: "
  if act then
    for key,value in pairs(act) do 
      help= help .. "'" .. key .."'" .. " " 
    end
    return help
  end
  return "No actn."
end


function say(what)
  print(what)
  m:publish(mytopic_out, what,0,0)
end

-- on receive message
m:on("message", 
function(conn, topic, data)
    if data ~= nil then
      action=nil 
      if (topic == mytopic_msg) then
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
        end
      else if (topic == mytopic_eval) then
        local f,err=loadstring(data)
        if not f then
          say(err)
        else
          local res,err=pcall(f)
          if res then
            say("err:" .. tostring(err))
          end 
        end
      end
    end
  end
end)

local intro=function() 
  --say("Ich bin Katze.")
  say("MQTT: ".. BROKER .. " topic:" .. mytopic_msg)
  say(helpStr(actions))
  -- tmr.alarm(4,24000,0,intro)
end
 

local doConnect= function()
    m:connect(BROKER, 1883, 0,   
      function(conn) 
        eventConnected()
        -- subscribe topic with qos = 0
        m:subscribe(mytopic_msg,0, 
          function(conn) 
            say("Die Katze ist erwacht.")
            intro()
          end)
        m:subscribe(mytopic_eval,0,function() end)
      end) 
end
     

tmr.alarm(3,1000,0,doConnect)
