# carpi 

Custom car infotaintment system using a Raspberri Pi 5 4gb and ESP32-WROVER
Car is an 1986 Ford escort MKIV Convertible

This application is meant to read out data from the car and display that on a screen.
Als creating a [mobile app](https://github.com/JoostKraan/Car-Control-Application) to control car features
## Planned Features

- Turn by turn navigation
- Central locking functionality 
- Throttle Input reading
- electrically controlled windows
- Display status lights in app (high beam, low beam, indicators ETC)
- Media player for controling phone media and playing through radio
- Parking sensors using ultrasonic sensors
- Integrated camera's for dashcam usage / blind spot view
- Car speed reading using hall effect sensor

## Current Features 

- Two temperature read
- Gps location read
- music metadata displayed in app when connected with bluetooth
- Interactable map

## Hardware

- [Raspberri pi 5 4GB](https://core-electronics.com.au/media/catalog/product/cache/d5cf359726a1656c2b36f3682d3bbc67/r/a/raspberry-pi-5-case-red-white-active-cooler.jpg)
- [ESP32-WROVER-B,SIM7000G(LTE,WIFI,BLUETOOTH)](https://m.media-amazon.com/images/I/617l1UeFBVL._AC_UF350,350_QL80_.jpg)
- [Waveshare 7 inch HDMI QLED Display 1024*600](https://www.tinytronics.nl/image/cache/catalog/products_2022/7qp-caplcd-4-600x600.jpg)


### Sensors

- [DFRobot Gravity DS18B20 Temperature Sensor V2](https://www.tinytronics.nl/image/cache/catalog/products/product-003936/dfrobot-gravity-ds18b20-temperature-sensor-front-side-1500x1500.jpg) x 2
- [Hall Effect Switch Module](https://www.tinytronics.nl/image/cache/data/product-757/hall%20effect%20sensor%20module-1500x1500.jpg)
- [RFID NFC Kit PN532](https://www.hackerstore.nl/Afbeeldingen/1606groot.jpg)
- GPS Module (Comes with ESP32)

*will probably change in the future


## Tech

### Software

- [Flutter](https://github.com/flutter/flutter)
- Dart


### Progress Pictures
 <img src="./app/assets/img/screen3.png" alt="Home Page Screenshot" width="800" />
 Serial data from esp32 sensors gets picked up by flutter app and displayed as temperatures and car location
