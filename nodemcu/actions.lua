



--actions
actions={}
actions.katzup=     function()  pwm.setduty(servo1_pin,servo_idle) end
actions.katzdown=   function()  pwm.setduty(servo1_pin,servo_min) end
actions.katzshake=  function () 
    for i=1,4 do
        pwm.setduty(servo1_pin,servo_max)
        tmr.delay(70000)
        pwm.setduty(servo1_pin,servo_min)
        tmr.delay(70000)
    end
    pwm.setduty(servo1_pin,servo_idle)
end

actions.katzmosh=   function () 
    for i=1,6 do
        pwm.setduty(servo1_pin,servo_max)
        tmr.delay(290000)
        pwm.setduty(servo1_pin,servo_min)
        tmr.delay(290000)
    end
    pwm.setduty(servo1_pin,servo_idle)
end

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

actions.katzfn = function (data) 
    name=data:match("\w(.*)||")
    print("fn name" .. name)
    luafn=data:match("||(.*)")
    print("fn " .. luafn)
    actions[name]=luafn
end

f=actions["katzfn"]
 
f("fooname||barlua")