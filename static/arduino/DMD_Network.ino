/*--------------------------------------------------------------------------------------
 Includes
 --------------------------------------------------------------------------------------*/
#include <Ethernet.h>
#include <SPI.h>        //SPI.h must be included as DMD is written by SPI (the IDE complains otherwise)
#include <DMD.h>        //
#include <TimerOne.h>   //
#include "Arial_black_16.h"

//Fire up the DMD library as dmd
DMD dmd;

int charPos=0;
int lineNum=0;

#define inputMax 255
char inputString[inputMax];         // a string to hold incoming data
byte inputLength=0;
boolean stringComplete = false;  // whether the string is complete
long mDelay=75;
long timer=-1;

byte mac[] = { 
  0x00, 0xAA, 0xBB, 0xCC, 0xDE, 0x02 };
IPAddress ip(192,168,1, 177);
IPAddress gateway(192,168,1, 254);
IPAddress subnet(255, 255, 255, 0);

EthernetServer server(23);


/*--------------------------------------------------------------------------------------
 Interrupt handler for Timer1 (TimerOne) driven DMD refresh scanning, this gets
 called at the period set in Timer1.initialize();
 --------------------------------------------------------------------------------------*/
void ScanDMD()
{ 
  dmd.scanDisplayBySPI();
}

/*--------------------------------------------------------------------------------------
 setup
 Called by the Arduino architecture before the main loop begins
 --------------------------------------------------------------------------------------*/
void setup(void)
{

  //initialize TimerOne's interrupt/CPU usage used to scan and refresh the display
  Timer1.initialize( 5000 );           //period in microseconds to call ScanDMD. Anything longer than 5000 (5ms) and you can see flicker.
  Timer1.attachInterrupt( ScanDMD );   //attach the Timer1 interrupt to ScanDMD which goes to dmd.scanDisplayBySPI()
  //clear/init the DMD pixels held in RAM
  dmd.clearScreen( true );   //true is normal (all pixels off), false is negative (all pixels on)
  dmd.selectFont(Arial_Black_16);
  //  dmd.selectFont(Arial_14);
  //  dmd.selectFont(System5x7);
  Serial.begin(115200);
  //  Serial.begin(9600);
  Serial.println("Starting");
  // start the Ethernet connection:
  Serial.println("Trying to get an IP address using DHCP");
  if (Ethernet.begin(mac) == 0) {
    Serial.println("Failed to configure Ethernet using DHCP");
    // initialize the ethernet device not using DHCP:
    Ethernet.begin(mac, ip, gateway, subnet);
  }
  // print your local IP address:
  Serial.print("My IP address: ");
  ip = Ethernet.localIP();
  for (byte thisByte = 0; thisByte < 4; thisByte++) {
    // print the value of each byte of the IP address:
    Serial.print(ip[thisByte], DEC);
    Serial.print("."); 
  }
  Serial.println();
  // start listening for clients
  server.begin();

  dmd.drawMarquee("Hello world",11,0);
  timer=millis();
}

/*--------------------------------------------------------------------------------------
 loop
 Arduino architecture main loop
 --------------------------------------------------------------------------------------*/
void loop(void)
{

  // print the string when a newline arrives:
  if (stringComplete) {
    Serial.println(inputString);
    dmd.clearScreen(true);
    if (inputLength>0) {
      dmd.drawMarquee(inputString,inputLength,0);
      //dmd.drawString(1,1,inputString,inputLength,GRAPHICS_NORMAL);
      timer=millis();
    } 
    else {
      timer=-1;
    }
    // clear the string:
    for (byte i=0;i<inputMax;i++) inputString[i] = '\0';
    inputLength = 0;
    stringComplete = false;
  }
  if (timer!=-1 && ((timer+mDelay) <= millis())) {
    dmd.stepMarquee(1);
    timer=millis();
    EthernetClient client = server.available();

    // when the client sends the first byte, say hello:
    if (client) {
      while(client.connected()){
        // read the bytes incoming from the client:
        char thisChar = client.read();
        // if the incoming character is a newline, set a flag
        // so the main loop can do something about it:
        if (thisChar == '\n') {
          stringComplete = true;
          inputString[inputLength]='\0';
          client.stop();
        } 
        else {
          inputString[inputLength++]=thisChar;
        }
      }
    }
  }
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
      inputString[inputLength]='\0';
    } 
    else {
      inputString[inputLength++]=inChar;
      //Serial.print(inChar);
    }
  }
}





