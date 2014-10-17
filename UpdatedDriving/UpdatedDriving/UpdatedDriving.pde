import SimpleOpenNI.*;
import processing.serial.*;
import pt.citar.diablu.processing.nxt.*;

SimpleOpenNI  kinect;
LegoNXT nxt;
int skelColorRed = 255;
int skelColorGreen = 255;
int skelColorBlue = 255;
PVector com = new PVector();                                   
PVector com2d = new PVector();
float rightZ;
float leftZ;
int pwr;
float moveThreshold = 325;

void setup()
{
  size(640,480);
  
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }else{
      println("init SimpleOpenNI"); 
  }
  
  //flip
  kinect.setMirror(true);
  
  // enable depthMap generation 
  kinect.enableDepth();
   
  // enable skeleton generation for all joints
  kinect.enableUser();
 
  nxt = new LegoNXT(this, "/dev/tty.NXT-DevB");
  frameRate(10);
}

void draw()
{
  // update the cam
  kinect.update();
  
  // draw depthImageMap
  image(kinect.depthImage(),0,0);
//  image(kinect.userImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = kinect.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(kinect.isTrackingSkeleton(userList[i]))
    {
      calculateMotionControls(userList[i]);
      moveVehicle();
//      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      
  }    
}

void calculateMotionControls(int userID)
{
  PVector rightHand = new PVector();
  PVector leftHand = new PVector();
  PVector torso = new PVector();
  
  kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, torso);
  
  PVector rightHandTorsoDiff = PVector.sub(rightHand, torso);
  PVector leftHandTorsoDiff = PVector.sub(leftHand, torso);
  
  leftZ = round(abs(leftHandTorsoDiff.z));
  rightZ = round(abs(rightHandTorsoDiff.z));
//  println("leftZ: "+leftZ + "   rightZ: "+rightZ);
  
  pwr = round(abs(map(leftZ, moveThreshold, 550, 0, 100)));
  println("pwr: "+pwr);
}

void moveVehicle()
{
  if( rightZ > moveThreshold && leftZ < moveThreshold ){ //TURN LEFT
    goLeft();
    setGreen();
  }else if( leftZ > moveThreshold && rightZ < moveThreshold ){ //TURN RIGHT
    goRight();
    setGreen();
  }else if( leftZ>moveThreshold && rightZ>moveThreshold ){ // GO FORWARD
    goForward();
    setGreen();
  }else if( leftZ<=moveThreshold && rightZ<=moveThreshold){ // ALL STOP
    stopMotors();
    setRed();
  }
  
//  if( rightZ < 275 && leftZ < 275 ){
//    goReverse();
//    setYellow();
//  }
}
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
   
  stroke(skelColorRed, skelColorGreen, skelColorBlue);
  strokeWeight(5);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}
// -----------------------------------------------------------------
// DRIVING FUNCTIONS
void goForward()
{
  nxt.motorForward(LegoNXT.MOTOR_A, pwr);
  nxt.motorForward(LegoNXT.MOTOR_C, pwr);
  println("FORWARD");
}

void goReverse()
{
  nxt.motorForwardLimit(LegoNXT.MOTOR_A, 50, 360);
//  nxt.motorForwardLimit(LegoNXT.MOTOR_C, 50, 360);
  println("REVERSE");
}

void goLeft()
{
  //MOTOR A
  nxt.motorForward(LegoNXT.MOTOR_A, -25);
  //MOTOR C
  nxt.motorForward(LegoNXT.MOTOR_C, 25);
  println("<------      LEFT");
}

void goRight()
{
  //MOTOR A
  nxt.motorForward(LegoNXT.MOTOR_A, 25);
  //MOTOR C
  nxt.motorForward(LegoNXT.MOTOR_C, -25);
  println("               RIGHT        --->");
}

void stopMotors()
{
//  nxt.motorHandBrake(1);
//  nxt.motorHandBrake(2);
  nxt.motorHandBrake(LegoNXT.MOTOR_A);
  nxt.motorHandBrake(LegoNXT.MOTOR_C);
//  println("\n\n\n\n\n¡¡¡¡¡¡¡¡¡¡STOP¡¡¡¡¡¡¡¡¡¡\n\n\n\n");
}
// -----------------------------------------------------------------
// Visual Cues
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
// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

/*
void keyPressed()
{
  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  }
}  */

