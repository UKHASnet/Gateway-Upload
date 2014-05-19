phil-python-uart
==========

This script uses Python 2 to listen on the Pi's UART for messages sent over by the UKHASnet Microcontroller (eg. arduino). The microcontroller code must be set to output the packets over its UART according to the spec below.

This uses the /dev/ttyAMA0 port, at 9600 baud. If you haven't done so already, you'll need to disable the linux console present by default on this port.

Packet
===

The script waits for a packet line to come in, eg:

	rx: 3aT23.4V4.56[EG]

The preceding 'rx: ' will be trimmed off if it exists and the resulting string will have to parse a simple regex to sanity check before uploading.

RSSI
===

RSSI can optionally be sent with each uploaded packet. If this is enabled then the script will wait after receiving a packet line, for a line similar to below:

	RSSI: -30

Would be a value of -30dBm, this will be parsed and uploaded to the server with the packet.
