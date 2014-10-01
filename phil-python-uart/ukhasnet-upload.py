#!/usr/bin/python2
import serial
import httplib,urllib
import re
import sys

# Callsign of gateway node
gateway_callsign='CHANGEME'
# Is RSSI output sent over the UART after the packet? See README.md
rssi=True
# Should we upload to ukhas.net? Disable for debugging
upload=True

def upload_data( line ):
  params = urllib.urlencode({'origin': gateway_callsign, 'data': line})
  headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
  conn = httplib.HTTPSConnection("www.ukhas.net")
  conn.request("POST", "/api/upload", params, headers)
  response = conn.getresponse()
  if(response.status!=200):
    print 'Upload Failed: '+response.read()
  data = response.read()
  conn.close()
  return

def upload_data_rssi( line, rssi ):
  params = urllib.urlencode({'origin': gateway_callsign, 'data': line, 'rssi': rssi})
  headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
  conn = httplib.HTTPSConnection("www.ukhas.net")
  conn.request("POST", "/api/upload", params, headers)
  response = conn.getresponse()
  if(response.status!=200):
    print 'Upload Failed: '+response.read()
  data = response.read()
  conn.close()
  return

if(gateway_callsign=='CHANGEME'):
    print 'Please set the gateway node callsign'
    print 'Exiting...'
    sys.exit()

node = serial.Serial('/dev/ttyAMA0', 9600, timeout=1)

try:
    # Little sanity check to reduce likelihood of debugging info upload
    data_detect = re.compile('\d[a-z].+[[]\w.*[]]')
    rssi_detect = re.compile('RSSI: -[0-9]+')
    temp_data=''
    while 1:
       try:
        data_line = node.readline().rstrip().strip('rx: ').strip('tx: ')
        if(data_line.__len__() > 0):
	    print(data_line)
            m = data_detect.match(data_line)
            if m:
                temp_data = data_line
                if not rssi:
                   if upload: upload_data(temp_data)
            if rssi:
	        if rssi_detect.match(data_line):
                    rssi_value = data_line.rstrip().strip('RSSI: ')
                    if upload: upload_data_rssi(temp_data,rssi_value)
       except Exception, e:
           continue
except KeyboardInterrupt:
    print "Ctrl+C Detected, quitting.."
    node.close() # Close serial port
    sys.exit()
