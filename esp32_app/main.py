import utime
import time
from machine import I2C, Pin
import gps
from bluetooth import BLE, UUID, FLAG_WRITE, FLAG_WRITE_NO_RESPONSE
import ujson
from mpu6886 import MPU6886

userId = ""
deviceId = ""
not_paired = True

i2c = I2C(0, scl= Pin(4), sda=Pin(5), freq=400000)
sensor = MPU6886(i2c)

print("MPU6886 id: " + hex(sensor.whoami))

prevVal = sensor.acceleration

try:
    with open("data.json", "r") as f:
        data = ujson.load(f)
        userId = data["userId"]
        deviceId = data["deviceId"]
except OSError:
    print("No saved data found")

def broadcast_bluetooth():
    ble = BLE()
    ble.active(True)

    SERVICE_UUID = UUID("12345678-1234-5678-1234-56789abcdef0")
    CHAR_1_UUID = UUID("12345678-1234-5678-1234-56789abcdef1")
    CHAR_2_UUID = UUID("12345678-1234-5678-1234-56789abcdef2")

  
    service = (
        SERVICE_UUID,
        [(CHAR_1_UUID, FLAG_WRITE | FLAG_WRITE_NO_RESPONSE),
        (CHAR_2_UUID, FLAG_WRITE | FLAG_WRITE_NO_RESPONSE)]
    )


    handles = ble.gatts_register_services([service])[0]

    print("Service registered successfully!")

    def on_write(event, data):
        global userId, deviceId, not_paired

        if event == 3: 
  
            conn_handle, attr_handle = data

            if attr_handle == handles[0]:
                value = ble.gatts_read(handles[0]).decode()
                print("Received String 1:", value)
                userId = value
            elif attr_handle == handles[1]:
                value = ble.gatts_read(handles[1]).decode()
                print("Received String 2:", value)
                deviceId = value
            not_paired = False
            userData = {"userId": userId, "deviceId": deviceId}
            with open("data.json", "w") as f:
                ujson.dump(userData, f)
           


    ble.irq(on_write)

  
    adv_payload = bytearray([
        2, 0x01, 0x06,      
        8, 0x09           
    ]) + b"Tracker" + bytearray([
        3, 0x03, 0x78, 0x12  
    ])
    ble.gap_advertise(500, adv_payload)
    print("BLE Advertising... Ready to receive data.")

led = Pin(6, Pin.OUT)
buttonPin = Pin(7, Pin.IN, Pin.PULL_DOWN)

def interuppt_handler(pin):
    global buttonPin
    current_time = time.ticks_ms()
    while(time.ticks_ms() - current_time < 5000):
        if(buttonPin.value() == 0):
            return
    startPairMode()

def startPairMode():
    broadcast_bluetooth()
    global not_paired
    global led
    current_time = time.ticks_ms()
    while(time.ticks_ms() - current_time < 60000):
        led.value(1)
        time.sleep(0.2)
        led.value(0)
        time.sleep(0.2)
        if(not not_paired):
           break
    not_paired = True

buttonPin.irq(trigger=Pin.IRQ_RISING, handler=interuppt_handler)

gps.initialize_network()
gps.init_gps()

def check_for_gps_updates():
    global prevVal
    acceleration = sensor.acceleration

    for idx,acc in enumerate(prevVal):
        if(abs(acceleration[idx] - acc) > 3):
            print("accelerated")
            gpsData = gps.get_gps()
            led.value(1)
            time.sleep(2)
            led.value(0)
            if(gpsData is not None and len(gpsData) == 2):
                postNewGpsData(gpsData)
            else:
                print("no GPS data retrieved")
            break
    prevVal = acceleration

def postNewGpsData(data):
    global deviceId
    global userId
    try:
        doSend = True
        for value in data:
            num = float(value)
            if num <= 0:
                doSend = False
        if(doSend):
            print("Sending Data")
            gps.post_data(userId, deviceId, data[0], data[1])
    except:
        print("invalid gps data")

while True:
    if (userId != "" and deviceId != ""):
        check_for_gps_updates()
        print(sensor.acceleration)
        utime.sleep_ms(10000)
    utime.sleep_ms(1000)
