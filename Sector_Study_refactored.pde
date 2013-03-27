import TUIO.*;
import vialab.simpleMultiTouch.*;
import vialab.simpleMultiTouch.events.*;
import vialab.mouseToTUIO.*;
import java.awt.BorderLayout;
import java.util.*;
//sound library
import ddf.minim.*;

TouchClient client;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// GAME CONSTANTS
//----------------------------------------------------------------

final boolean USING_SMART_TABLE_NOW = false;  //<<<<<<<<<<<<<<<<<<<<<<<<<REMEMBER TO CHANGE this.
final boolean ANIMATE = true;

final boolean PLAY_BG_MUSIC = false;

final float SPEED_DANGER = 0.1;
final float SPEED_PLANE = 0.5;

final float PLANE_RADIUS = 20.0;
final float DANGER_RADIUS = 60.0;

int NUMBER_OF_PLANES =16;
int NUMBER_OF_DANGERS = 10;

final int SCREEN_WIDTH = 1024;
final int SCREEN_HEIGHT = 768;

final int AIRPORT_OFFSET = 60;
final int AIRPORT_WIDTH = 100;
final int AIRPORT_HEIGHT = 200;

final float DANGER_MIN_X = AIRPORT_OFFSET + AIRPORT_WIDTH + DANGER_RADIUS;
final float DANGER_MAX_X = SCREEN_WIDTH - AIRPORT_OFFSET - AIRPORT_WIDTH - DANGER_RADIUS;

final int HISTORY_LENGTH = 75;
final boolean SHOW_PLANE_LOCATION_HISTORY = true;
final boolean SHOW_DANGER_LOCATION_HISTORY = false;
final boolean DEADLY_DANGERS = true;

final boolean SHOW_PLANE_LABELS = true;
final boolean ROTATE_TEXT = true;

final float DIRECTION_SELECTION_DISTANCE = 60;

int DIFFICULTY = 2; // ranges from 0 - 4

final color P1_COLOR = color(0,255,0);
final color P2_COLOR = color(0,255,255);

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Game "Global Variables"
//----------------------------------------------------------------
ArrayList <GameObject> aListGameObject = new ArrayList<GameObject>();
ArrayList <Explosion> aListExplosion = new ArrayList<Explosion>();

Airport Airport_P1;
Airport Airport_P2;

int[] progBarP1;
int[] progBarP2;

PFont fontA;
PFont fontB;
PFont fontC;

int gameState = 0;
// 0 = start screen
// 1 = normal game play
// 2 = game over

float selectedX = -1.0;
float selectedY = -1.0;

Touch [] dragTouches;

PImage bgGame;
PImage bgSplash;
PImage bgGameOver_Good;
PImage bgGameOver_Bad;

//index is touchID -> selected GameObject
Vector <GameObject> touchToObj = new Vector <GameObject>();

//sound stuff
Minim minim;
AudioPlayer soundLanding;
AudioPlayer soundExplosion;
AudioPlayer soundBounce;
AudioPlayer soundTouch;
AudioPlayer soundHeadingChanged;
AudioPlayer soundSplashMusic;


public void setup() {
    size(SCREEN_WIDTH, SCREEN_HEIGHT, P3D);
    //size(displayWidth, displayHeight, P3D);
    this.setLayout(new BorderLayout());
    this.add(new MouseToTUIO(this, true));
    client = new TouchClient(this);
    if (USING_SMART_TABLE_NOW) runTuioServer();
    
    setupFont();
    
    if(USING_SMART_TABLE_NOW){
      // decent ones: 2,6,7,8,9,us
      bgGame = loadImage("data/b9.jpg");
      bgSplash = loadImage("data/b2.jpg");;
      //bgGameOver_Good;
      //bgGameOver_Bad;
    }
    
    setupSounds();
}

public void setupFont(){
      // Font Stuff
    fontA = loadFont("CourierNew36.vlw");
    fontB = loadFont("Arial-Black-80.vlw");
    fontC = loadFont("CourierNewPS-BoldMT-24.vlw");
    textAlign(LEFT);
    // Set the font and its size (in units of pixels)
    textFont(fontA, 15);
  
}

public void setupSounds(){
    //sounds stuff
    minim = new Minim(this);
 
    // this loads mysong.wav from the data folder
    
    //soundMenuSelect = minim.loadFile("data/sounds/terminal_hacked.wav");
    soundSplashMusic = minim.loadFile("data/sounds/fair1939.wav");
    soundLanding = minim.loadFile("data/sounds/Squeeze.wav");
    soundExplosion = minim.loadFile("data/sounds/enemy_FlyingBuzzer_DestroyedExplosion.wav");
    soundBounce = minim.loadFile("data/sounds/bullet_hit_metal_enemy_2.wav");
    soundTouch = minim.loadFile("data/sounds/Pop-5.wav");
    soundHeadingChanged = minim.loadFile("data/sounds/terminal_hacked.wav");
}



public void initializeGamePortion(){
    //dirty hack
    aListGameObject = new ArrayList<GameObject>();
    aListExplosion = new ArrayList<Explosion>();
    
    setupAndPlaceDangers(); // see bottom of Danger Tab
    
    setupAndPlacePlanes(); // see bottom of Planes Tab
    


    
    progBarP1 = new int[NUMBER_OF_PLANES/2];
    progBarP2 = new int[NUMBER_OF_PLANES/2];
    
    Airport_P1 = new Airport(SCREEN_WIDTH - AIRPORT_OFFSET, SCREEN_HEIGHT/2, AIRPORT_WIDTH, AIRPORT_HEIGHT, P1_COLOR);
    Airport_P2 = new Airport(AIRPORT_OFFSET, SCREEN_HEIGHT/2, AIRPORT_WIDTH, AIRPORT_HEIGHT, P2_COLOR);
}

public void drawGrid(){
  stroke(150);
  for (int y = 2; y <= SCREEN_HEIGHT; y+=SCREEN_HEIGHT/9){
      line(0, y, SCREEN_WIDTH, y);    
  }
  for (int x = 3; x <= SCREEN_WIDTH; x+=SCREEN_WIDTH/12){
      line(x, 0, x , SCREEN_HEIGHT);
  }
  stroke(255);
  line(SCREEN_WIDTH/ 2-1, 0, SCREEN_WIDTH/2-1 , SCREEN_HEIGHT);
  line(SCREEN_WIDTH/ 2, 0, SCREEN_WIDTH/2 , SCREEN_HEIGHT);
  line(SCREEN_WIDTH/ 2+1, 0, SCREEN_WIDTH/2+1 , SCREEN_HEIGHT);
}







public void draw() {
   
  if (gameState == 0){
    startScreen();
    if(!soundSplashMusic.isPlaying() && PLAY_BG_MUSIC) soundSplashMusic.loop();
  } 
  else if (gameState == 2){
    gameOverScreen();
    if(!soundSplashMusic.isPlaying() && PLAY_BG_MUSIC) soundSplashMusic.loop();
  }
  
  
  else {
    
    if(soundSplashMusic.isPlaying())soundSplashMusic.pause();
    
    if (USING_SMART_TABLE_NOW) background(bgGame);
    else background(0);
    
    drawGrid();
    
    stroke(255);
    Airport_P1.render();
    Airport_P2.render();
    

//    // object selection
//    /if (mousePressed){
//      selectedX = mouseX;
//      selectedY = mouseY;
//    }else{
//      selectedX = -1.0;
//      selectedY = -1.0;
//    }
    
   
    // Update headings to reflect drag actions
    int i;
    Touch[] touches = client.getTouches();
    for (i = 0; i < touches.length; i++){
      dragDirection(touches[i]);
    }
    
    // Detect collisions with other objects    
    collisionDetection();    
    
    drawProgressBars();
    //removeCollidedPlanes();    
    
    
    int landedCount = 0;
    int explodedCount = 0;
    
    // iterate through all game objects: perform multiple tasks
    for(GameObject gObject : aListGameObject){
      
      if (gObject.landed){
            landedCount ++;
      }
      
      if (gObject.collided){
            explodedCount++;
      }
      
      if(DEADLY_DANGERS){
        if(gObject.collided && gObject.objID.charAt(0)=='P'){
          noFill();
          continue;
        }
      }      
      
      gObject.updateLandedStatus();
      //gObject.updateHeading(selectedX, selectedY);
      //gObject.updateHeadingWithDrag();
      
      if (ANIMATE){ // for debugging
        gObject.step(); // bounce off wall if applicable and change position based on speed and heading
      }
      
      gObject.isSelected(selectedX, selectedY); // this sets the current plane as selected if the point is close enough 
      if (!gObject.landed){
        gObject.render();
        if (gObject.showHistory){
          gObject.recordHistory();
          gObject.playHistory();
        }
        gObject.drawLabel();
      }
    }
    
    //println("Landed: " + landedCount + " Collided: " + explodedCount);
    
    for(Explosion exp : aListExplosion){
      exp.render();
    }
  
    noFill();
  }
  
  if (isGameOver() == true)
  gameState = 2;
    
}


public void dragDirection (Touch t){
   //println("dragDirection ("+t.cursorId+")");
  
  // is touch associated with some object?
    // if yes, update that object's heading using either speed or position of touchpoint
    if (t.cursorId < touchToObj.size()){
      if (touchToObj.get(t.cursorId) != null){
        touchToObj.get(t.cursorId).updateHeading(t.x, t.y);
        if(!soundHeadingChanged.isPlaying())soundHeadingChanged.play(0);
      }
    }

}



public void collisionDetection(){
  for(GameObject gObjA : aListGameObject){
    for(GameObject gObjB : aListGameObject){
      gObjA.detectCollision(gObjB);
     
    }
  }
}

public void removeCollidedPlanes(){
  for(GameObject gObjA : aListGameObject){
    if (gObjA.objID.charAt(0)=='P' && gObjA.collided){
      println("plane crashed");
      aListGameObject.remove(gObjA);  
    }
  }
}

public boolean addTouch(Touch t){
  soundTouch.play(0);
  // also used in splash screen
  selectedX = t.x;
  selectedY = t.y;
  return true;
}

public class DragPoint {
  float x, y;
  int cursorId;
  boolean serviced;
  
  DragPoint (float x, float y, int cursorId){
    this.x = x;
    this.y = y;
    this.cursorId = cursorId;
    this.serviced = false;
  }
}

//ArrayList <DragPoint> aListDragPoint = new ArrayList<DragPoint>();


public  boolean updateTouch(Touch t){
  
  println(second() + " update touch: x:" + t.x + " y:" + t.y + " cursor ID:" + t.cursorId );
  
  // HACK: This only determines whether the touch is currently on an object, 
  // not if the touch has passed through an object.
  for(GameObject gObj : aListGameObject){
    if (gObj.objID.charAt(0) =='P'){
      if ( ( (t.x - gObj.x)*(t.x - gObj.x) + (t.y - gObj.y)*(t.y - gObj.y) ) <= (gObj.r*gObj.r) ) {
        // TO DO: set touchToObj
        
          if (t.cursorId < touchToObj.size()){
            if (touchToObj.get(t.cursorId)!=null)
               touchToObj.get(t.cursorId).selected = false;
          }
          if (t.cursorId >= touchToObj.size()){
               touchToObj.setSize(t.cursorId+1);
          }
          touchToObj.set(t.cursorId, gObj);
          gObj.selected = true;
      }
    }
  }
  return true;
  
  
  /*
  DragPoint d = new DragPoint(t.x, t.y, t.cursorId); 
  aListDragPoint.add(d);
  */
 }

public boolean removeTouch(Touch t){
  
  if (t.cursorId < touchToObj.size()){
    if (touchToObj.get(t.cursorId)!=null){
      touchToObj.get(t.cursorId).selected = false; 
      touchToObj.set(t.cursorId, null);
    }
  }
  selectedX = -99.0;
  selectedY = -99.0;
  
  return true;
}

public void addLanded(char player){
  
  println("add l");
  
  if (player=='1'){
    for(int i=0; i<progBarP1.length; i++){
      if (progBarP1[i] == 0){
            progBarP1[i] = 1;
            i = progBarP1.length;
      }
    }
  }
  
  if (player=='2'){
    for(int i=0; i<progBarP2.length; i++){
      if (progBarP2[i] == 0){
            progBarP2[i] = 1;
            i = progBarP1.length;
      }
    }
   }
   
   soundLanding.play(0);
 }

public void addExploded(char player){
  
//    println("add e");
  
  if (player=='1'){
    for(int i=0; i<progBarP1.length; i++){
      if (progBarP1[i] == 0){
            progBarP1[i] = 2;
            i = progBarP1.length;
      }
  }
  }
  
  if (player=='2'){
    for(int i=0; i<progBarP2.length; i++){
      if (progBarP2[i] == 0){
            progBarP2[i] = 2;
            i = progBarP1.length;
      }
    }
  }
  soundExplosion.play(0);

}


//TO DO: Make this function do a thing
public boolean isGameOver(){
  
 if (gameState!=0 && progBarP1[progBarP1.length-1] != 0 && progBarP2[progBarP2.length-1] != 0){
   return true;
 }
 
 return false; 
}

// This name should be changed... to AIRPORT Stuff... this stuff should really be moved to AIRPORT
public void drawProgressBars(){
  
  float barWidth = 20.0;
  
  // Airport P1 (RIGHT)
  fill(200,200,200);
  for (int i = 0; i < progBarP1.length ; i++){
    if (progBarP1[i] == 1){
      fill(P1_COLOR);
    }else if(progBarP1[i] == 2){
      fill(255,0,0);
    }else fill(150,150,150);    
    rect(Airport_P1.getMaxX() - barWidth , Airport_P1.centerY - Airport_P1.height/2.0 + i*(Airport_P1.height/Airport_P1.planesTotal), 20, Airport_P1.height/Airport_P1.planesTotal);
  }
  
  // Airport P2 (LEFT)
  fill(200,200,200);
  for (int i = 0; i < progBarP2.length ; i++){
    if (progBarP2[i] == 1){
      fill(P2_COLOR);
    }else if(progBarP2[i] == 2){
      fill(255,0,0);
    }else fill(150,150,150);    
    rect(Airport_P2.getMinX() , Airport_P2.centerY - Airport_P2.height/2.0 + i*(Airport_P2.height/Airport_P2.planesTotal), 20, Airport_P2.height/Airport_P2.planesTotal);
  }

  
  // ANOTHER DIRTY HACK: Pretty airport lights
  int s = 60;
  
  // Airport_P1 (RIGHT) 
  // front lights
  for (int i = -s; i<=s ; i+=s){
    flashingRect(Airport_P1.centerX - Airport_P1.width/2.0, Airport_P1.centerY+i, false);
  }
  pushMatrix();
  translate(Airport_P1.centerX,Airport_P1.centerY);  // Translate to the center
  rotate(-PI/2);
  flashingRect(- Airport_P1.height/2.0, 0, false);
  flashingRect(+ Airport_P1.height/2.0, 0, true);
  popMatrix();  
  // runway text
  pushMatrix();
  textFont(fontA, 24);
  translate(Airport_P1.centerX,Airport_P1.centerY);  // Translate to the center
  rotate(-PI/2);
  textAlign(CENTER);            
  fill(255);
  text ("P1" , 0,0);
  popMatrix();

  
  // Airport_P2 (LEFT) 
  // front lights
  for (int i = -s; i<=s ; i+=s){
    flashingRect(Airport_P2.centerX + Airport_P2.width/2.0, Airport_P2.centerY+i, true);
  }
  // top and bottom lights
  pushMatrix();
  translate(Airport_P2.centerX,Airport_P2.centerY);  // Translate to the center
  rotate(PI/2);
  flashingRect(- Airport_P2.height/2.0, 0, false);
  flashingRect(+ Airport_P2.height/2.0, 0, true);
  popMatrix();  
  // runway text
  pushMatrix();
  textFont(fontA, 24);
  translate(Airport_P2.centerX,Airport_P2.centerY);  // Translate to the center
  rotate(PI/2);
  textAlign(CENTER);            
  fill(255);
  text ("P2", 0,0);
  popMatrix();



}

public void flashingRect(float x_, float y_, boolean right){
  fill (255,0,0);
  int w = 4;
  int h = 50;
  
  float x = x_ - (w/2);
  float y = y_ - (h/2);
  
  //for (int i = 0; i <= n*spacing; i+=spacing){
    fill(255- (millis()/5 % 255));
      if (right)rect(x - 2*w,y,w,h);
      else rect(x + 2*w,y,w,h);     

    fill(255- ((millis()+250)/ 5 % 255));
      rect(x,y,w,h);
    
    fill(255- ((millis()+500)/ 5 % 255));
      if (right) rect(x + 2*w,y,w,h);        
      else rect (x - 2*w,y,w,h);
    
  //}

}

void startScreen() {
  if (USING_SMART_TABLE_NOW) background (bgSplash);
  else background(0);
    
  textFont(fontC, 24);
  fill(0);
  textAlign(LEFT);
  text ("MSCI 730 Final Project", 202, 102);
  text ("Rebecca Langer, Joseph Shum, Xiaochen Yuan", 202, 132);
  fill(255);
  textAlign(LEFT);
  text ("MSCI 730 Final Project", 200, 100);
  text ("Rebecca Langer, Joseph Shum, Xiaochen Yuan", 200, 130);
  
  
  textFont(fontB, 80);
  fill(0);
  text ("PUSHING TIN", 202, 252);
  fill(255);
  text ("PUSHING TIN", 200, 250);
  textFont(fontA, 24);
  fill(0);
  text ("Select a difficulty:", 202, 327);
  fill(255);
  text ("Select a difficulty:", 200, 325);
  
  float bWidth = 250;
  float bHeight = 50;
  float b1_x = 200 ;
  float b1_y = 350;
  float bSpacing = 10;
  int numberOfButtons = 5;
  
  String [] bText = {"Training", "Easy", "Medium", "Hard", "Extreme"};
  
  for (int i = 0; i < numberOfButtons; i++){
    button(b1_x, b1_y + i* (bHeight + bSpacing), bWidth, bHeight, bText[i]);
    if (client.getTouches().length > 0 &&
          (selectedX > b1_x && selectedX < b1_x + bWidth) &&
          (selectedY > b1_y + i * (bHeight + bSpacing) && selectedY < b1_y + i * (bHeight + bSpacing) + bHeight)
          )
    {
        DIFFICULTY = i;
        initializeGamePortion();
        textFont(fontA, 15);
        gameState = 1;
    } 
  }
}

void button(float x, float y, float width, float height, String bText){
  noStroke();
  fill(175);
  rect(x + 5, y + 5, width, height);
  fill(255);
  rect(x, y, width, height);

  textFont(fontA, 24);
  textAlign(CENTER);
  fill(0);
  text(bText, x + width /2, y + height/2 + 5);
}


void gameOverScreen() {
  background (0);
  
  //Lazy hack to get do 2 screens
  
  line(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT);
  
  for (int k=0; k<=1; k++){
  
    pushMatrix();
    translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    if (k == 0) {
      rotate(PI/2);
      translate(-325,0);
    }
    else if (k==1){
      rotate(-PI/2);
      translate(-325,0);
    }
    
      
    textFont(fontA, 24);
    fill(255);
  
    text ("Game Over", 200, 200);
   
    float barWidth = 20.0;
    stroke (255);
    
    int survivors = 0;
  
    // Airport P1 (RIGHT)
    fill(200,200,200);
    for (int i = 0; i < progBarP1.length ; i++){
      if (progBarP1[i] == 1){
        fill(P1_COLOR);
        survivors++;
      }else if(progBarP1[i] == 2){
        fill(255,0,0);
      }else fill(150,150,150);    
      rect(200 + i*(Airport_P1.height/Airport_P1.planesTotal), 230, Airport_P1.height/Airport_P1.planesTotal, 20);
    }
    
    // Airport P2 (LEFT)
    fill(200,200,200);
    for (int i = 0; i < progBarP2.length ; i++){
      if (progBarP2[i] == 1){
        fill(P2_COLOR);
        survivors++;
      }else if(progBarP2[i] == 2){
        fill(255,0,0);
      }else fill(150,150,150);    
      rect(200 + i*(Airport_P2.height/Airport_P2.planesTotal), 260, Airport_P2.height/Airport_P2.planesTotal, 20);
    }  
    
    fill(255);
    textAlign(LEFT);
    textFont(fontA, 15);
  
    text(survivors +" out of " + NUMBER_OF_PLANES + " planes survived.", 200, 310);
    
    popMatrix();
    
  }
  
  //Becca, why is this here?
  if (client.getTouches().length > 0){
      textFont(fontA, 15);
      gameState = 0;
      initializeGamePortion();
  }
  
}



void runTuioServer() {
  final String tuioServerCommand = "D:\\Hancock\\Touch2Tuio\\Release\\Touch2Tuio.exe " + this.frame.getTitle();

  Thread serverThread = new Thread() {

    public void run() {
      while (true) {
        try {
          Process tuioServer = Runtime.getRuntime().exec(tuioServerCommand);
          tuioServer.waitFor();
        } 
        catch (Exception e) {
          System.err.println("TUIO Server stopped!");
        }
      }
    }
  };
  serverThread.start();
}

//sound stuff
void stop()
{
  //sound stuff
  soundSplashMusic.close();
  soundLanding.close();
  soundExplosion.close();
  soundBounce.close();
  soundTouch.close();
  soundHeadingChanged.close();
  minim.stop();
  super.stop();
}
