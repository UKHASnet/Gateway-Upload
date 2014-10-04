#!/usr/bin/python2
import serial
import httplib,urllib
import sys

# Callsign of gateway node
gateway_callsign='CHANGEME'
# Should we upload to ukhas.net? Disable for debugging
upload=False

def upload_data( line ):
  params = urllib.urlencode({'origin': gateway_callsign, 'data': line})
  headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
  conn = httplib.HTTPSConnection("www.ukhas.net")
  conn.request("POST", "/api/upload", params, headers)
  response = conn.getresponse()
  data = response.read()
  if(response.status!=200):
    print 'Upload Failed: '+data
  conn.close()
  return

def upload_data_rssi( line, rssi ):
  params = urllib.urlencode({'origin': gateway_callsign, 'data': line, 'rssi': rssi})
  headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
  conn = httplib.HTTPSConnection("www.ukhas.net")
  conn.request("POST", "/api/upload", params, headers)
  response = conn.getresponse()
  data = response.read()
  if(response.status!=200):
    print 'Upload Failed: '+data
  conn.close()
  return

if(gateway_callsign=='CHANGEME'):
    print 'Please set the gateway node callsign'
    print 'Exiting...'
    sys.exit()

node = serial.Serial('/dev/ttyAMA0', 9600, timeout=1)

try:
    while 1:
       try:
        data_line = node.readline().rstrip()
        if(data_line.__len__() > 0):
	    print(data_line)
	    if upload:
	        if "|" in data_line: # Check for RSSI
	            upload_data_rssi(data_line.split("|")[0],data_line.split("|")[1])
	        else:
	            upload_data(data_line)
       except Exception, e:
           continue
except KeyboardInterrupt:
    print "Ctrl+C Detected, quitting.."
    node.close() # Close serial port
    sys.exit()
