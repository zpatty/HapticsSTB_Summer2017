#include <IntervalTimer.h>
#include <SPI.h>


#define RESET 			0x10 // reset signal

//LED Pins
#define LED_1			4 
#define LED_2			3
#define LED_3			6
#define LED_4			5

// Signals for register settings for the accelerometer DAQ
#define SETUP_ACC 		0x64 // Sets the setup register: use internal clock with internally timed sampling ...
// ... external single ended voltage reference with no wake up delay
#define CONV_ACC 		0xC0 // Set conversion register, scan AIN0-8
#define CS_ACC 			7 // Slave select to pin 7 on the microcontroller

// Signals for register settings for the mini40
#define SETUP_FT		0x6B // Sets the setup register: use internal clock with internally timed sampling ...
// ... Use internal reference (always on) with no wake up delay, write to bipolar mode register
#define CONV_FT 		0xD8 // Set conversion register, scan AIN0-11
#define CS_FT			9 // Slave select to pin 9 on the microcontroller

#define SAMPLE_RATE 	2000 // Delay in us between samples

#define SCAN_MODE00 	0x0
#define SCAN_MODE01 	0x1
#define SCAN_MODE10 	0x2
#define SCAN_MODE11 	0x3

#define CLOCK_MODE00 	0x0
#define CLOCK_MODE01 	0x1
#define CLOCK_MODE10 	0x2
#define CLOCK_MODE11 	0x3

#define REF_INT_DELAY 	0x0
#define REF_INT_NODELAY 0x2
#define REF_EXT_SINGLE	0x1
#define REF_EXT_DIFF	0x3

#define SINGLE		0x0
#define UNIPOLAR	0x2
#define BIPOLAR		0x3

#define START 0x01 
#define STOP 0x02
#define PING 0x03

IntervalTimer irq; // initialize irq as interrupt variable


byte convReg(byte channel, byte scan_mode, byte temp)
{
	byte command = 0x80 | (channel << 3) | (scan_mode << 1) | (temp);
	return command;
}

byte setupReg(byte cksel, byte refsel, byte diffsel)
{
	byte command = 0x40 | (cksel << 4) | (refsel << 2) | (diffsel);
	return command;
}

// this function reads data from each DAQ at intervals specified by the user and transmits it back to the computer
void readADC(void)
{
	static byte j = 0; //counts packet "ID" number
	static byte data[31]; // stores the data
	byte i = 0;

	j++;

	Serial.flush();

  // read mini40
	for (i = 0; i < 12; i++)
	{	
		digitalWrite(CS_FT, LOW); // pull Slave select low (active low)
		data[i] = SPI.transfer(0x00); // Send 0x00 - powers up all DAQ registers (sans Setup) - and receives the latest reading
		digitalWrite(CS_FT, HIGH); // deselect slave
		delayMicroseconds(2);
	}

  //same as above for accelerometers
	for (i = 12; i < 30; i++)
	{	
		digitalWrite(CS_ACC, LOW);
		data[i] = SPI.transfer(0x00);
		digitalWrite(CS_ACC, HIGH);
		delayMicroseconds(2);
	}

  // set the last byte of data to be the ID number
	data[30] = j;

	Serial.write(data, 31); // write to USB

  // set conversion registers again
	digitalWrite(CS_FT, LOW);
	SPI.transfer(CONV_FT);
	digitalWrite(CS_FT, HIGH);

	digitalWrite(CS_ACC, LOW);
	SPI.transfer(CONV_ACC);
	digitalWrite(CS_ACC, HIGH);

}
void pulseCS(char pin)
{
	// Pulses the CS line in between SPI bytes (see datasheet for explanation)
	digitalWrite(pin, HIGH);
	delayMicroseconds(2);
	digitalWrite(pin, LOW);
}

// setup routine for the mini40 DAQ
void setupFT(void)
{
	digitalWrite(CS_FT, LOW); //Slave select
	SPI.transfer(RESET); // reset registers
	pulseCS(CS_FT); // pulse slave select
	SPI.transfer(SETUP_FT); // set setup register
	SPI.transfer(0xFF); // set all inputs to bipolar mode
	pulseCS(CS_FT); // pulse again
	SPI.transfer(CONV_FT); // set converstion register
	digitalWrite(CS_FT, HIGH); // slave deselect
}

// for acceleromters, same as above except no need to set bipolar register
void setupACC(void)
{
	digitalWrite(CS_ACC, LOW);
	SPI.transfer(RESET);
	pulseCS(CS_ACC);
	SPI.transfer(SETUP_ACC);
	pulseCS(CS_ACC);
	SPI.transfer(CONV_ACC);
	digitalWrite(CS_ACC, HIGH);
}

// setup function for the microcontroller
void setup(void)
{

	// Turn on LEDS (only LED_4 connected)
	pinMode(LED_1, OUTPUT);
	pinMode(LED_2, OUTPUT);
	pinMode(LED_3, OUTPUT);
	pinMode(LED_4, OUTPUT);
	digitalWrite(LED_1, HIGH);
	digitalWrite(LED_2, HIGH);
	digitalWrite(LED_3, HIGH);
	digitalWrite(LED_4, HIGH);

	// Start USB
	Serial.begin(9600);

	// Declare chip select pins, set to idle high
	pinMode(CS_ACC, OUTPUT);
	pinMode(CS_FT, OUTPUT);
	digitalWrite(CS_ACC, HIGH);
	digitalWrite(CS_FT, HIGH);

	// Start SPI, 8Mhz speed, Defaults to mode 0
	SPI.begin();
	SPI.setClockDivider(SPI_CLOCK_DIV2);
	SPI.setDataMode(SPI_MODE0);
}

// main loop
void loop(void)
{
	byte message[5]; // stores initial reading from computer
	byte sample_rate_buff[2];
	int period;
	byte packet_length; // length of initial reading from computer

	if (Serial.available())
	{
		noInterrupts();
		packet_length = Serial.available(); 

    // loop aggregates the serial reading into a single array
		for (int i = 0; i < packet_length; i++)
		{
			message[i] = Serial.read();
		}
   
		Serial.flush(); // flush serial port

    // loop obtains sample rate set on computer
		if (message[0] == START) // note that START is an arbitrary hex number (0x01)
		{
			if (packet_length > 1)
			{
				period = 1000000/((int)(message[1]<<8) + (int)message[2]); //reconstructs the period (was sent as 2 bytes)
				// delay(1);
			}

			else
			{
				period = SAMPLE_RATE;
			}
			
			// delay(1);
      //setup ADC registers
			setupACC();
			setupFT();
			
			delayMicroseconds(period); 

			irq.begin(readADC, period); // begin sampling at the specified rate
		}

    // end sampling if computer tells us to
		if (message[0] == STOP)
			irq.end();

    // Ping function for device ID confirmation (works with get_device function in hapticsstb.py)
		if (message[0] == PING)
			{
				irq.end();
				Serial.flush();
				Serial.write(0x01);
			}
		
		if (!Serial.dtr())
			irq.end();	
		interrupts()

	}

}
