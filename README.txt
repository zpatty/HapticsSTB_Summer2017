README for Surgical Robotics 
Authors: Zach Patterson, Brett Wolfinger
Contacts: zjp5@pitt.edu bwolfin1@jhu.edu

When downloading to new computer, cython must be installed. Compile the setup.py file using this command on the command line:

	python setup.py build_ext --inplace

this will initialize the cython modules and dependencies that the driver code requires to run.



Driver file: SqueezeSTB.py
Command line arguments (Each flag is followed by the desired value to pass):
	"-s" or "--subject" (Subject ID Number, default: 1)
	"-t" or "--task" (Task ID Number, default: 1)
	"-p" or "--plot" with choices of [1,2,3,4] (default: 0)
		1. Force/Torque Graph
		2. Mini40 Channel Voltages
		3. Accelerometer Gs
		4. Single Point Position of Force
	"--sample_rate" (Smart Task Board sampling rate, default: 3kHz, 500 Hz if plotting)
	"--sample_time" ()
	"--keyboard" (Allows use of keyboard to start and stop. Turning on keyboard turns off the pedal, default : false)
	"--no_pedal" 
	"--no_video"
	"--no_write"

Necessary Support Files: hapticsstb.py, hapticsstb_rt.py

Arduino code:
	STB: HapticsDAQ_FT
	Pedal: PedalController 


OLD STUFF
USE LEGACY BRANCH FOR DATA COLLECTION, THIS CODE IS BETTER, BUT A BIT DIFFERENT

1: Open terminal (ctrl-alt-T or right click in Nautilus and choose "Open in Terminal")
2: Type "./RunSTB -s y -t y" with appropriate task and subject numbers
3: End task using ctrl-c

COMMON ERRORS
-Bias vector is all zeros
	-No power to STB, wiggle connector and try again
-Bias vector is all ~4s
	-Mini40 not plugged in
-Serial Port is busy or unavailable
	-Quit terminal and try again, usually happens after RunSTB crashes and doesn't close ports
	-If during test, usually a plug has fallen out
-NOT ENOUGH DEVICES CONNECTED error message
	-USB connection is missing, check all plugs

cd hapticsdaqteensy/
./RunSTB.py
