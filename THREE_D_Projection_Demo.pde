

public class POINT {
    public int x;
    public int y;
    public int z;
    
    POINT(){
     x=0;
     y=0;
     z=0;
    }
    
    POINT(int nx,int ny, int nz){
      x =nx;
      y = ny;
      z = nz;
    }
}


POINT camera;
POINT viewportPlane[] = new POINT[3];

// stuctures for 3d Cube and 2D representation
POINT _3Daxis;

POINT _3Dreal[] = new POINT[8];
POINT _3Dflattened_curr[] = new POINT[8];;
POINT _3Dflattened_prev[] = new POINT[8];;
POINT _3Drotated[] = new POINT[8];

float current_rad = 0.0;
int iteration = 0;

void setup() {
    size(1000,1000);
     noFill();
     stroke(255);
     strokeWeight(2); 
     
    camera =  new POINT(128  ,96  , -100);
    viewportPlane[0] = new POINT(0,   0,   0);
    viewportPlane[1] = new POINT(255, 0,   0);
    viewportPlane[2] = new POINT(0,   191,  0);
    
    // stuctures for 3d Cube and 2D representation
    _3Daxis =  new POINT(128, 96, 128);
    
    _3Dreal[0] = new POINT(98  ,66  ,98 );
    _3Dreal[1] = new POINT(158 ,66  ,98 );
    _3Dreal[2] = new POINT(98  ,126 ,98 );
    _3Dreal[3] = new POINT(158 ,126 ,98 );
    _3Dreal[4] = new POINT(98  ,66  ,158);
    _3Dreal[5] = new POINT(158 ,66  ,158);
    _3Dreal[6] = new POINT(98  ,126 ,158);
    _3Dreal[7] = new POINT(158 ,126 ,158);
                                
    for (int i = 0; i < 8; i++) {
      _3Dflattened_curr[i] = new POINT(0,0,0);
      _3Dflattened_prev[i] = new POINT(0,0,0);
      _3Drotated[i] = new POINT(0,0,0);
    }

}

void keyPressed() {
   print("KEY PRESSED " + key);
    if(key == 'm') camera.x++;
    else if(key == 'n') camera.x--;
    else if(key == 'w') camera.z++;
    else if(key == 's') camera.z--;
    else if (key == 'a') camera.y--;
    else if (key == 'd') camera.y++;
    else if(key == CODED) {
        if(keyCode == UP     ) _3Daxis.y--;
        else if(keyCode == DOWN   ) _3Daxis.y++ ;
        else if(keyCode == LEFT   ) _3Daxis.x++;
        else if(keyCode == RIGHT  ) _3Daxis.x--;
    }
}


void draw() {
  background(0);
  println("ITERATION " + iteration);
  iteration++;
  
  stroke(0);
  // un draw old cube
  drawline(_3Dflattened_prev[0],_3Dflattened_prev[1]);
  drawline(_3Dflattened_prev[2],_3Dflattened_prev[3]);
  drawline(_3Dflattened_prev[4],_3Dflattened_prev[5]);
  drawline(_3Dflattened_prev[6],_3Dflattened_prev[7]);
  drawline(_3Dflattened_prev[7],_3Dflattened_prev[3]);
  drawline(_3Dflattened_prev[6],_3Dflattened_prev[2]);
  drawline(_3Dflattened_prev[5],_3Dflattened_prev[1]);
  drawline(_3Dflattened_prev[0],_3Dflattened_prev[2]);
  drawline(_3Dflattened_prev[1],_3Dflattened_prev[3]);
  drawline(_3Dflattened_prev[4],_3Dflattened_prev[6]);
  drawline(_3Dflattened_prev[5],_3Dflattened_prev[7]);
  drawline(_3Dflattened_prev[0],_3Dflattened_prev[4]);
  stroke(255);
  rect(0, 0, 256, 192);
  update();
  // draw cube
  
  drawline(_3Dflattened_curr[0],_3Dflattened_curr[1]);
  drawline(_3Dflattened_curr[2],_3Dflattened_curr[3]);
  drawline(_3Dflattened_curr[4],_3Dflattened_curr[5]);
  drawline(_3Dflattened_curr[6],_3Dflattened_curr[7]);
  drawline(_3Dflattened_curr[7],_3Dflattened_curr[3]);
  drawline(_3Dflattened_curr[6],_3Dflattened_curr[2]);
  drawline(_3Dflattened_curr[5],_3Dflattened_curr[1]);
  drawline(_3Dflattened_curr[0],_3Dflattened_curr[2]);
  drawline(_3Dflattened_curr[1],_3Dflattened_curr[3]);
  drawline(_3Dflattened_curr[4],_3Dflattened_curr[6]);
  drawline(_3Dflattened_curr[5],_3Dflattened_curr[7]);
  drawline(_3Dflattened_curr[0],_3Dflattened_curr[4]);
  // draw cube top view
  drawTopLine(_3Drotated[0],_3Drotated[1]);
  drawTopLine(_3Drotated[2],_3Drotated[3]);
  drawTopLine(_3Drotated[4],_3Drotated[5]);
  drawTopLine(_3Drotated[6],_3Drotated[7]);
  drawTopLine(_3Drotated[7],_3Drotated[3]);
  drawTopLine(_3Drotated[6],_3Drotated[2]);
  drawTopLine(_3Drotated[5],_3Drotated[1]);
  drawTopLine(_3Drotated[0],_3Drotated[2]);
  drawTopLine(_3Drotated[1],_3Drotated[3]);
  drawTopLine(_3Drotated[4],_3Drotated[6]);
  drawTopLine(_3Drotated[5],_3Drotated[7]);
  drawTopLine(_3Drotated[0],_3Drotated[4]);
  
  // draw viewport
  drawTopLine(viewportPlane[0],viewportPlane[1]);
  drawSideLine(viewportPlane[0],viewportPlane[2]);


  
  // draw cube side view
  drawSideLine(_3Drotated[0],_3Drotated[1]);
  drawSideLine(_3Drotated[2],_3Drotated[3]);
  drawSideLine(_3Drotated[4],_3Drotated[5]);
  drawSideLine(_3Drotated[6],_3Drotated[7]);
  drawSideLine(_3Drotated[7],_3Drotated[3]);
  drawSideLine(_3Drotated[6],_3Drotated[2]);
  drawSideLine(_3Drotated[5],_3Drotated[1]);
  drawSideLine(_3Drotated[0],_3Drotated[2]);
  drawSideLine(_3Drotated[1],_3Drotated[3]);
  drawSideLine(_3Drotated[4],_3Drotated[6]);
  drawSideLine(_3Drotated[5],_3Drotated[7]);
  drawSideLine(_3Drotated[0],_3Drotated[4]);
  
  // draw projection lines
  stroke(0,50,250);

  for(int i = 0; i < 8; i++) {
      drawSideLine(_3Drotated[i],camera);
      drawTopLine(_3Drotated[i],camera);
  }
    stroke(255);
    
  // draw cameras
  stroke(0,200,0);
  drawTop(camera);
  drawSide(camera);
  stroke(255);
  
  int offset = 600;
   for (int i = 0 ; i < 8 ; i++) {
       int multiplier = i * 25;
       text("P[",30,multiplier + offset);text(i,42,multiplier + offset); text("] = ",50,multiplier + offset);   
       
       text("X: ",88,multiplier + offset);
       text(_3Dflattened_curr[i].x,100,multiplier + offset);
       text("Y: ",138,multiplier + offset);
       text(_3Dflattened_curr[i].y,150,multiplier + offset);
       text("Z: ",188,multiplier + offset);
       text(_3Dflattened_curr[i].z,200,multiplier + offset);
   }
   text("CURRENT RADIANS: ",50, 800); text(current_rad,170,800);
   text("CAMERA X: ",50, 850); text(camera.x,120,850);
   text("CAMERA Y: ",150, 850); text(camera.y,220,850);
   text("CAMERA Z: ",250, 850); text(camera.z,320,850);

  
}

void update() {

    for (int i=0;i < 8;i++){
        _3Dflattened_prev[i].x = _3Dflattened_curr[i].x;
        _3Dflattened_prev[i].y = _3Dflattened_curr[i].y;
        _3Dflattened_prev[i].z = _3Dflattened_curr[i].z;

        POINT temp_rotate = new POINT();
        temp_rotate = rotateX3D(_3Daxis,_3Dreal[i],current_rad);
  //      temp_rotate = rotateY3D(_3Daxis,temp_rotate,current_rad);
  //      temp_rotate = rotateZ3D(_3Daxis,temp_rotate,current_rad);
        _3Drotated[i] = temp_rotate;
        
        
        _3Dflattened_curr[i] = flatten(temp_rotate);
    }

    println("incrementing: " + current_rad);
    inc_radians();

}

POINT flatten( POINT _3Dpoint){

    POINT _2Dpoint = new POINT();
    POINT D = new POINT();

    // more complex if camera viewport is rotated
    D.x = _3Dpoint.x - camera.x;
    D.y = _3Dpoint.y - camera.y;
    D.z = _3Dpoint.z - camera.z;

 //   _2Dpoint.x = int(((float)D.x * (float)_3Dpoint.x / (float)_3Dpoint.z) - (float)camera.x);
 //   _2Dpoint.y = int(((float)D.y * (float)_3Dpoint.y / (float)_3Dpoint.z) - (float)camera.y);
 //   _2Dpoint.x = int(((float)-camera.z * (float)_3Dpoint.x / (float)_3Dpoint.z));
 //   _2Dpoint.y = int(((float)-camera.z * (float)_3Dpoint.y / (float)_3Dpoint.z));
    _2Dpoint.x = int(((float)-camera.z * (float)D.x / (float)D.z));
    _2Dpoint.y = int(((float)-camera.z * (float)D.y / (float)D.z));
    _2Dpoint.z = 0;
    
    _2Dpoint.x += camera.x;
    _2Dpoint.y += camera.y;
    _2Dpoint.z += camera.z;   

    return _2Dpoint;
}

void inc_radians() {

    if (current_rad < (2 * PI) ) {
        current_rad += 0.0087;
    } else {
        current_rad = 0.0;
    }

}

POINT topOrigin = new POINT(500,800,0);
POINT sideOrigin = new POINT(500,0,0);

void drawline(POINT p1, POINT p2){
  line(p1.x,p1.y,p2.x,p2.y);
}


void drawTop(POINT value) {
        ellipse(topOrigin.x+value.x,topOrigin.y-value.z,4,4);
}

void drawSide(POINT value) {
        ellipse(sideOrigin.x+value.z,sideOrigin.y+value.y,4,4);

}

void drawTopLine(POINT value1, POINT value2) {
      //line(value1.x,value1.y,value2.x,value2.y);
      line(topOrigin.x+value1.x,topOrigin.y-value1.z,topOrigin.x+value2.x,topOrigin.y-value2.z);

}

void drawSideLine(POINT value1, POINT value2) {
      line(sideOrigin.x+value1.z,sideOrigin.y+value1.y,sideOrigin.x+value2.z,sideOrigin.y+value2.y);
}

POINT rotateX3D( POINT axis,  POINT point, float radians) {

    POINT temp = new POINT();
    temp.x=point.x-axis.x;
    temp.y=point.y-axis.y;
    temp.z=point.z-axis.z;

    float _3Dmatrix[][] = new float[3][3];

    _3Dmatrix[0][0] = 1;     _3Dmatrix[0][1] = 0;             _3Dmatrix[0][2] = 0;
    _3Dmatrix[1][0] = 0;     _3Dmatrix[1][1] = cos(radians);  _3Dmatrix[1][2] = sin(radians);
    _3Dmatrix[2][0] = 0;     _3Dmatrix[2][1] = -sin(radians);  _3Dmatrix[2][2] = cos(radians);

    _3Dmatrix[0][0] *= temp.x;     _3Dmatrix[0][1] *= temp.y;           _3Dmatrix[0][2] *= temp.z;
    _3Dmatrix[1][0] *= temp.x;     _3Dmatrix[1][1] *= temp.y;           _3Dmatrix[1][2] *= temp.z;
    _3Dmatrix[2][0] *= temp.x;     _3Dmatrix[2][1] *= temp.y;           _3Dmatrix[2][2] *= temp.z;

    temp.x = int(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = int(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = int(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);

    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;

    return temp;

}

POINT rotateY3D( POINT axis,  POINT point, float radians) {

    POINT temp = new POINT();
    temp.x=point.x-axis.x;
    temp.y=point.y-axis.y;
    temp.z=point.z-axis.z;

    float _3Dmatrix[][] = new float[3][3];

    _3Dmatrix[0][0] = cos(radians);    _3Dmatrix[0][1] = 0;  _3Dmatrix[0][2] = -sin(radians);
    _3Dmatrix[1][0] = 0;               _3Dmatrix[1][1] = 1;  _3Dmatrix[1][2] = 0;
    _3Dmatrix[2][0] = sin(radians);    _3Dmatrix[2][1] = 0;  _3Dmatrix[2][2] = cos(radians);

    _3Dmatrix[0][0] *= temp.x;     _3Dmatrix[0][1] *= temp.y;           _3Dmatrix[0][2] *= temp.z;
    _3Dmatrix[1][0] *= temp.x;     _3Dmatrix[1][1] *= temp.y;           _3Dmatrix[1][2] *= temp.z;
    _3Dmatrix[2][0] *= temp.x;     _3Dmatrix[2][1] *= temp.y;           _3Dmatrix[2][2] *= temp.z;

    temp.x = int(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = int(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = int(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);

    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;

    return temp;

}

POINT rotateZ3D( POINT axis,  POINT point, float radians) {

    POINT temp = new POINT();
    temp.x=point.x-axis.x;
    temp.y=point.y-axis.y;
    temp.z=point.z-axis.z;

    float _3Dmatrix[][] = new float[3][3];

    _3Dmatrix[0][0] = cos(radians);    _3Dmatrix[0][1] = sin(radians);  _3Dmatrix[0][2] = 0;
    _3Dmatrix[1][0] = -sin(radians);   _3Dmatrix[1][1] = cos(radians);  _3Dmatrix[1][2] = 0;
    _3Dmatrix[2][0] = 0;               _3Dmatrix[2][1] = 0;             _3Dmatrix[2][2] = 1;

    _3Dmatrix[0][0] *= temp.x;     _3Dmatrix[0][1] *= temp.y;           _3Dmatrix[0][2] *= temp.z;
    _3Dmatrix[1][0] *= temp.x;     _3Dmatrix[1][1] *= temp.y;           _3Dmatrix[1][2] *= temp.z;
    _3Dmatrix[2][0] *= temp.x;     _3Dmatrix[2][1] *= temp.y;           _3Dmatrix[2][2] *= temp.z;

    temp.x = int(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = int(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = int(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);

    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;

    return temp;

}