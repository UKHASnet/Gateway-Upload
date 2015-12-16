
# Ruby based parser for uploading to UKHASnet
# Jcoxon@googlemail.com
# Reads either a serial port
#
# Need to install the serialport ruby gem (you might need sudo):
#  > gem install serialport
#
# Also need to change the serial port (port_str) to your device
# as well as the gateway node ID
#
# Uses inbuilt curses lib and wrapper for GUI

require 'serialport'
require "uri"
require "net/http"
require "curses"
include Curses

#SETTINGS THAT NEED TO BE CHANGED
gateway_ID = 'AB'
port_str="/dev/tty.SLAB_USBtoUART"

class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end 

number = 0

init_screen

table_pos = 10

setpos(0,0)
addstr("UKHASnet Ruby Gateway")
setpos(7,0)
addstr("Boot Time: #{Time.now}")
setpos(1,0)
addstr("***********************************************")
setpos(9,0)
addstr("Data from packets received by gateway")
setpos(table_pos,0)
addstr("Nodes  |")
setpos(table_pos,10)
addstr("RSSI   |")
setpos(table_pos,20)
addstr("Seconds|")
setpos(table_pos,30)
addstr("Packets|")
setpos(table_pos,40)
addstr("% Rx |")
refresh

uri = URI.parse('http://ukhas.net/api/upload')
req = Net::HTTP::Post.new('http://ukhas.net/api/upload')

complete_id = [gateway_ID]
rssi_array = [0]
time_array = [0]
packet_array = [0]

baud_rate=115200
data_bits=8
stop_bits=1
parity=SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
#sp.read_timeout = 10000

#just read forever
while true do
    setpos(1,0)
    addstr("***#{Time.now}")
    sp_char = sp.readline
        if sp_char
#            puts sp_char
            if sp_char[0..1] == 'rx'
                packet = sp_char[4..-1] #remove the first 4 characters 'r' 'x' ':' ' '
                #sp.flush_input
		
                #check packet is real (ensure first position of packet is a number
                if packet[0].numeric?
                    sections = packet.chomp.split('|')
                    rx_rssi = sections.last
                    packet_data = sections.first		
                    
                    #Extract IDs
                    parts = packet_data.chop.split('[')
                    path = parts.last
                    id = path.split(',')

                    #Curses section
                    setpos(1,0)
                    addstr("***#{Time.now}")
                    number = number + 1
                    setpos(2,0)
                    clrtoeol
                    addstr("Total Rx: #{number}")
                    setpos(3,0)
                    clrtoeol
                    addstr("Packet: #{packet_data}")
                    setpos(4,0)
                    clrtoeol
                    addstr("RSSI: #{rx_rssi}")
                    setpos(5,0)
                    clrtoeol
                    addstr("Path: #{id}")
                    
                    #Compare arrays and remove duplicates
                    complete_id = complete_id | id

                    result = complete_id.index(id.last)
                    rssi_array[result] = rx_rssi.to_i
                    time_array[result] = Time.now
                    
                    if packet_array[result].inspect.to_i > 0
                        packet_array[result] +=1
                    else
                        packet_array[result] = 1
                    end
                    
                    complete_id.each_index do |index|
                        setpos(index+table_pos + 1,0)
                        clrtoeol
                        addstr("#{complete_id[index].inspect}")
                        setpos(index+table_pos + 1,10) 
                        addstr("#{rssi_array[index].inspect}")
                        setpos(index+table_pos + 1,20)
                        if index == 0
                            addstr("-")
                        else
                            addstr("#{Time.now.to_i - time_array[index].to_i}")
                        end
                        setpos(index+table_pos + 1,30)
                        addstr("#{packet_array[index]}")
                    end
                    
                    refresh

                    #Send to UKHASnet
                    req = Net::HTTP::Post.new(uri)
		    req.set_form_data({
                                      'origin'    => gateway_ID,
                                      'data' => packet_data,
                                      'rssi' => rx_rssi
                                      })
	            #res = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }
                    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  			http.request(req)
		    end    
		   # puts res #this is the debug from uploading
                    sleep 1
                end
            end
        end
end
