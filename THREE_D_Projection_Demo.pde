boolean pauseFlag = false;

int MAX_DEPTH = 32768;
int SCREEN_WIDTH = 1000; // change to 256 for the actual NDS port
int SCREEN_HEIGHT = 1000; // 
int depth_buffer[] = new int[SCREEN_WIDTH*SCREEN_HEIGHT];;


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

// line pairs for wireframe
int [][] line_pairs =   {  {0,1},
                           {2,3},
                           {4,5},
                           {6,7},
                           {7,3},
                           {6,2},
                           {5,1},
                           {0,2},
                           {1,3},
                           {4,6},
                           {5,7},
                           {0,4}};

int then = 0;
int now = 0;
int FPS = 0;

void setup() {
  then = millis();
    size(1000,1000);
    
    
     noFill();
     stroke(255);
     strokeWeight(2); 
     
    clear_depth_buffer();
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
  
  clear_depth_buffer();
  background(0);
  iteration++;
  then = now;
  now = millis();
  FPS = 1000/(now - then);
    text("FPS: " + FPS , 850,20);
    //text("THEN: " + then + " NOW: " + now , 850,40);


     
  stroke(0);
  // un draw old cube
  for (int i = 0; i < 12; i++) {
      drawline(_3Dflattened_prev[line_pairs[i][0]],_3Dflattened_prev[line_pairs[i][1]]);
  }

  stroke(255);
  rect(0, 0, 256, 192);
  update();
  // draw cube
  for (int i = 0; i < 12; i++) {
      drawline(_3Dflattened_curr[line_pairs[i][0]],_3Dflattened_curr[line_pairs[i][1]]);
  }

  // draw cube top view
  for (int i = 0; i < 12; i++) {
      drawTopLine(_3Drotated[line_pairs[i][0]],_3Drotated[line_pairs[i][1]]);
  }

  // draw viewport
  drawTopLine(viewportPlane[0],viewportPlane[1]);
  drawSideLine(viewportPlane[0],viewportPlane[2]);

  for (int tri = 0; tri < 12; tri++) {
     stroke(tri,(tri*10),(tri*12) + 100);
     strokeWeight(1);
     
     //drawFilledTriangle(triangle_array[tri]);
     drawFilledTriangleBresenham(triangle_array[tri]);

     

  }
   stroke(255);
   strokeWeight(2);
  // draw cube side view

  for (int i = 0; i < 12; i++) {
      drawSideLine(_3Drotated[line_pairs[i][0]],_3Drotated[line_pairs[i][1]]);
  }

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
    
    // update triangles for rasterization
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
  
  
    // update the rotation of the triangles
    /*
    for (int tri = 0; tri < 12 ; tri++) {
      temp_triangle_rot[tri].P1 = rotate2D(_3Daxis,triangle_array[tri].P1,current_rad);
      temp_triangle_rot[tri].P2 = rotate2D(_3Daxis,triangle_array[tri].P2,current_rad);
      temp_triangle_rot[tri].P3 = rotate2D(_3Daxis,triangle_array[tri].P3,current_rad);
    }
    */
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

    _2Dpoint.x = int(float(-camera.z * D.x) / float(D.z));
    _2Dpoint.y = int(float(-camera.z * D.y) / float(D.z));
    _2Dpoint.z = D.z;
    
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


void clear_depth_buffer() {
 
   for (int i = 0; i < depth_buffer.length; i++) {
       depth_buffer[i] = MAX_DEPTH;
   }
  
}