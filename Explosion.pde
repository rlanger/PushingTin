public class Explosion {
  float x, y;
  int state;
  
  Explosion (float explosionX, float explosionY){
    x = explosionX;
    y = explosionY;
    state = 1;
  }
  
  public void render(){
    
    //println ("EXPLODE!");
    
    if (state > 0 && state < 100){
     float alpha = 255 - (255 * state/100);
     fill (255, 0, 0, alpha);
     ellipse(x, y, PLANE_RADIUS*2 + state, PLANE_RADIUS*2 + state); 
     state = state + 4;
    }
     
    if (state >= 100){
       state = 0;
    }
    // TO DO: Remove Explosion from aListExplosion
    
  }
  
  
}
