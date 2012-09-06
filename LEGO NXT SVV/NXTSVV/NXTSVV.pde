// NXT Sensor Value Viewer by: Diego Baca, 2007.
// NXTComm library by: Jorge Cardoso, 2007. http://jorgecardoso.org/processing/NXTComm/
// SpringGUI library by: Philipp Seifried, 2005. http://www.repeatwhiletrue.com/SpringGUI/

// Load Libraries:
import processing.serial.*;
import SpringGUI.*;
import pt.citar.diablu.nxt.protocol.*;
import pt.citar.diablu.processing.nxt.*;
import pt.citar.diablu.nxt.brick.*;

SpringGUI gui;
LegoNXT nxt;

PImage nxtImg;
PFont fontA;
PFont fontB;

void setup(){
  size(800,450);
  smooth();
  
  // Load background Image
  nxtImg = loadImage("nxtsvv.jpg");
  
  // Load Fonts
  fontA = loadFont("HelveticaNeue-12.vlw");
  fontB = loadFont("HelveticaNeue-Bold-12.vlw");
  
  // Start connection with LegoNXT brick
  println(Serial.list());
  nxt = new LegoNXT(this, Serial.list()[5]);

  // Create radio buttons
  gui = new SpringGUI(this); 
  gui.addRadiobutton("myRBN1", "On", "motor1", 260, 30, 70, 20); 
  gui.addRadiobutton("myRBN2", "Off", "motor1", 260, 50, 70, 20); 
  gui.addRadiobutton("myRBN3", "On", "motor2", 550, 35, 70, 20); 
  gui.addRadiobutton("myRBN4", "Off", "motor2", 550, 55, 70, 20); 
  gui.addRadiobutton("myRBN5", "On", "motor3", 680, 170, 70, 20); 
  gui.addRadiobutton("myRBN6", "Off", "motor3", 680, 190, 70, 20); 
  gui.setState("myRBN2", true);
  gui.setState("myRBN4", true);
  gui.setState("myRBN6", true);
  gui.setAllBackgrounds(255,255,255); 

  //Start Touch Sensor
  nxt.getButtonState(0);

  //Start Sound Sensor
  nxt.getDB(1);
  
  //Start Light Sensor
  nxt.getLight(2);

  //Start Distance Sensor
  nxt.getDistance(3);

}
void draw(){
  background(nxtImg);

  // Touch sensor state loop
  String touch ="";
  
  if (nxt.getButtonState(0) == true){
    touch = "Pressed";
  }
  if (nxt.getButtonState(0) == false){
    touch = "Released";
  }

  // Print sensor values
  textFont(fontA, 12); 
  fill(0);
  
    text(touch, 60, 205);
    text(nxt.getDB(1), 60, 315);
    text(nxt.getLight(2), 290, 415);
    text(nxt.getDistance(3), 530, 315);
 
  // Lables
  textFont(fontB, 12); 
  fill(0);
  
  text("Motor A", 260, 25);
  text("Motor B", 550, 30);
  text("Motor C", 680, 165);
  
  text("Touch Sensor", 60, 190);
  text("Sound Sensor", 60, 300);
  text("Light Sensor", 290,400);
  text("Ultrasonic Sensor", 530, 300);

}

//Radio buttons controlling Motors A-C:

void handleEvent(String[] parameters) {

  if ( parameters[0].equals("Radiobutton") && parameters[2].equals("selected") ) {
    String selected = gui.getSelectedRadiobutton("motor1"); 

    if (selected.equals("myRBN1")) { 
      //Start Motor A
      nxt.motorForward(0, 100);
    } 
    else if (selected.equals("myRBN2")) { 
      //Stop Motor A
      nxt.motorHandBrake(0);

    }
  }

  if ( parameters[0].equals("Radiobutton") && parameters[2].equals("selected") ) {
    String selected = gui.getSelectedRadiobutton("motor2"); 

    if (selected.equals("myRBN3")) { 
      //Start Motor B
      nxt.motorForward(1, 100);
    } 
    else if (selected.equals("myRBN4")) { 
      //Stop Motor B
      nxt.motorHandBrake(1);

    }
  }

  if ( parameters[0].equals("Radiobutton") && parameters[2].equals("selected") ) {
    String selected = gui.getSelectedRadiobutton("motor3"); 

    if (selected.equals("myRBN5")) { 
      //Start Motor C
      nxt.motorForward(2, 100);
    } 
    else if (selected.equals("myRBN6")) { 
      //Stop Motor C
      nxt.motorHandBrake(2);

    }
  }
}
