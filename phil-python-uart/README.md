phil-python-uart
==========

This script is designed to be used on Raspberry Pi to listen for messages transferred over the GPIO UART from a Gateway Node. It is compatible with the AVR Gateway code at https://github.com/UKHASnet/UKHASnet_Firmware/tree/master/arduino_gateway

This uses the /dev/ttyAMA0 port, at 9600 baud. To set a Pi up for this, run 'sudo raspi-config' then -> Advanced -> Serial Port and Disable the console. Then reboot. All dependencies are pre-installed on raspbian.

To run the script, use 'python ukhasnet-upload.py'. You can run this as a service or in a screen session.


Packet
======

The script waits for a packet line to come in, eg:

	rx: 3aT23.4V4.56[EG]

The preceding 'rx: ' will be trimmed off if it exists and the resulting string will have to pass a simple regex match before uploading. This regex allows debugging statements to be interleaved with the packets, however care should be taken that the debugging messages could not be matched.

RSSI
======

RSSI can optionally be sent with each uploaded packet. If this is enabled then the script will wait after receiving a packet line, for a line that must follow imediately, similar to below:

	RSSI: -30

Would be a value of -30dBm, this will be parsed and uploaded to the server with the packet.


MIT License - Copyright 2014 Phil Crump
