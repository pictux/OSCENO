/*
  OSCENO OSC Esp9266 Node
  A smart, IoT lighting node controlled by a Processing app compiled as APK.
  The protocol choosen is OSC (Open Sound Control).
  BOM
  - a standard ESP8266 node (here i've used an ESP-01 
  - a NEOPIXEL strip module (8 neopixels on it)
  - a DC voltage converter 
  - a 4xAA battery holder
  The converter is user to power the ESP8266 at 3.3v, meanwhile the 6v of the battery pack is used to
  power the NEOPIXEL module
  
  CC BY-SA
*/

#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCBundle.h>
#include <OSCBoards.h>
#include <NeoPixelBus.h>

#define PIN 2
#define PIXELS 8

const char* ssid     = "your_ssid";
const char* password = "your_password";

//set a static IP for this node (we'll need it later)
IPAddress ip(192, 168, 0, 61);
IPAddress netmask(255, 255, 255, 0);
IPAddress gateway(192, 168, 0, 1);

unsigned int localPort = 8888;
int ledState = LOW;

char packetBuffer[255];

NeoPixelBus strip = NeoPixelBus(PIXELS, PIN);

WiFiUDP udpPort;

void setup() {
  Serial.begin(115200);
  delay(10);

  // We start by connecting to a WiFi network
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  WiFi.config(ip, gateway, netmask);
  udpPort.begin(localPort);

  strip.Begin();

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

int value = 0;

void loop() {
  OSCMsgReceive();
}

void OSCMsgReceive() {
  OSCMessage msgIN;
  int size;
  if ((size = udpPort.parsePacket()) > 0) {
    while (size--)
      msgIN.fill(udpPort.read());
    if (!msgIN.hasError()) {
      msgIN.route("/Rgb/ValueInt", rgbValueInt);
    }
  }
}

void rgbValueInt(OSCMessage &msg, int addrOffset) {
  //this is the callback function used to drive the neopixel following the RBG received

  int rVal = (int) msg.getInt(0);
  int gVal = (int) msg.getInt(1);
  int bVal = (int) msg.getInt(2);

  Serial.println(String(rVal) + " " + String(gVal) + " " + String(bVal));

  for (int i = 0; i < PIXELS; i++) {
    strip.SetPixelColor(i, RgbColor(rVal, gVal, bVal));
  }
  strip.Show();
}
