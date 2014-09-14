Gateway-Upload
==========

A set of scripts for uploading UKHASnet data to the ukhas.net website with a Pi or PC

These scripts are the work of their respective authors, who hold all copyright and retain all rights unless stated otherwise. 

* phil-python-uart
 - Listens on the Pi UART for packets sent from a UKHASnet microcontroller
 - By Phil, craag

 * ukhasnet_ruby.rb 
   - Ruby based script that reads a serial port (using the serialport gem) and uploads strings that begin with rx after stripping the rx: away. Will need to install the serial port library (> gem install serialport) and make sure you've updated the serialport settings and gateway ID name.
