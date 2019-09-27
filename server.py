import json
import pyvjoy
import socket


def main():
    joystick = pyvjoy.VJoyDevice(1)
    
    host = '0.0.0.0'
    port = 14854
    
    # Create a UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((host, port))
    
    # Continuously read data from the socket
    print('Server setup, connect to ', socket.gethostbyname(socket.gethostname()), ':', port, sep='')
    while True:
        data, addr = sock.recvfrom(1024)
        left, right = json.loads(data.decode())
        
        joystick.set_axis(pyvjoy.HID_USAGE_X, left)
        joystick.set_axis(pyvjoy.HID_USAGE_Y, right)


if __name__ == '__main__':
    main()