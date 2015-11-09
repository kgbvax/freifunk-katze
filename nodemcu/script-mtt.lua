
--identity="winkekatze-"..node.chipid()
--print("id:"..identity)
 
do 
  local mytopic_out=MYTOPIC .. "/%winkekatze"  -- 
  local mytopic_msg=MYTOPIC .. "/%winkekatze/messages" --
  local mytopic_eval=MYTOPIC .. "/eval"

  local servo_paw_low=35
  local servo_paw_high=120
  paw_idle_value=0

  --move to paw to position 0..99 (0 being top)
  local function pawval(val) 
    return servo_paw_low+(servo_paw_high-servo_paw_low)*val/100 
  end
  
  function paw(val) 
    pwm.setduty(servo1_pin,pawval(val))
    --tmr.wdclr()
  end

  
  function paw_idle(val)
     if val then paw_idle_value=val  end
     paw(paw_idle_value)
     tmr.alarm(6,500,0,function() --disable PWM after 0,5 sec
        pwm.stop(servo1_pin)
    end)
  end

  function paw_busy()
    tmr.stop(6) -- cancel the auto disable alarm
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
  --udpCon=net.createConnection(net.UDP,0)
  --udpCon:connect(2003,"10.43.0.12")

  local eventConnected=function() 
    NET=true 
    pwm.setduty(led_pin,0) 
    print (">>+") 
  end

  local eventDisconnected=function()
    NET=false 
    pwm.setduty(led_pin,700)
    print (">>-") 
    scheduleConnect()
  end

  -- initiate the mqtt client and set keepalive timer to 60sec
  m = mqtt.Client(myname, 60,"","")
  m:on("connect", eventConnected)
  m:on("offline", eventDisconnected)
 

  function scheduleConnect()
    tmr.alarm(0,1000,0,doConnect)
  end 
  

  function say(what)
    print(what)
    m:publish(mytopic_out, what,0,0)
  end

  local function dispatchAction(topic,data)
    for key,value in pairs(actions) do --see whether text contains an action
      if data:find(key) ~= nil then
        action=value
        actionName=key
      end
    end
    if action ~= nil then
      local res,err = pcall(action,data)
      if res then
        say("I did: " .. actionName)
      else
        say(err)
      end
    end
  end

  local function dispatchEval(topic,data)
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

  function messageDispatcher(conn,topic,data)
     if (topic == mytopic_msg) then
          dispatchAction(topic,data)
     elseif (topic == mytopic_eval) then
          dispatchEval(topic,data)
     end
   end
   
  -- on receive message
  m:on("message",messageDispatcher)

 
  local intro=function() 
    --say("Ich bin Katze.")
    say("MQTT: ".. BROKER .. " topic:" .. mytopic_msg)
    local help = "I can do: "
    if actions then
      for key,value in pairs(actions) do 
        help= help .. "'" .. key .."'" 
      end
      say(help)
    end
    
  end

  function doConnect()
    print("DC")
    m:connect(BROKER, 1883, 0,   
      function(conn) 
        eventConnected()
        -- subscribe topic with qos = 0
        m:subscribe(mytopic_msg,0, 
          function(conn) 
            say("Die Katze ist erwacht.")
            intro()
          end)
        --
      end)
       --m:subscribe(mytopic_eval,0,function() end)  
  end

  scheduleConnect()
end
