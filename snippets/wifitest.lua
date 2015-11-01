wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_N)
wifi.sleeptype(wifi.LIGHT_SLEEP)
wifi.sta.config("Freifunk","")
wifi.sta.connect()

ip = wifi.sta.getip()
print(ip)
    
