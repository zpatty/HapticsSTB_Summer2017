
// this code monitors for pedal presses from the user. First press starts the system, second press pauses the system, third press ends. 

// thresholds for debouncing presses
#define DOUBLE_TAP_MIN 75
#define DOUBLE_TAP_MAX 200

#define PEDAL_PIN 14
#define LED_PIN 13
#define STATUS_PIN 10
#define STATUS_INT 255

volatile byte pedal_state = 2; // holds the number of the last pedal press
unsigned long start_time; // holds the time of the last press
volatile unsigned long tap_interval = 1000; // holds time since last press
volatile unsigned long last_tap = 0;
volatile boolean third_tap = 0;
byte first = 0;

void setup()
{
	Serial.begin(9600);
	pinMode(LED_PIN, OUTPUT);
	pinMode(PEDAL_PIN, INPUT);
	pinMode(STATUS_PIN, OUTPUT);
	digitalWrite(LED_PIN, pedal_state);
	analogWrite(STATUS_PIN, 0);

}


void loop()
{
  // this loop is ID confirmation with the computer using arbitrary hex values
	if (Serial.available())
	{
		if (Serial.read() == 0x03)
			Serial.write(0x02);
	}
	digitalWrite(LED_PIN, LOW);

	if (pedal_state == 1)
	{
		// analogWrite(STATUS_PIN, 0);
		digitalWrite(STATUS_PIN, LOW);
	}
	else
	{
		// analogWrite(STATUS_PIN, 200);
		digitalWrite(STATUS_PIN, HIGH);
	}

  // while the pedal is not pressed, we transmit 0x02 over the serial port
	while (!digitalRead(PEDAL_PIN))
	{
		if (Serial.available())
		{
			if (Serial.read() == 0x03)
				Serial.write(0x02);
		}
	}
  // when pedal is pressed
	pedal_state = 1; // set state to 1
		digitalWrite(LED_PIN, HIGH); // turn on LEDs
	delay(DOUBLE_TAP_MIN); // delay by the debouncing threshold
	while (digitalRead(PEDAL_PIN)); // loop until pedal is released
	digitalWrite(LED_PIN, LOW); // turn off LEDs

	start_time = millis(); // stores the time of the press
	tap_interval = 0;

  // because we set tap_interval to 0 above, we will always enter this loop
	while (tap_interval <= DOUBLE_TAP_MAX)
	{	

    // if the pedal is pressed and the tap interval is greater than the min threshold
		if(digitalRead(PEDAL_PIN) && (tap_interval >= DOUBLE_TAP_MIN))
		{
			pedal_state += 1; // add 1 to the pedal state
			delay(DOUBLE_TAP_MIN); 
			while (digitalRead(PEDAL_PIN)); // loop until pedal is released
			start_time = millis(); // set the time of the press

		}
		tap_interval = millis() - start_time; // iterate tap interval
	}

	if (pedal_state > 3)
		pedal_state = 3;

	Serial.write(pedal_state);
}
