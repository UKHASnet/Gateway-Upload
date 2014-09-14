# Ruby based parser for uploading to UKHASnet
# Jcoxon@googlemail.com
# Reads either a serial port
#
# Need to install the serialport ruby gem (you might need sudo):
#  > gem install serialport
#
# Also need to change the serial port (port_str) to your device
# as well as the gateway node ID

require 'serialport'
require "uri"
require "net/http"
uri = URI.parse('http://ukhas.net/api/upload')
req = Net::HTTP::Post.new('http://ukhas.net/api/upload')

gateway_ID = 'SR0'
port_str="/dev/tty.usbmodem1a21"

baud_rate=9600
data_bits=8
stop_bits=1
parity=SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

#just read forever
while true do
    sp_char = sp.readline
        if sp_char
            if sp_char[0..1] == 'rx'
                packet = sp_char[4..-1] #remove the first 4 characters 'r' 'x' ':' ' '
                #Send to UKHASnet
                puts packet
                req.set_form_data({
                                  'origin'    => gateway_ID,
                                  'data' => packet
                                  })
                res = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }
                #puts res #this is the debug from uploading
                sleep 10
            end
		end
end
