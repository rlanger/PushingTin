public class Airport {
  float centerX, centerY;
  float width, height;
  int planesLanded;
  int planesTotal;
  color c;

  Airport (float centerX, float centerY, float width, float height, color airportColor){
    this.centerX = centerX;
    this.centerY = centerY;
    this.width = width;
    this.height = height;
    this.planesLanded = 0;
    this.planesTotal = NUMBER_OF_PLANES / 2;
    c = airportColor;
  }
  
  public void render(){

//    color baseColor = color (red(c)/3, green(c)/3, blue(c)/3);
//    fill(baseColor);
    stroke(255);
    fill (c); 
    rect(centerX - width/2.0, centerY - height/2.0, width, height);    
  }
  
  public float getMinX(){
    return (centerX - width/2.0);
  }
  
  public float getMinY(){
    return (centerY - height/2.0);
  }
  
  public float getMaxX(){
    return (centerX + width/2.0);
  }
  
  public float getMaxY(){
    return (centerY + height/2.0);
  }

}  


