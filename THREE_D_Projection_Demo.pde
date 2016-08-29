boolean pauseFlag = false;




// triangle test
TRIANGLE_POINTS test_triangle_rot1 = new TRIANGLE_POINTS();

POINT P1 = new POINT(550,700,0);
POINT P2 = new POINT(500,800,0);
POINT P3 = new POINT(600,900,0);

TRIANGLE_POINTS test_triangle1 = new TRIANGLE_POINTS(P1,P2,P3);
POINT _2Daxis = new POINT(550,800,0);
TRIANGLE_POINTS triangle_array[] = new TRIANGLE_POINTS[12];
TRIANGLE_POINTS temp_triangle_rot[] = new TRIANGLE_POINTS[12];

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
     
    camera =  new POINT(128  ,96  , -170);
    viewportPlane[0] = new POINT(0,   0,   0);
    viewportPlane[1] = new POINT(255, 0,   0);
    viewportPlane[2] = new POINT(0,   191,  0);
    
    
    // stuctures for 3d Cube and 2D representation
    _3Daxis =  new POINT(128, 96, 138);
    
    _3Dreal[0] = new POINT(68  ,36  ,98 ); // front top left *
    _3Dreal[1] = new POINT(188 ,36  ,98 ); // front top right
    _3Dreal[2] = new POINT(68  ,156 ,98 ); // front bottom left
    _3Dreal[3] = new POINT(188 ,156 ,98 ); // front bottom right *
    _3Dreal[4] = new POINT(68  ,36  ,218); // back top left
    _3Dreal[5] = new POINT(188 ,36  ,218); // back top right
    _3Dreal[6] = new POINT(68  ,156 ,218); // back bottom left
    _3Dreal[7] = new POINT(188 ,156 ,218); // back bottom right
                                
    for (int i = 0; i < 8; i++) {
      _3Dflattened_curr[i] = new POINT(0,0,0);
      _3Dflattened_prev[i] = new POINT(0,0,0);
      _3Drotated[i] = new POINT(0,0,0);
    }
    
    for (int tri = 0; tri < 12; tri++) {
       temp_triangle_rot[tri] = new TRIANGLE_POINTS(); 
    }
    
    // triangles for rasterization
    triangle_array[0 ] = new TRIANGLE_POINTS(_3Dflattened_curr[0],_3Dflattened_curr[1],_3Dflattened_curr[2]);
    triangle_array[1 ] = new TRIANGLE_POINTS(_3Dflattened_curr[3],_3Dflattened_curr[1],_3Dflattened_curr[2]);
    triangle_array[2 ] = new TRIANGLE_POINTS(_3Dflattened_curr[4],_3Dflattened_curr[5],_3Dflattened_curr[6]);
    triangle_array[3 ] = new TRIANGLE_POINTS(_3Dflattened_curr[7],_3Dflattened_curr[5],_3Dflattened_curr[6]);
    triangle_array[4 ] = new TRIANGLE_POINTS(_3Dflattened_curr[0],_3Dflattened_curr[1],_3Dflattened_curr[4]);
    triangle_array[5 ] = new TRIANGLE_POINTS(_3Dflattened_curr[5],_3Dflattened_curr[1],_3Dflattened_curr[4]);
    triangle_array[6 ] = new TRIANGLE_POINTS(_3Dflattened_curr[2],_3Dflattened_curr[3],_3Dflattened_curr[6]);
    triangle_array[7 ] = new TRIANGLE_POINTS(_3Dflattened_curr[7],_3Dflattened_curr[3],_3Dflattened_curr[6]);
    triangle_array[8 ] = new TRIANGLE_POINTS(_3Dflattened_curr[1],_3Dflattened_curr[3],_3Dflattened_curr[5]);
    triangle_array[9 ] = new TRIANGLE_POINTS(_3Dflattened_curr[7],_3Dflattened_curr[3],_3Dflattened_curr[5]);
    triangle_array[10] = new TRIANGLE_POINTS(_3Dflattened_curr[0],_3Dflattened_curr[4],_3Dflattened_curr[2]);
    triangle_array[11] = new TRIANGLE_POINTS(_3Dflattened_curr[6],_3Dflattened_curr[4],_3Dflattened_curr[2]);

}

void keyPressed() {
//   print("KEY PRESSED " + key);
    if(key == 'm') camera.x++;
    else if(key == 'n') camera.x--;
    else if(key == 'w') camera.z++;
    else if(key == 's') camera.z--;
    else if (key == 'a') camera.y--;
    else if (key == 'd') camera.y++;
    else if (key == 'p') {
        if (pauseFlag) pauseFlag = false;
        else pauseFlag = true;  
    }
    else if(key == CODED) {
        if(keyCode == UP     ) _3Daxis.y--;
        else if(keyCode == DOWN   ) _3Daxis.y++ ;
        else if(keyCode == LEFT   ) _3Daxis.x++;
        else if(keyCode == RIGHT  ) _3Daxis.x--;
    }
}




void draw() {
  if (!pauseFlag) {
  background(0);
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

  for (int tri = 0; tri < 12; tri++) {
     stroke(0,0,200);
     strokeWeight(1);
     
     //drawFilledTriangle(temp_triangle_rot[tri]);
     stroke(255);
     strokeWeight(2);
  }


  
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

  test_triangles();
  }
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
  
  
    // update the rotation of the triangles
    for (int tri = 0; tri < 12 ; tri++) {
      temp_triangle_rot[tri].P1 = rotate2D(_3Daxis,triangle_array[tri].P1,current_rad);
      temp_triangle_rot[tri].P2 = rotate2D(_3Daxis,triangle_array[tri].P2,current_rad);
      temp_triangle_rot[tri].P3 = rotate2D(_3Daxis,triangle_array[tri].P3,current_rad);
    }
    //println("incrementing: " + current_rad);
    inc_radians();

}

POINT flatten( POINT _3Dpoint){

    POINT _2Dpoint = new POINT();
    POINT D = new POINT();

    // more complex if camera viewport is rotated
    D.x = _3Dpoint.x - camera.x;
    D.y = _3Dpoint.y - camera.y;
    D.z = _3Dpoint.z - camera.z;

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

POINT topOrigin = new POINT(500,450,0);
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

POINT rotate2D(POINT axis, POINT p, float radians) {
    POINT new_point = new POINT();    


    int x = p.x - axis.x;
    int y = p.y - axis.y;


    float A = cos(radians);
    float B = -sin(radians);
    float C = -B;
    float D = A;
    
    new_point.x = int(A*float(x) + B*float(y));
    new_point.y = int(C*float(x) + D*float(y));

    new_point.x += axis.x;
    new_point.y += axis.y;

    return new_point;
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