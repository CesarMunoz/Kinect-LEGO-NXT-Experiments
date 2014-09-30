  import SimpleOpenNI.*;
  import processing.serial.*;
  import pt.citar.diablu.processing.nxt.*;

  SimpleOpenNI  kinect;
  LegoNXT nxt;
  int skelColorRed;
  int skelColorGreen;
  int skelColorBlue;
  color[]       userClr = new color[]{ color(255,0,0),
                                       color(0,255,0),
                                       color(0,0,255),
                                       color(255,255,0),
                                       color(255,0,255),
                                       color(0,255,255)
                                     };
  PVector com = new PVector();                                   
  PVector com2d = new PVector();
  float rightZ;
  float leftZ;
  int pwr;

  void setup()
  {
    size(640,480);
    
    kinect = new SimpleOpenNI(this);
    if(kinect.isInit() == false)
    {
       println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
       exit();
       return;  
    }
    
    //flip
    //kinect.setMirror(true);
    
    // enable depthMap generation 
    kinect.enableDepth();
     
    // enable skeleton generation for all joints
    kinect.enableUser();
   
    //background(200,0,0);

    stroke(0,0,255);
    strokeWeight(3);
    smooth();
    
    //<-------------------------------------START CONNECTION WITH NXT BRICK
    //println(Serial.list());
    //nxt = new LegoNXT(this, Serial.list()[1]);
    nxt = new LegoNXT(this, "/dev/tty.NXT-DevB");
//    frameRate(10);
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
        stroke(userClr[ (userList[i] - 1) % userClr.length ] );
        drawSkeleton(userList[i]);
      }      
        
      // draw the center of mass
      if(kinect.getCoM(userList[i],com))
      {
  //      kinect.convertRealWorldToProjective(com,com2d);
  //      stroke(100,255,0);
  //      strokeWeight(1);
  //      beginShape(LINES);
  //        vertex(com2d.x,com2d.y - 5);
  //        vertex(com2d.x,com2d.y + 5);
  //
  //        vertex(com2d.x - 5,com2d.y);
  //        vertex(com2d.x + 5,com2d.y);
  //      endShape();
  //      
  //      fill(0,255,100);
  //      text(Integer.toString(userList[i]),com2d.x,com2d.y);
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
    // println("rightHandTorsoDiff: "+rightHandTorsoDiff.z);
    // calculate the distance & directon of difference vector
    // magnitude is length of vector
    //float magnitude = rightHandTorsoDiff.mag();
    //rightHandTorsoDiff.normalize();
    //println("MAG: "+magnitude);`
    
    leftZ = round(abs(leftHandTorsoDiff.z));
    rightZ = round(abs(rightHandTorsoDiff.z));
    println("leftZ: "+leftZ + "   rightZ: "+rightZ);
    
    pwr = round(abs(map(leftZ, 400, 550, 0, 100)));
    //int revPwr = -50;
  }

  void moveVehicle()
  {
    if( leftZ > 400 && rightZ > 400 )
    {
      goForward();
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
    nxt.motorForwardLimit(LegoNXT.MOTOR_A, pwr, 360);
    nxt.motorForwardLimit(LegoNXT.MOTOR_C, pwr, 360);
    println("FORWARD");
  }

  void goReverse()
  {
    nxt.motorForwardLimit(LegoNXT.MOTOR_A, 50, 360);
    nxt.motorForwardLimit(LegoNXT.MOTOR_C, 50, 360);
    println("REVERSE");
  }

  void goLeft()
  {
    //MOTOR A
    // nxt.motorForward(2, -25);
    //MOTOR B
    // nxt.motorForward(1, 25);
    println("<-------------------------------------LEFT");
  }

  void goRight()
  {
    //MOTOR A
    // nxt.motorForward(2, 25);
    //MOTOR B
    // nxt.motorForward(1, -25);
    println("RIGHT------------------------------------->");
  }

  void stopMotors()
  {
  //  nxt.motorHandBrake(1);
  //  nxt.motorHandBrake(2);
    nxt.motorStop(LegoNXT.MOTOR_A);
    nxt.motorStop(LegoNXT.MOTOR_C);
    println("¡¡¡¡¡¡¡¡¡¡STOP¡¡¡¡¡¡¡¡¡¡");
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


  void keyPressed()
  {
    switch(key)
    {
    case ' ':
      kinect.setMirror(!kinect.mirror());
      break;
    }
  }  

