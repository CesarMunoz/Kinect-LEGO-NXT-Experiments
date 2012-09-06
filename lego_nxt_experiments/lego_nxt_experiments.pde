import pt.citar.diablu.nxt.protocol.*;
import pt.citar.diablu.processing.nxt.*;
import pt.citar.diablu.nxt.brick.*;
import processing.serial.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect;
LegoNXT nxt;
int skelColorRed;
int skelColorGreen;
int skelColorBlue;

//boolean readyToGo = false;

void setup(){
  size(640, 480);
  fill(255, 0, 0);
  
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  //<-------------------------------------START CONNECTION WITH NXT BRICK
  println(Serial.list());
  nxt = new LegoNXT(this, Serial.list()[5]);
}

void draw(){
  kinect.update();
  
  PImage depth = kinect.depthImage();
  image(kinect.depthImage(), 0, 0);
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  
  if(userList.size() > 0){
    int userID = userList.get(0);
    
    if(kinect.isTrackingSkeleton(userID)){
      PVector rightHand = new PVector();
      PVector leftHand = new PVector();
      PVector torso = new PVector();
      
      kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
      kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, torso);
      
      PVector rightHandTorsoDiff = PVector.sub(rightHand, torso);
      PVector leftHandTorsoDiff = PVector.sub(leftHand, torso);
      //println("rightHandTorsoDiff: "+rightHandTorsoDiff.z);
      // calculate the distance & directon of difference vector
      // magnitude is length of vector
      //float magnitude = rightHandTorsoDiff.mag();
      //rightHandTorsoDiff.normalize();
      //println("MAG: "+magnitude);
      
      float leftZ = round(abs(leftHandTorsoDiff.z));
      float rightZ = round(abs(rightHandTorsoDiff.z));
      //println("leftZ: "+leftZ + "   rightZ: "+rightZ);
      
      float pwr = map(leftZ, 400, 550, 0, 100);
      int revPwr = -50;
      
      if( leftZ > 400 && rightZ > 400 ){
        goForward(int(pwr));
        setGreen();
      }else if( leftZ > 275 && leftZ < 400 ){
        stopMotors();
        setRed();
      }else if( rightZ > 275 && rightZ < 400 ){
        stopMotors();
        setRed();
      }/*else if( leftZ > 400 && rightZ < 275 ){
        //goRight();
        setGreen();
      }else if( rightZ > 400 && leftZ < 275 ){
        //goLeft();
        setGreen();
      }else */if( rightZ < 275 && leftZ < 275 ){
        goReverse();
        setYellow();
      } 
      
      drawSkeleton(userID); 
    }
  }
}

//<-------------------------------------DRIVING FUNCTIONS
void goForward(int pwr){
  //MOTOR A
  nxt.motorForward(1, pwr);
  //MOTOR B
  nxt.motorForward(2, pwr);
  println(pwr);
}

void goReverse(){
  //MOTOR A
  nxt.motorForward(1, 50);
  //MOTOR B
  nxt.motorForward(2, 50);
  println("REVERSE");
}

void goLeft(){
  //MOTOR A
  nxt.motorForward(2, -25);
  //MOTOR B
  nxt.motorForward(1, 25);
  println("<-------------------------------------LEFT");
}

void goRight(){
  //MOTOR A
  nxt.motorForward(2, 25);
  //MOTOR B
  nxt.motorForward(1, -25);
  println("RIGHT------------------------------------->");
}

void stopMotors(){
  nxt.motorHandBrake(1);
  nxt.motorHandBrake(2);
  println("STOP!!!!");
}

void setRed()
{
  skelColorRed = 255;
  skelColorGreen = 0;
  skelColorBlue = 0;
}

void setGreen()
{
  skelColorRed = 0;
  skelColorGreen = 255;
  skelColorBlue = 0;
}

void setYellow()
{
  skelColorRed = 255;
  skelColorGreen = 255;
  skelColorBlue = 0;
}

void nxtTone(){
  nxt.playTone(400, 1000);
  //readyToGo = true;
}

void drawSkeleton(int userID)
{
  stroke(skelColorRed, skelColorGreen, skelColorBlue);
  strokeWeight(5);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  
  kinect.drawLimb(userID, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
   
  drawJoint(userID, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userID, SimpleOpenNI.SKEL_NECK);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userID, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userID, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userID, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userID, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userID, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userID, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userID, SimpleOpenNI.SKEL_LEFT_HAND);
}

void drawJoint(int userID, int jointID)
{
  PVector joint = new PVector();
  
  float confidence = kinect.getJointPositionSkeleton(userID, jointID, joint);
  if(confidence < 0.5)
  {
    return;
  }
  
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

//<-------------------------------------USER TRACKING CALLBACKS
void onNewUser(int userID)
{
  println("start pose detection");
  kinect.startPoseDetection("Psi", userID);
}

void onEndCalibration(int userID, boolean successful)
{
  if(successful)
  {
    println("  User calibrated!!!");
    kinect.startTrackingSkeleton(userID);
    nxtTone();
  }else{
    println("  Failed to calibrate user!!!");
    kinect.startPoseDetection("Psi", userID);
  }
}

void onStartPose(String pose, int userID)
{
  println("Started pose for user");
  kinect.stopPoseDetection(userID);
  kinect.requestCalibrationSkeleton(userID, true);
}
