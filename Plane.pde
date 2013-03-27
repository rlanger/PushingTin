public class Plane extends GameObject {
  
  color c;
  
  Plane (float x, float y, float speed, float heading, float r, String objID){
    super(x, y, speed, heading, r, objID);
    landed = false;
    collided = false;
    showHistory = SHOW_PLANE_LOCATION_HISTORY;
    if (objID.charAt(1) =='1')
      c = P1_COLOR;
    else
      c = P2_COLOR;
  }
  
  @Override
  public void render(){
    
    if (landed) return;
    
    if (DEADLY_DANGERS){
      if (this.collided){
        return;
      }
    }
    
    if (this.selected){

      int p = 10;
      // always active selection icon around object
      pushMatrix();
      translate (x,y);
      
      float theta;
      
      if (objID.charAt(1) == '1') theta = atan( (SCREEN_HEIGHT/2 - y)/((SCREEN_WIDTH - AIRPORT_OFFSET) - x));
      else theta = atan( (SCREEN_HEIGHT/2 - y)/(AIRPORT_OFFSET - x)) + PI;
      
      rotate(theta);
      //println(theta);
      fill (0,0,200);
      stroke (0,0,255);
      arc(0, 0, 45+p, 45+p, 3*PI/4, 5*PI/4); // back piece
      arc(0, 0, 50+p, 50+p, -PI/4, PI/4); // big piece, direction towards airport
      noFill();
      arc(0, 0, 60+p, 60+p, PI/4, 3*PI/4); //side arc
      arc(0, 0, 70+p, 70+p, -PI/4, PI/4); // towards airport
      arc(0, 0, 60+p, 60+p, 5*PI/4, 7*PI/4); // side arc
      popMatrix();
    }
    
    stroke(0);
    fill (c);
    ellipse(x, y, r+r, r+r);

    if (this.collided){
      //fill (255,0,0);
      //ellipse(x, y, r+r+r+r, r+r+r+r);
      this.collided = false;
    }
    // drawing direction line
    stroke(75);
    if (speed > 0){
      line(x, y, x + speed*50*sin(radians(heading)) , y + speed*50*cos(radians(heading)));
    }
    noStroke();
  }
    
  public void recordHistory(){
    int which = frameCount % HISTORY_LENGTH;
    x_history[which] = x;
    y_history[which] = y;
  }
  
  public void playHistory(){
    int which = frameCount % HISTORY_LENGTH;
    
    fill(0);
    
    color outlineColor;
    
    for (int i = 0; i < HISTORY_LENGTH; i=i+10) {
      
      outlineColor = color (red(c)/5+i*(red(c)/63), green(c)/5+i*(green(c)/63), blue(c)/5+i*(blue(c)/63));
      stroke(outlineColor);
      // stroke(0,50+i*4,0);
      // which+1 is the smallest (the oldest in the array)
      int index = (which+1 + i) % HISTORY_LENGTH;
      //ellipse(x_history[index], y_history[index], i/2, i/2);
      ellipse(x_history[index], y_history[index], r/4, r/4);
    }
    noStroke();
  }
    
  @Override
  public void drawLabel(){
    if (SHOW_PLANE_LABELS){
      fill(175);
      textFont(fontA, 15);
      if (ROTATE_TEXT){
        pushMatrix();
        translate(x,y);  // Translate to the center
        if (x < SCREEN_WIDTH /2){
          rotate(PI/2);
        }else {
          rotate(-PI/2);
        }
        textAlign(LEFT);            
        text (objID, r + 5, r);
        popMatrix();
      }else{
        text (objID,  x + r + 5, y + r);
      }
    }
  }
  
  
  @Override
  public boolean isSelected(float selectedX, float selectedY){
    
    // sometimes x and y is small enough that it would be less than r*r regardless of whether selected is within the radius of the plane
    if ( x > 3 && y > 3 && (selectedX - x)*(selectedX - x) + (selectedY - y) * (selectedY - y) < r*r){
      //println (" x:" + x + " y:" + y + " sX:" + selectedX + " sY:" + selectedY + " r:" +r);
      selected = true;
      return true;  
    }
    return false;
  }
  
  @Override
  public void updateHeading(float selectedX, float selectedY) {
    float distanceBetweenSelectionAndObjectSquared = (selectedX - x)*(selectedX - x) + (selectedY - y) * (selectedY - y);
    if (this.selected  && selectedX > 0 && selectedY > 0
          && (distanceBetweenSelectionAndObjectSquared < (r + DIRECTION_SELECTION_DISTANCE)*(r + DIRECTION_SELECTION_DISTANCE))
          && (distanceBetweenSelectionAndObjectSquared > r*r + DIRECTION_SELECTION_DISTANCE)){
            
      if (selectedY < y && selectedX > x) {
        //println ("1 " + distanceBetweenSelectionAndObjectSquared + " x:" + x + " y:" + y + " sX:" + selectedX + " sY:" + selectedY);
        this.heading = degrees(atan( abs(selectedY - y)/abs(selectedX - x) ) + PI /2 );
      }else if (selectedY < y && selectedX < x) {
        //println ("2 " + distanceBetweenSelectionAndObjectSquared + " x:" + x + " y:" + y + " sX:" + selectedX + " sY:" + selectedY);
        this.heading = degrees(atan( abs(selectedX - x)/abs(selectedY - y) ) + PI );
      }
      // why does this work? is it because there is no negatives?
      else { 
        //println ("3 " + distanceBetweenSelectionAndObjectSquared + " x:" + x + " y:" + y + " sX:" + selectedX + " sY:" + selectedY);
        this.heading = degrees(atan( (selectedX - x)/(selectedY - y) ) );
      }
      this.selected = false;
      
    }
    
  }
  @Override  
  public void updateLandedStatus(){
    
    // Yeah, determining airport is a bit of a hack
    if (objID.charAt(1)=='1'){
      if (x >= Airport_P1.getMinX() && x <= Airport_P1.getMaxX() && y >= Airport_P1.getMinY() && y<=Airport_P1.getMaxY()){
        //Airport_P1.planesLanded++;
        landed = true;
        speed = 0;
        x = -99;
        y = -99;
        println("LAND");
        addLanded('1');

      }
    }else if (objID.charAt(1)=='2'){
      if (x >= Airport_P2.getMinX() && x <= Airport_P2.getMaxX() && y >= Airport_P2.getMinY() && y<=Airport_P2.getMaxY()){
        //Airport_P2.planesLanded++;
        landed = true;
        speed = 0;
        x = -99;
        y = -99;
        addLanded('2');

      }
    } else return;
    
  }
  /*  
  public synchronized void updateHeadingWithDrag(){
    for (DragPoint d: aListDragPoint){
      
      if (d.serviced == false){
        float distanceToPlaneSquared = (d.x - x)*(d.x - x) + (d.y - y) * (d.y - y);
        // really dirty hack
        if (this.selected && distanceToPlaneSquared < 10){
          if (d.y < y && d.x > x) {
            this.heading = degrees(atan( abs(d.y - y)/abs(d.x - x) ) + PI /2 );
          }else if (selectedY < y && selectedX < x) {
            //println ("2 " + distanceBetweenSelectionAndObjectSquared + " x:" + x + " y:" + y + " sX:" + selectedX + " sY:" + d.y);
            this.heading = degrees(atan( abs(d.x - x)/abs(d.y - y) ) + PI );
          }
          // why does this work? is it because there is no negatives?
          else { 
            this.heading = degrees(atan( (d.x - x)/(d.y - y) ) );
          }
          println("New Dragheading:" + heading);
          this.selected = false;
        }
        d.serviced=true;
      }
      
    }    
  }*/
}


// global method to setup and place planes position in the beginning of the game
public void setupAndPlacePlanes(){

    // Randomized starting positions
    // Planes to land at Airport_P1
    /*
    for (int i = 1; i <= NUMBER_OF_PLANES/2; i++){
      GameObject gObject = new Plane(random(60,SCREEN_WIDTH-60), random(60,SCREEN_HEIGHT-60), SPEED_PLANE,0 + i * 20, PLANE_RADIUS, "P1-" + Integer.toString(i));
      aListGameObject.add(gObject);
    }
    // Planes to land at Airport_P2
    for (int i = 1; i <= NUMBER_OF_PLANES/2; i++){
      GameObject gObject = new Plane(random(60,SCREEN_WIDTH-60), random(60,SCREEN_HEIGHT-60), SPEED_PLANE,0 + i * 20, PLANE_RADIUS, "P2-" + Integer.toString(i));
      aListGameObject.add(gObject);
    }
    */
    
    // Training Mode
    /*if (DIFFICULTY == 0){
      NUMBER_OF_PLANES = 2;      
      
      float x_p1 = Airport_P1.getMinX() - 20;
      float x_p2 = Airport_P2.getMaxX() + 20;
      
      GameObject gObject1 = new Plane(x_p2, 200, SPEED_PLANE, 100, PLANE_RADIUS, "P1-1");
      aListGameObject.add(gObject1);

    // Planes to land at Airport_P2
      GameObject gObject2 = new Plane(x_p1, SCREEN_HEIGHT - 200, SPEED_PLANE, 280, PLANE_RADIUS, "P2-1");
      aListGameObject.add(gObject2);

    }*/
    
    // Training Mode
    if (DIFFICULTY == 0){
      NUMBER_OF_PLANES = 2; 
    }
    
    // Easy Mode
    if (DIFFICULTY == 1){
        NUMBER_OF_PLANES = 4;      
    }
    
    // Medium Mode
    if (DIFFICULTY == 2){
        NUMBER_OF_PLANES = 8;
    }
    
    // Hard Mode
    if (DIFFICULTY == 3){
        NUMBER_OF_PLANES = 10;
    }
        
    // Extreme Mode
    if (DIFFICULTY == 4){
        NUMBER_OF_PLANES = 16;
    }
    
    // Standard starting position
    // Planes to land at Airport_P1
    float x_p1 = SCREEN_WIDTH - AIRPORT_OFFSET - AIRPORT_WIDTH - 20;
    float x_p2 = AIRPORT_OFFSET + AIRPORT_WIDTH + 20;
    float v_spacing = (float) SCREEN_HEIGHT / (float)NUMBER_OF_PLANES * 1.8;
    float headingChangeSteps = 200.0 / (float)NUMBER_OF_PLANES * 2.0;
    
    for (int i = 1; i <= NUMBER_OF_PLANES/2; i++){
      GameObject gObject = new Plane(x_p2, i*v_spacing, SPEED_PLANE, 180 - i* headingChangeSteps, PLANE_RADIUS, "P1-" + Integer.toString(i));
      aListGameObject.add(gObject);
    }
    // Planes to land at Airport_P2
    for (int i = 1; i <= NUMBER_OF_PLANES/2; i++){
      GameObject gObject = new Plane(x_p1, SCREEN_HEIGHT - i*v_spacing, SPEED_PLANE, - i* headingChangeSteps, PLANE_RADIUS, "P2-" + Integer.toString(i));
      aListGameObject.add(gObject);
    }
    
}


