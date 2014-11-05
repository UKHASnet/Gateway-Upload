phil-python-uart
==========

This script is designed to be used on Raspberry Pi to listen for messages transferred over the GPIO UART from a Gateway Node. It is compatible with the AVR Gateway code at https://github.com/UKHASnet/UKHASnet_Firmware/tree/master/arduino_gateway

This uses the /dev/ttyAMA0 port, at 9600 baud. To set a Pi up for this, run 'sudo raspi-config' then -> Advanced -> Serial Port and Disable the console. Then reboot. All dependencies are pre-installed on raspbian.

To run the script, use 'python ukhasnet-upload.py'. You can run this as a service or in a screen session.


Packet
======

A packet line should be sent from the node over the UART with a speed of 9600 baud in the following format. All packets should be followed by a newline. Any additional whitespace will be trimmed.

    3aT23.4V4.56[EG]

or

    3aT23.4V4.56[EG]|-30

to submit an optional 'gateway rssi' of -30dBm to the server with the packet.


MIT License - Copyright 2014 Phil Crump
