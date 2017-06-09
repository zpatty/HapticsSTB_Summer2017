from __future__ import division
#!/usr/bin/env python

## BEFORE RUNNING ON NEW COMPUTER
# Install Phidget Libraries: http://www.phidgets.com/docs/OS_-_Linux#Getting_Started_with_Linux
# Install Phidget Python libraries: http://www.phidgets.com/docs/Language_-_Python#Linux
# Test Phidget with demo code: http://www.phidgets.com/downloads/examples/Python.zip
# Make sure it works with demo code, this code is pretty basic

# Phidget Python API reference: http://www.phidgets.com/documentation/web/PythonDoc/Phidgets.html

import csv #Module - importing/exporting to spreadsheets
import argparse #Module - reads user-friendly command line arguements
import glob #Module - finds pathnames matching pattern used in Unix
import time #Module - allows time access and conversions
import os #Module - allows interfacing with underlying operating system
import sys #Module - provides access to some variable maintained by interpreter
import datetime #Module - supplies classes for manipulating dates and times
import termios #Module - provides interface to Unix terminal control facilities
import fcntl #Module for file control and I/O control on file descriptors
import numpy as np #Module for scientific computing 
import hapticsstb #Custom module built for project, see corresponding file

import math 

"""
Lines 29-52 set up the different command line arguments that can be passed when running this file and reads them in
"""
parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter)

parser.add_argument("-s", "--subject", type=str, default='1', help="Subject ID Number")
parser.add_argument("-t", "--task", type=str, default='1', help="Task ID Number")

parser.add_argument("-p", "--plot", type=int, default=0, choices=[1,2,3,4],
                    help=
"""Set sample rate to 500Hz and display line plots for
debugging
    1: F/T graph
    2: Mini40 Channel Voltages
    3: Accelerometer Gs
    4: Single Point Position
""")

parser.add_argument("--sample_rate", type=int, default=3000, help="STB sampling rate (default 3kHz, 500Hz if plotting)")
parser.add_argument("--sample_time", type=int, default=10, help="Length of trial run in sec (overridden if pedal active)")

parser.add_argument("--keyboard", default=False, action="store_true", help="Use keyboard to start and stop trials")
parser.add_argument("--no_pedal", dest="pedal", default=True, action="store_false", help="Don't use pedal to start and stop trials")
parser.add_argument("--no_video", dest="video", default=True, action="store_false", help="Don't record video")
parser.add_argument("--no_write", dest="write", default=True, action="store_false", help="Don't write data to disk")

args = parser.parse_args()


#True if user supplied --keyboard commandline argument
if args.keyboard:
    args.pedal = False 	#Keyboard overrides pedal, sets it to do not use pedal.
    fd = sys.stdin.fileno() #This will be 0
    oldterm = termios.tcgetattr(fd)
    newattr = termios.tcgetattr(fd) #Reading off the port what the current settings are
    newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO #Turns off canonical input and input echo
    termios.tcsetattr(fd, termios.TCSANOW, newattr) #changes the settings of the port now

    oldflags = fcntl.fcntl(fd, fcntl.F_GETFL) #Pulling the file access mode and file status flags for stdin
    fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK) #Setting access mode to nonblock

"""
Method to create directories that will store the data collected

@param subject The subject that the data is being taken on
@param task The task being performed
@param data_dir The directory name that the file should be stored in.
"""
def create_filename(subject, task, data_dir):
    subject_dir = 'Subject'+subject.zfill(3)
    test_filename =  'S' + subject.zfill(3) + 'TrainFB' + task +'_' + time.strftime('%m-%d_%H-%M')
    test_path = data_dir + '/' + subject_dir + '/' + test_filename

    if [] == glob.glob(data_dir):
        print "MAKING " + data_dir
        os.mkdir(data_dir)
    if [] == glob.glob(data_dir + '/' + subject_dir):
        print "MAKING " + subject_dir
        os.mkdir(data_dir + '/' + subject_dir)

    return test_path

from Phidgets.PhidgetException import PhidgetErrorCodes, PhidgetException
from Phidgets.Devices.AdvancedServo import AdvancedServo

#Do Not Make Force_Scale less than 1
FORCE_SCALE  = 1

"""
Defines an error and error message for the phidget as determined by phidget errors
"""
def Error(e):
    try:
        source = e.device
        print("Phidget Error %i: %s" % (source.getSerialNum(), e.eCode, e.description))
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))

# Setup Phidget
servo = AdvancedServo()
servo.setOnErrorhandler(Error)

# Open Phidget
servo.openPhidget()
servo.waitForAttach(500)

# Set Phidget servo parameters
try:
	motor = 0
	servo.setEngaged(0, True)
	servo.setEngaged(1, True)
	servo_min = servo.getPositionMin(motor) + 100
	servo_max = servo.getPositionMin(motor) + 150
	servo_mid = (servo_max - servo_min)/2
	servo.setAcceleration(1, 500)
	servo.setAcceleration(motor, 500) # I just picked these to be smooth, feel free to change
	servo.setVelocityLimit(1, 2000)
	servo.setVelocityLimit(motor, 2000)
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    print("Exiting....")
    exit(1)

# Create sample rate the STB will be running at.
sample_rate = 50 # This works best with low sampling rates

# Call STB's constructer (init)
sensor = hapticsstb.STB(sample_rate, pedal=args.pedal)

#If plots are to be used, set them up.
if args.plot:
   sensor.plot_init(args.plot, 5)

# Preallocate hist vector, use sensor.sample_rate rather than input sample rate
# since sample rate changes if you turn graphing on
if not args.pedal:
    sample_length = sensor.sample_rate*args.sample_time
else:
    sample_time = 1800
    sample_length = sensor.sample_rate*sample_time

sensor_hist = np.zeros((sample_length, 17))

#Prints star separated messages to inform the user of what is going on
print '*'*80
print "Biasing, make sure board is clear"
sensor.bias() # Tares the sensor, make sure that nothing's touching the bordcr
print sensor.bias_vector
print "Done!"
print '*'*80

volt = 3.3

while True: # Runs once if args.pedal is false

	try:


    	# Block until single pedal press if using pedal
		if args.pedal:
		    print "Waiting for Pedal Input"

		    while True:
		        pedal = sensor.pedal() #Call to determine if pedal is pressed
		        if pedal == 1:	#After first pedal press continue with program
		            break
		        elif pedal == 3:	#After third pedal press quit program
		            print "Quitting!"
		            sys.exit()

		#If using keyboard rather than pedal, print a message.
		elif args.keyboard:
		    print "Waiting for Keyboard Input (space to start/stop, q to quit)"

		    while True:
		        try:
		            keypress = sys.stdin.read(1) #Read the first thing that comes into stdin
		            if keypress == ' ':		#If the keypress is a space, continue with program
		                break
		            elif keypress == 'q':	#If keypress is q, quit prgram
		                print "Quitting!"
		                sys.exit()
		        except IOError: pass

		#Creates necessary files if writing data or making a video
		if args.write or args.video:
		    test_filename = create_filename(args.subject, args.task, 'TestData')

		#Sets up video file
		if args.video:
		    video_filename = test_filename + '.avi'
		    sensor.video_init(video_filename)

		else:
		    print "Starting " + str(args.sample_time) + " second trial"

		#Begins sampling
		print '*'*80
		print "Starting Sampling ..."
		sensor.start_sampling()

		#Runs for the time the code is set to go for
		for ii in range(0,sample_length):
			sensor_data = sensor.read_m40() #Forces and torques from STB
			handedness = sensor.read_acc() #Acceleration voltages from STB
			#Magnitude calculated from force
			mag = (sensor_data[0]**2 + sensor_data[1]**2 + sensor_data[2]**2) ** (1/2)
			conv = (5/7) #Arbitrary scaling factor
			#Position of the servo based on the magnitude of the force vector and the conversion factor
			pos = servo_min + (mag * ((servo_max - servo_min)*conv) / FORCE_SCALE)
			#Creates a history of the data
			sensor_hist[ii,:] = np.hstack((sensor.read_data(),[pos,mag]))	
	
			
			if mag > 0.1:	#If the force is signficant
				#hand one
				if handedness[0] < volt:
				# Scale force to +- 30N for whole range of servo
					if pos <= servo_max and pos >= servo_min:
						servo.setPosition(0, pos)
					elif pos > servo_max:
						servo.setPosition(0, servo_max)
					elif pos < servo_min:
						servo.setPosition(0, servo_min)
	
				#hand two
				if handedness[1] < volt:
					if pos <= servo_max and pos >= servo_min:
						servo.setPosition(1, pos)
					elif pos > servo_max:
						servo.setPosition(1, servo_max)
					elif pos < servo_min:
						servo.setPosition(1, servo_min)
				#Both Hands
				if handedness[0] > volt and handedness[1] > volt:
					if pos <= servo_max and pos >= servo_min:
						servo.setPosition(0, pos)
						servo.setPosition(1, pos)
					elif pos > servo_max:
						servo.setPosition(0, servo_max)
						servo.setPosition(1, servo_max)
					elif pos < servo_min:
						servo.setPosition(0, servo_min)
						servo.setPosition(1, servo_min)

			else:
				servo.setPosition(1, servo_min)
				servo.setPosition(0, servo_min)
			#continually update plot if using one
			if args.plot:
				sensor.plot_update()

			#If using a pedal, the second petal press stops the trial
			if args.pedal:
				if sensor.pedal() == 2:
					print "Pedal Break ..."
					print '*'*80
					servo.setPosition(1, servo_min)
					servo.setPosition(0, servo_min)
					break
			#If using the keyboard the second space press stops the trial
			elif args.keyboard:
				try:
					if sys.stdin.read(1) == ' ':
						print "Key Break ..."
						print '*'*80
						servo.setPosition(1, servo_min)
						servo.setPosition(0, servo_min)
						break
				except IOError: pass
		#Time is up and it hasnt been stopped through either other method.
		else:
		    if args.pedal or args.keyboard:
			print "Time Limit Reached! " + str(args.sample_time) + "s limit, adjust in code if needed"
			print '*'*80
       
	except KeyboardInterrupt: # This lets you ctrl-c out of the sampling loop safely, also breaks out of while loop
        	break

	except PhidgetException as e:
		print("Phidget Exception %i: %s" % (e.code, e.details))
		print("Exiting....")
		exit(1)

	except:
		print "Closing Serial Port ..."
		sensor.close() # Need to run this when you're done, stops STB and closes serial port
		servo.closePhidget()
		if args.keyboard:
		    termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
		    fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)
		raise

	print 'Finished Sampling!'

	sensor.stop_sampling()

	#Saves the data to a csv file and notifies the user writing has completed if
	#writing was chosen to be used in the command line.
 	if args.write:
		np.savetxt(test_filename + '.csv', sensor_hist[:(ii+1),0:17], delimiter=",")
		print 'Finished Writing!'

    	print '*'*80

    	if not args.pedal:
		break

servo.setPosition(1, servo_min)
servo.setPosition(0, servo_min)
sensor.close()
servo.closePhidget()

#Sets the serial port to its original settings before running the code
if args.keyboard:
    termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
    fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)
