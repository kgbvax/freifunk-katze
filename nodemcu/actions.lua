--actions
actions={}
actions.katzup=     function()  pwm.setduty(servo1_pin,servo_idle) end
actions.katzdown=   function()  pwm.setduty(servo1_pin,servo_min) end
actions.katzshake=  function () 
    for i=1,4 do
        paw(100)
        tmr.delay(70000)
        paw(0)
        tmr.delay(70000)
    end
    paw_idle()
end

actions.katzmosh=   function () 
    for i=1,6 do
        paw(100)
        tmr.delay(290000)
        paw(0)
        tmr.delay(290000)
    end
    paw_idle()
end

actions.katzwave=   function() 
   local v
   for v = 0,100,2 do
      paw(v)
      tmr.delay(19000)
    end
    for v= 100,0,-2 do
      paw(v)
      tmr.delay(19000)
    end
    --i=0/0
end

--actions.katzfn = function (data) 
--    name=data:match("\w(.*)||")
--    print("fn name" .. name)
--    luafn=data:match("||(.*)")
--    print("fn " .. luafn)
--    actions[name]=luafn
--end

 
