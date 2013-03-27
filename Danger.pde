
public class Danger extends GameObject {
  
  Danger (float x, float y, float speed, float heading, float r, String objID){
    super(x, y, speed, heading, r, objID);
    showHistory = SHOW_DANGER_LOCATION_HISTORY;
  }
  
  @Override
  public void render(){

    noStroke();
    if (this.collided){
      this.collided = false;
    }
    fill(200);
    ellipse(x, y, r+r, r+r);
  }

}

// globoal method for setting up starting positions of Danger
public void setupAndPlaceDangers(){
    
  // Training Mode
    if (DIFFICULTY == 0){
      NUMBER_OF_DANGERS = 1;      
    }
    
    // Easy Mode
    if (DIFFICULTY == 1){
        NUMBER_OF_DANGERS = 2;      
    }
    
    // Medium Mode
    if (DIFFICULTY == 2){
        NUMBER_OF_DANGERS = 4;      
    }
    
    // Medium Mode
    if (DIFFICULTY == 3){
        NUMBER_OF_DANGERS = 6;      
    }
    
    // Extreme Mode
    if (DIFFICULTY == 4){
          NUMBER_OF_DANGERS = 10;
    }
  
    for (int i = 1; i<= NUMBER_OF_DANGERS; i++) {
      GameObject gObject = new Danger(random(SCREEN_WIDTH/2 - DANGER_RADIUS, SCREEN_WIDTH/2 + DANGER_RADIUS), random(DANGER_RADIUS,SCREEN_HEIGHT-DANGER_RADIUS), SPEED_DANGER, random(0,360), DANGER_RADIUS, "D" + Integer.toString(i));
      aListGameObject.add(gObject);
    }
}
