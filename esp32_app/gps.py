from machine import UART
import time
import utime

uart = UART(1, baudrate=115200, tx=21, rx=20)
            
def send_at(cmd, timeout=500):
    message = cmd + "\r\n"
    response = b""
    current_time = time.ticks_ms()
    uart.write(message.encode())
    while(time.ticks_ms() - current_time < timeout):
        if uart.any():
            data = uart.read()
            if data:
                response += data
    print(response.strip())
    return response.strip()

def init_gps():
    send_at("ATE0")
    response = send_at("AT")
    while (response != b'OK'):
        print("Attempting to initiate MPU6886")
        send_at("ATE0")
        response = send_at("AT")
    print("MPU6886 initialized")
    return True
        
def get_gps():
    response = send_at("AT+CGNSINF", 3000)
    responseToString = response.decode("utf-8")
    responseToList = responseToString.split(",")
    if(len(responseToList) >= 4):
        print(responseToList[3], responseToList[4])
        return (responseToList[3], responseToList[4])
    
def initialize_network():
    print("Network func start")
    send_at("AT+CPIN?")
    send_at('AT+CSQ')
    send_at('AT+CPSI?')
    send_at("AT+COPS?")
    send_at("AT+CGNSPWR=1")
    # send_at("AT+CNACT=0,0", 1000)
    # send_at("AT+CRESET")
    # send_at("AT+CFUN=1,1")
    print("network func done")
    

def post_data(userId, deviceId, long=1.02, lat=1.03):
    send_at("AT+CFUN=1")
    send_at('AT+CSSLCFG="ignorertctime",1,1')
    send_at('AT+SHSSL=1,""')
    send_at("AT+CNACT=0,1")
    send_at("AT+SHCONF=\"URL\",\"https://postgpsdata-6hc3arpala-uc.a.run.app\"")
    send_at("AT+SHCONF=\"BODYLEN\",1024")
    send_at("AT+SHCONF=\"HEADERLEN\",350")
    send_at("AT+CSSLCFG=\"sslversion\",1,3")
    send_at("AT+SHCONN", 2000)
    send_at("AT+SHSTATE?")
    send_at('AT+SHCHEAD')
    send_at('AT+SHAHEAD="Content-Type","application/json"')
    send_at('AT+SHAHEAD="Cache-control","no-cache"')
    send_at('AT+SHAHEAD="Connection","keep-alive"')
    send_at('AT+SHAHEAD="Accept","*/*"')
    payload = f'{{"userId":"{userId}", "gpsUnitId":"{deviceId}","latitude":"{lat}","longitude":"{long}"}}'
    send_at(f'AT+SHBOD={len(payload)}, 1000', 200)
    send_at(payload)
    send_at("AT+SHREQ=\"/post\", 3")
    send_at("AT+SHDISC")
    send_at("AT+CNACT=0,0")
    send_at("AT+CFUN=0")

def upload_and_convert_ca_certificate():

    try:
        with open("r1.pem", "rb") as cert_file:
            cert_data = cert_file.read()
    except Exception as e:
        print("Error reading certificate file:", e)
        return None

    cert_length = len(cert_data)
    cert_name = "r1.pem"           
    ssl_name  = "r1.pem"          
    dir_index = 3               
    response = send_at("AT+CFSINIT")
    print("CFSINIT response:", response)

    upload_cmd = f'AT+CFSWFILE={dir_index},"{cert_name}",0,{cert_length},1000'
    response = send_at(upload_cmd)
    print("CFSWFILE response:", response)

    if b"DOWNLOAD" not in response:
        print("No DOWNLOAD prompt received. Cannot upload certificate.")
        # Clean up
        send_at("AT+CFSTERM")
        return None
    uart.write(cert_data)
    time.sleep(2) 
    response = send_at("AT+CFSTERM")
    print("CFSTERM response:", response)

    convert_cmd = f'AT+CSSLCFG="convert",2,"{ssl_name}"'
    response = send_at(convert_cmd)
    print("Certificate convert response:", response)

    if b"OK" in response:
        print("Certificate uploaded and converted successfully.")
        return True
    else:
        print("Failed to convert certificate. Check module responses.")
        return False
