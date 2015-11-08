--timer used: 2
-- Münster, November 2015, outdoor 12DegC:  293
ZERO_POINT_VOLTAGE=293

--CO2CURVE = {2.602, }
function sendCO2Value(value)
    if NET then 
      m:publish(MYTOPIC.."/co2adc",value, 0, 0)
    end
    v2= value-200 
    paw(v2)
end

function pollCO2()
  local val=adc.read(0)
  -- print("CO2 ADC read " .. val .." ".. node.heap())
  -- print(m)
  -- todo conversion to ppm
  sendCO2Value(val)
end

tmr.alarm(2,5000,1,pollCO2)
