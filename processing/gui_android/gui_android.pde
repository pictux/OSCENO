/*
  OSCENO OSC Esp9266 Node
  A smart, IoT lighting node controlled by a Processing app compiled as APK.
  
  The protocol choosen is OSC (Open Sound Control).
  The color is choosen by touching the color wheel (based on :
  http://www.openprocessing.org/sketch/85009).
  
  CC BY-SA 
*/

/*
Android Mode ON
 */

import android.os.Bundle;

/*
import ketai.net.wifidirect.*;
 
 import ketai.net.*;
 import ketai.ui.*;
 import apwidgets.*;
 
 KetaiWiFiDirect net;
 */

/*
Android Mode OFF
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

boolean rotate = false;
boolean live = false;

int fingerPosX = 0;
int fingerPosY = 0;

PFont font;

void setup() {
  colorMode(HSB);

  size(displayWidth, displayHeight);

  orientation(PORTRAIT);

  smooth();
  noStroke();
  frameRate(16);

  font = loadFont("GravurCondensed-Bold-48.vlw");
  textFont(font, 32);

  oscP5 = new OscP5(this, 12000);
  //myRemoteLocation = new NetAddress("10.0.55.61", 8888);
  myRemoteLocation = new NetAddress("192.168.4.1", 8888);
}


int s=256;

void draw() {
  background(0);
  //translate(256, 256);
  //colorTriangle(256, s%256);
  translate(width / 2, 320);

  colorTriangle(256, s%256);

  if (live) {
    if (mouseY < 500) {
      fingerPosX = mouseX;
      fingerPosY = mouseY;
    }
  }

  if (rotate) {
    s=s+1;
  }

  if (live || rotate) {
    int c = get(fingerPosX, fingerPosY);
    int red = int(red(c)); 
    int green = int(green(c));
    int blue = int(blue(c)); 
    println(red + " " + green + " " + " " + blue);

    OscMessage myMessage = new OscMessage("/Rgb/ValueInt");

    myMessage.add(red); /* add the RGB components to the osc message */
    myMessage.add(green);
    myMessage.add(blue);

    oscP5.send(myMessage, myRemoteLocation);
  }

  translate(-width / 2, - 320);
  drawMouse();
  drawText();
}

void colorTriangle(float i, int a) {
  if (i > 0) {
    fill((a+256/(2*PI))%256, 256, 256);
    rotate(radians(5.625/4));
    triangle(0, 0, 128*tan(radians(5.625/4)), (width / 2) - (width / 10), -128*tan(radians(5.625/4)), (width / 2) - (width / 10));
    colorTriangle(i-1, a+1);
  }
}

void mousePressed() {
  int tempFingerPosX = mouseX;
  int tempFingerPosY = mouseY;

  //if user touches the area with the word "ESP8266", it will start the rotation of the color wheel; if touched again
  //it will stop the rotation

  //if user touches the area with the word "#osc", it will start the live mode (send continuosly the RGB data); if touched again
  //it will stop the rotation
  
  //otherwise, if touched, it will send the color to the ESP node.

  if (tempFingerPosX > (50) && tempFingerPosX < (width/2 - 50) && tempFingerPosY < 600 && tempFingerPosY > 500) {
    rotate = !rotate;
  } else if (tempFingerPosX > (width/2 + 50) && tempFingerPosX < (width - 50) && tempFingerPosY < 600 && tempFingerPosY > 500) { 
    live = !live;
  } else {
    fingerPosX = tempFingerPosX;
    fingerPosY = tempFingerPosY;

    int c = get(fingerPosX, fingerPosY);
    int red = int(red(c)); 
    int green = int(green(c));
    int blue = int(blue(c));
    println(red + " " + green + " " + " " + blue);
    println(fingerPosX + " " + fingerPosY);

    OscMessage myMessage = new OscMessage("/Rgb/ValueInt");

    myMessage.add(red); /* add the RGB components to the osc message */
    myMessage.add(green);
    myMessage.add(blue);

    oscP5.send(myMessage, myRemoteLocation);
  }
}

void drawMouse() {
  if (fingerPosX != 0 && fingerPosY != 0) {
    //colorMode(RGB);
    stroke(255);
    strokeWeight(5);
    fill(255, 0);
    ellipse(fingerPosX, fingerPosY, 30, 30);
    noStroke();
  }
}

void drawText() {
  //write something useful of a few #hashtags

  stroke(255);
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(font, 52);
  text("#OSCENO", width/2, 50);
  textFont(font, 32);

  if (rotate) {
    text("rotation", 80, 530);
    text("on", 80, 560);
  } else {
    text("#esp8266", 80, 530);
    text("#neopixel", 80, 560);
  }  
  if (live) {
    text("live mode", 400, 530);
    text("on", 400, 560);
  } else {
    text("#osc", 400, 530);
    text("#processing", 400, 560);
  }
  textFont(font, 48);
  text("#MFR15", width/2, 550);
  noStroke();
}
