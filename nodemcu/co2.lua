--timer used: 2
-- Münster, November 2015, outdoor 12DegC:  293
do 
    local ZERO_POINT_VOLTAGE=293

    local epochTime = function() 
        local boot = 1447027616;
        return boot+tmr.time()
    end
    
    --CO2CURVE = {2.602, }
    local function sendCO2Value(value)
        if NET then 
          m:publish(MYTOPIC.."/co2adc",value, 0, 0)
         -- local m="test.warpkatze.co2adc " .. tostring(value) .. " " ..tostring(epochTime())
         -- udpCon:send(m)
         -- print(m)
        end
        v2=value-200 
        paw_idle(v2)
    end
    
    local function pollCO2()
      local val=adc.read(0)
      --print("CO2 ADC read " .. val .." ".. node.heap())

      -- todo conversion to ppm
      sendCO2Value(val)
    end

    tmr.alarm(2,5000,1,pollCO2)
end


