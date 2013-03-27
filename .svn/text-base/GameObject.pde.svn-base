public class GameObject {
  float x;
  float y;
  float speed;
  float heading; //heading in degrees
  float r;
  boolean collided;
  boolean selected;
  boolean landed;
  String objID;
  
  boolean showHistory;
  float x_history[] = new float[HISTORY_LENGTH];
  float y_history[] = new float[HISTORY_LENGTH];
  
  // Constructor
  GameObject (float x, float y, float speed, float heading, float r, String objID){
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.heading = heading;
    this.r = r;
    this.collided = false;
    this.objID = objID;
    
    this.showHistory = false; // flag for showing radar trail
    this.selected = false; // flag becomes true if object is selected by user
    this.landed = false;
  }
  
  // this should be a virtual function... to be implemented by child classes
  public void render(){}


  // function to change the position of object  
  public void step(){
    
    // Bounce back from edges
    bounceBack();
    
    while (heading >=360) heading %= 360;
    while (heading < 0) heading += 360;
    
    
    x += speed * sin (radians(heading));
    y += speed * cos (radians(heading));
  }
  
  // function returns true is game object collides with this.
  // also changes the collision flag of the objects involved
  public boolean detectCollision ( GameObject gObj){ 
    if (this.objID == gObj.objID || (this.objID.charAt(0) =='D' && gObj.objID.charAt(0)=='D') || this.landed || gObj.landed )
    { 
      return false;
    }
    
    if (DEADLY_DANGERS && (this.collided || gObj.collided))
    { 
      return false;
    }
    
    else if ( ( (this.x - gObj.x)*(this.x - gObj.x) + (this.y - gObj.y)*(this.y - gObj.y) ) <= (this.r+gObj.r)*(this.r+gObj.r) ) {
          
      this.collided = true;
      gObj.collided = true;
      
      if (DEADLY_DANGERS && this.objID.charAt(0) =='P'){
        aListExplosion.add (new Explosion (this.x, this.y));
        addExploded(this.objID.charAt(1));
        println("EXPLODE");

      }
      if (DEADLY_DANGERS && gObj.objID.charAt(0) =='P'){
        aListExplosion.add (new Explosion (gObj.x, gObj.y));
        addExploded(gObj.objID.charAt(1));
        println("EXPLODE");

      }
      
      //println ("collided: " + this.objID + " " + gObj.objID);
      return true;
    }
    else return false;  
  }

  
  // Virtual function to be implemented by child classes
  public void drawLabel(){}
  
  // Virtual function to be implemented by child classes
  public boolean isSelected(float x, float y){ return false; }
  
  // Virtual function to be implemented by child classes
  public void updateHeading(float x, float y) {}
  
  public void updateHeadingWithDrag(){}
  
  public void updateLandedStatus(){};
  
  public void recordHistory(){};
  
  public void playHistory(){};
  
  
  // Some code taken from http://processing.org/learning/topics/reflection1.html
  public void bounceBack() {
    
      // detect and handle collision (including restricted boundaries for Dangers)
      if ((objID.charAt(0)=='D' && (x-r <= DANGER_MIN_X || x+r >= DANGER_MAX_X)) ||
            y - r < 0 || y + r > SCREEN_HEIGHT || x - r < 0 || x + r > SCREEN_WIDTH){
      // normalized direction vector
      float directionX = sin(radians(heading));
      float directionY = -cos(radians(heading));
      
      // normalized incidence vector
      float incidenceVectorX = -directionX;
      float incidenceVectorY = -directionY;  
      
        float normalX = 0;
        float normalY = 0;
      
        if ( y - r < 0){
          //println("TOP OF SCREEN");
          normalY = -1;
          //soundBounce.play();
        }
        if ( y + r > SCREEN_HEIGHT ){
          //println("BOTTOM OF SCREEN");
          normalY = 1;
          //soundBounce.play();
        }
        if ( x - r < 0 || (objID.charAt(0)=='D' && (x-r <= DANGER_MIN_X))){
          //println("LEFT EDGE");
          normalX = 1;
          //soundBounce.play();
        }
        if ( x + r > SCREEN_WIDTH || (objID.charAt(0)=='D' && (x+r >= DANGER_MAX_X))){
          //println("RIGHT EDGE");
          normalX = -1;
          //soundBounce.play();
        }
        
        // calculate dot product of incident vector and base top normal 
        float dot = incidenceVectorX*normalX + incidenceVectorY*normalY;

        // calculate reflection vector
        float reflectionVectorX = 2*normalX*dot - incidenceVectorX;
        float reflectionVectorY = 2*normalY*dot - incidenceVectorY;

        // assign reflection vector to direction vector
        directionX = reflectionVectorX;
        directionY = reflectionVectorY;
        
        //println("("+directionX+","+directionY+")");
        
        //updateHeading(directionX, directionY);
        float atanAbsXY = atan(abs(directionX)/abs(directionY));
        
        //TO DO: Deal with case where x and/or y is 0
        
        if(directionX>=0 && directionY<=0){
          this.heading = degrees(atanAbsXY);}
        if(directionX>=0 && directionY>=0){
          this.heading = degrees(PI - atanAbsXY);}
        if(directionX<=0 && directionY>=0){
          this.heading = degrees(PI + atanAbsXY);}
        if(directionX<=0 && directionY<=0){
          this.heading = degrees(2*PI - atanAbsXY);}
        
        }
  }
}
