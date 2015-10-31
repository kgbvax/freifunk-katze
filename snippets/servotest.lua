-- PWM frequency 50Hz
PWM_freq = 50
-- IOMap https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#new_gpio_map
servo1_pin=4 -- GPIO2
seek_delay=30000 --usec


pwm.setup(servo1_pin,PWM_freq,0)

--repeat
    for v = 35,150,1 do
      pwm.setduty(servo1_pin,v)
      tmr.delay(wait)
    end
    for v= 150,35,-1 do
      pwm.setduty(servo1_pin,v)
      tmr.delay(wait)
    end
--until false
