import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class THREE_D_Projection_Demo extends PApplet {

boolean pauseFlag = false;

int MAX_DEPTH = 16384;
int SCREEN_WIDTH = 256; // change to 256 for the actual NDS port
int SCREEN_HEIGHT = 192; //
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

float current_rad = 0.0f;
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

public void setup() {
  then = millis();
    
    

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

public void keyPressed() {
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




public void draw() {
  if (!pauseFlag) {

  clear_depth_buffer();
  background(0);
  iteration++;
  then = now;
  now = millis();
  FPS = 1000/(now - then);
    text("FPS: " + FPS , 850,20);
    //text("THEN: " + then + " NOW: " + now , 850,40);


/*
  stroke(0);
  // un draw old cube
  for (int i = 0; i < 12; i++) {
      drawline(_3Dflattened_prev[line_pairs[i][0]],_3Dflattened_prev[line_pairs[i][1]]);
  }
*/

  stroke(255);
  noFill();
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

  //test_triangles();
  }
}

public void update() {

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

public POINT flatten( POINT _3Dpoint){

    POINT _2Dpoint = new POINT();
    POINT D = new POINT();

    // more complex if camera viewport is rotated
    D.x = _3Dpoint.x - camera.x;
    D.y = _3Dpoint.y - camera.y;
    D.z = _3Dpoint.z - camera.z;

    _2Dpoint.x = PApplet.parseInt(-camera.z * D.x / PApplet.parseFloat(D.z));
    _2Dpoint.y = PApplet.parseInt(-camera.z * D.y / PApplet.parseFloat(D.z));
    _2Dpoint.z = D.z;

    _2Dpoint.x += camera.x;
    _2Dpoint.y += camera.y;
    _2Dpoint.z += camera.z;

    return _2Dpoint;
}

public void inc_radians() {

    if (current_rad < (2 * PI) ) {
        current_rad += 0.0087f;
    } else {
        current_rad = 0.0f;
    }

}


public void clear_depth_buffer() {

   for (int i = 0; i < depth_buffer.length; i++) {
       depth_buffer[i] = MAX_DEPTH;
   }

}
POINT topOrigin = new POINT(500,450,0);
POINT sideOrigin = new POINT(500,0,0);

public void drawline(POINT p1, POINT p2){
  line(p1.x,p1.y,p2.x,p2.y);
}


public void drawTop(POINT value) {
        ellipse(topOrigin.x+value.x,topOrigin.y-value.z,4,4);
}

public void drawSide(POINT value) {
        ellipse(sideOrigin.x+value.z,sideOrigin.y+value.y,4,4);

}

public void drawTopLine(POINT value1, POINT value2) {
      //line(value1.x,value1.y,value2.x,value2.y);
      line(topOrigin.x+value1.x,topOrigin.y-value1.z,topOrigin.x+value2.x,topOrigin.y-value2.z);

}


public void drawSideLine(POINT value1, POINT value2) {
      line(sideOrigin.x+value1.z,sideOrigin.y+value1.y,sideOrigin.x+value2.z,sideOrigin.y+value2.y);
}
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
public POINT rotate2D(POINT axis, POINT p, float radians) {
    POINT new_point = new POINT();    


    int x = p.x - axis.x;
    int y = p.y - axis.y;


    float A = cos(radians);
    float B = -sin(radians);
    float C = -B;
    float D = A;
    
    new_point.x = PApplet.parseInt(A*PApplet.parseFloat(x) + B*PApplet.parseFloat(y));
    new_point.y = PApplet.parseInt(C*PApplet.parseFloat(x) + D*PApplet.parseFloat(y));

    new_point.x += axis.x;
    new_point.y += axis.y;

    return new_point;
}

public POINT rotateX3D( POINT axis,  POINT point, float radians) {

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

    temp.x = PApplet.parseInt(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = PApplet.parseInt(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = PApplet.parseInt(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);

    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;

    return temp;

}

public POINT rotateY3D( POINT axis,  POINT point, float radians) {

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

    temp.x = PApplet.parseInt(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = PApplet.parseInt(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = PApplet.parseInt(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);

    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;

    return temp;

}

public POINT rotateZ3D( POINT axis,  POINT point, float radians) {

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

    temp.x = PApplet.parseInt(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = PApplet.parseInt(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = PApplet.parseInt(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);

    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;

    return temp;

}
public class TRIANGLE_POINTS {
    public POINT P1;
    public POINT P2;
    public POINT P3;

    TRIANGLE_POINTS() {
    }

    TRIANGLE_POINTS(POINT np1, POINT np2, POINT np3) {
       P1 = np1;
       P2 = np2;
       P3 = np3;
    }
}

public void test_triangles() {
  println("_2Daxis: X" + _2Daxis.x + " Y" + _2Daxis.y + " Test_triangle P1: X:" + test_triangle1.P1.x + " Y:" + test_triangle1.P1.y + " current rad: " + current_rad);
    test_triangle_rot1.P1 = rotate2D(_2Daxis,test_triangle1.P1,current_rad);
    test_triangle_rot1.P2 = rotate2D(_2Daxis,test_triangle1.P2,current_rad);
    test_triangle_rot1.P3 = rotate2D(_2Daxis,test_triangle1.P3,current_rad);

    stroke(0,255,100);
    drawline(test_triangle_rot1.P1,test_triangle_rot1.P1);
    drawline(test_triangle_rot1.P1,test_triangle_rot1.P2);
    drawline(test_triangle_rot1.P2,test_triangle_rot1.P3);

    stroke(255,0,0);
    strokeWeight(1);
    drawFilledTriangleBresenham(test_triangle_rot1);
    strokeWeight(2);
    stroke(255);
}


  POINT DTB = new POINT(); // calculating Top-Bottom
  POINT DTM = new POINT(); // calculating Middle-Bottom
  POINT DMB = new POINT(); // calculating Middle-Bottom

  POINT STB = new POINT(); // calculating Top-Bottom
  POINT STM = new POINT(); // calculating Middle-Bottom
  POINT SMB = new POINT(); // calculating Middle-Bottom

  // error calculation
  int ETB; // calculating Top-Bottom
  int ETM; // calculating Middle-Bottom
  int EMB; // calculating Middle-Bottom

  int ETBz; // calculating Top-Bottom
  int ETMz; // calculating Middle-Bottom
  int EMBz; // calculating Middle-Bottom

  // temp error holder for comparisons
  int E2L;
  int E2R;

  int E2Lz;
  int E2Rz;

  POINT top;
  POINT middle;
  POINT bottom;

  int YL,YR, XL, XR, ZL, ZR;
  int setup_time;
  int draw_time;

public void drawFilledTriangleBresenham(TRIANGLE_POINTS triangle) {
  //println("BEGIN drawFilledTriangleBresenham()");
  fill(0);
  rect(825,45,150,150);
  fill(255);

  setup_time = millis();

  if(triangle.P1.y < triangle.P2.y) {
      top = triangle.P1;
      middle = triangle.P2;
  } else {
     top = triangle.P2;
     middle = triangle.P1;
  }

  if(triangle.P3.y <= top.y) {
      bottom = middle;
      middle = top;
      top = triangle.P3;
  } else if(triangle.P3.y < middle.y) {
    bottom = middle;
    middle = triangle.P3;
  } else {
    bottom = triangle.P3;
  }
  //println(  "TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
  //        ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
  //        ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") ");



  int edge = (middle.x - top.x) * (bottom.y - top.y) - (middle.y-top.y) * (bottom.x - top.x);


  DTM.x = top.x > middle.x ? top.x - middle.x : middle.x - top.x;
  DTM.y = middle.y - top.y;
  DTM.z = top.x > middle.z ? top.z - middle.z : middle.z - top.z;

  DTB.x = top.x > bottom.x ? top.x - bottom.x : bottom.x - top.x;
  DTB.y = bottom.y-top.y;
  DTB.z = top.z > bottom.z ? top.z - bottom.z : bottom.z - top.z;

  DMB.x = middle.x > bottom.x ? middle.x - bottom.x : bottom.x - middle.x;
  DMB.y = bottom.y - middle.y;
  DMB.z = middle.z > bottom.z ? middle.z - bottom.z : bottom.z - middle.z;


  // Calculate steps from start to destination

  STM.x = (top.x < middle.x) ? 1 : -1;
  STM.y = 1;
  STM.z = (top.z < middle.z) ? 1 : -1;

  STB.x = (top.x < bottom.x) ? 1 : -1;
  STB.y = 1;
  STB.z = (top.z < bottom.z) ? 1 : -1;

  SMB.x = (middle.x < bottom.x) ? 1 : -1;
  SMB.y = 1;
  SMB.z = (middle.z < bottom.z) ? 1 : -1;


  // calculate starting error
  // y will be negative and x will be positive
  // initiale error is half of which ever metrics x or y
  // contributes most greatly to the slope
  ETM = (DTM.x > DTM.y ? DTM.x : -DTM.y) >> 1;
  ETB = (DTB.x > DTB.y ? DTB.x : -DTB.y) >> 1;
  EMB = (DMB.x > DMB.y ? DMB.x : -DMB.y) >> 1;

  ETMz = (DTM.z > DTM.y ? DTM.z : -DTM.y) >> 1;
  ETBz = (DTB.z > DTB.y ? DTB.z : -DTB.y) >> 1;
  EMBz = (DMB.z > DMB.y ? DMB.z : -DMB.y) >> 1;

  // triangle always starts at a single point regardless of direction
   YL = top.y;
   YR = top.y;
   XL = top.x;
   XR = top.x;
   ZL = top.z;
   ZR = top.z;
  text("SETUP TIME: " + (millis() - setup_time), 850,60);
  draw_time = millis();

  if(edge > 0) {  // right pointing triangle
    //print("POINTING RIGHT TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
    //                      ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
    //                      ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") \n");

     // top half of triangle
     for(;;){
        if(YL == YR) {
              // println("RIGHT TOP XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
              drawSLine(XL, XR, ZL, ZR, YL);
              if (YL >= middle.y) break;
        }
        E2L = ETB;
        E2R = ETM;
        E2Lz = ETBz;
        E2Rz = ETMz;
        if(YL <= YR) {        // if the left line < right increment only left
            if (E2L >-DTB.x) { ETB -= DTB.y; XL += STB.x; }
            if (E2L < DTB.y) { ETB += DTB.x; YL += STB.y; }
            if (E2Lz >-DTB.z) { ETBz -= DTB.y; ZL += STB.z; }
            if (E2Lz < DTB.y) { ETBz += DTB.z;}
        }
        else if (YL > YR) {   // if the right line < left increment only
            if (E2R >-DTM.x) { ETM -= DTM.y; XR += STM.x; }
            if (E2R < DTM.y) { ETM += DTM.x; YR += STM.y; }
            if (E2Rz >-DTM.z) { ETMz -= DTM.y; ZR += STM.z; }
            if (E2Rz < DTM.y) { ETMz += DTM.z;}
        }
     }
     // bottom half of triangle
     YR = middle.y;
     XR = middle.x;
     ZR = middle.z;

     for(;;){
        if(YL == YR) {
          //println("RIGHT BOTTOM XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
          drawSLine(XL, XR, ZL, ZR, YL);
              if (YL >= bottom.y) break;
        }
        E2L = ETB;
        E2R = EMB;
        E2Lz = ETBz;
        E2Rz = EMBz;
        if(YL <= YR) {        // if the left line < right increment only left
            if (E2L >-DTB.x) { ETB -= DTB.y; XL += STB.x; }
            if (E2L < DTB.y) { ETB += DTB.x; YL += STB.y; }
            if (E2Lz >-DTB.z) { ETBz -= DTB.y; ZL += STB.z; }
            if (E2Lz < DTB.y) { ETBz += DTB.z;}
        }
        else if (YL > YR) {   // if the right line < left increment only
            if (E2R >-DMB.x) { EMB -= DMB.y; XR += SMB.x; }
            if (E2R < DMB.y) { EMB += DMB.x; YR += SMB.y; }
            if (E2Rz >-DMB.z) { EMBz -= DMB.y; ZR += SMB.z; }
            if (E2Rz < DMB.y) { EMBz += DMB.z;}
        }
     }
  }
  else { // Case with middle point on left side of triangle
        //print("POINTING LEFT  TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
        //                  ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
        //                  ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") \n");

     // top half of triangle
     for(;;){
        if(YL == YR) {
              //println("LEFT TOP XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
              drawSLine(XL, XR, ZL, ZR, YL);
              if (YR >= middle.y) break;
        }
        E2L = ETM;
        E2R = ETB;
        E2Lz = ETMz;
        E2Rz = ETBz;
        if(YL <= YR) {        // if the left line < right increment only left
            if (E2L >-DTM.x) { ETM -= DTM.y; XL += STM.x; }
            if (E2L < DTM.y) { ETM += DTM.x; YL += STM.y; }
            if (E2Lz >-DTM.z) { ETMz -= DTM.y; ZL += STM.z; }
            if (E2Lz < DTM.y) { ETMz += DTM.z;}
        }
        else if (YL > YR) {   // if the right line < left increment only
            if (E2R >-DTB.x) { ETB -= DTB.y; XR += STB.x; }
            if (E2R < DTB.y) { ETB += DTB.x; YR += STB.y; }
            if (E2Rz >-DTB.z) { ETBz -= DTB.x; ZR += STB.z; }
            if (E2Rz < DTB.x) { ETBz += DTB.z;}
        }
     }
     // bottom half of triangle
     YL = middle.y;
     XL = middle.x;
     ZL = middle.z;
     for(;;){
        if(YL == YR) {
              //println("LEFT BOTTOM XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
              drawSLine(XL, XR, ZL, ZR, YL);
              if (YR >= bottom.y) break;
        }
        E2L = EMB;
        E2R = ETB;
        E2Lz = EMBz;
        E2Rz = ETBz;
        if(YL <= YR) {        // if the left line < right increment only left
            if (E2L >-DMB.x) { EMB -= DMB.y; XL += SMB.x; }
            if (E2L < DMB.y) { EMB += DMB.x; YL += SMB.y; }
            if (E2Lz >-DMB.z) { EMBz -= DMB.y; ZL += SMB.z; }
            if (E2Lz < DMB.y) { EMBz += DMB.z;}
        }
        else if (YL > YR) {   // if the right line < left increment only
            if (E2R >-DTB.x) { ETB -= DTB.y; XR += STB.x; }
            if (E2R < DTB.y) { ETB += DTB.x; YR += STB.y; }
            if (E2Rz >-DTB.z) { ETBz -= DTB.y; ZR += STB.z; }
            if (E2Rz < DTB.y) { ETBz += DTB.z;}
        }
     }
  }
  text("DRAW TIME: " + (millis() - draw_time), 850,80);
}

int DeltaX;
int DeltaZ;
int StepX;
int StepZ;
int Error;
int ErrorTmp;
int x;
int z;
int depthBufferIndex;

public void drawSLine(int left_x, int right_x, int left_z, int right_z, int y){
      if(left_z < 0 || right_z < 0) { //<>//
        println(" left_Z: " + left_z + " right_Z: " + right_z);
        pauseFlag = true;  //<>//

        //return;
      }
      //println("STARTING DRAWSLINE()");
      DeltaX = left_x > right_x ? left_x - right_x : right_x - left_x;
      DeltaZ = left_z > right_z ? left_z - right_z : right_z - left_z;

      StepX = left_x < right_x ? 1 : -1;
      StepZ = left_z < right_z ? 1 : -1;

      Error = (DeltaX > DeltaZ ? DeltaX : -DeltaZ) >> 1;

      x=left_x;
      z=left_z;

      //println(" LeftX: " + left_x + " RightX: " + right_x + " LeftZ: " + left_z + " RightZ: " + right_z + " DX: " + DeltaX + " DZ: " + DeltaZ + " SX: " +StepX + " SZ: " + StepZ + " Error: " + Error);

      for(;;) {
         if(z < 0) {
            println("Z went negative");
            //System.exit(1);
            println(" LeftX: " + left_x + " RightX: " + right_x + " LeftZ: " + left_z + " RightZ: " + right_z +
            " DX: " + DeltaX + " DZ: " + DeltaZ + " SX: " +StepX + " SZ: " + StepZ + " Error: " + Error +
            " x: " + x + " z: " + z);
            pauseFlag = true;  //<>//
            break;
         }
         depthBufferIndex = x + (y * SCREEN_WIDTH); //<>//
         //print("LeftX: " + left_x + " RightX: " + right_x + "LeftZ: " + left_z + " RightZ: " + right_z + " DX: " + DeltaX + " DZ: " + DeltaZ + " SX: " +StepX + " SZ: " + StepZ + " Error: " + Error);
         //println(" db: " + depth_buffer[depthBufferIndex] + " x: " + x + " z: " + z  + " Error: " + Error);
         //println(" LeftX: " + left_x + " RightX: " + right_x + " LeftZ: " + left_z + " RightZ: " + right_z +
         //" DX: " + DeltaX + " DZ: " + DeltaZ + " SX: " +StepX + " SZ: " + StepZ + " Error: " + Error +
         //" x: " + x + " z: " + z);

         if (z <= depth_buffer[depthBufferIndex]) {
             point(x,y);
             depth_buffer[depthBufferIndex] = z;
         }
         if(x == right_x) {break;}
         ErrorTmp = Error;
         if (ErrorTmp >-DeltaX) { Error -= DeltaZ; x += StepX; }
         if (ErrorTmp < DeltaZ) { Error += DeltaX; z += StepZ; }
      }
  }

  public void drawFilledTriangle(TRIANGLE_POINTS triangle) {
  POINT top;
  POINT middle;
  POINT bottom;

  if(triangle.P1.y < triangle.P2.y) {
      top = triangle.P1;
      middle = triangle.P2;
  } else {
     top = triangle.P2;
     middle = triangle.P1;
  }

  if(triangle.P3.y <= top.y) {
      bottom = middle;
      middle = top;
      top = triangle.P3;
  } else if(triangle.P3.y < middle.y) {
    bottom = middle;
    middle = triangle.P3;
  } else {
    bottom = triangle.P3;
  }


  int edge = (middle.x - top.x) * (bottom.y - top.y) - (middle.y-top.y) * (bottom.x - top.x);



  if(edge > 0) { // right pointing triangle
    print("POINTING RIGHT TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
                          ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
                          ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") \n");

     for (int y = top.y; y <= bottom.y; y++)
        {
            if (y < middle.y)
            {
                drawScanLine(y, top, bottom, top, middle);
            }
            else
            {
                drawScanLine(y, top, bottom, middle, bottom);
            }
        }

  }


  // Case with middle point on left side of triangle
  else {
        print("POINTING LEFT  TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
                          ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
                          ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") \n");


        for (int y = (int)top.y; y <= (int)bottom.y; y++)
        {
            if (y < middle.y)
            {
                drawScanLine(y, top, middle, top, bottom);
            }
            else
            {
                drawScanLine(y, middle, bottom, top, bottom);
            }
        }

  }


}

  // determines where to draw the line based on the space between the x points on two sides of the triangle given a particular y coordinate
  public void drawScanLine(int y, POINT a, POINT b, POINT c, POINT d) {
  //print("SCANLINE A (" + nfs(a.x,3) + "," + nfs(a.y,3) + "," + nfs(a.z,3) +
  //                        ") B (" + nfs(b.x,3) + "," + nfs(b.y,3) + "," + nfs(b.z,3) +
  //                        ") C (" + nfs(c.x,3) + "," + nfs(c.y,3) + "," + nfs(c.z,3) +
  //                        ") D (" + nfs(d.x,3) + "," + nfs(d.y,3) + "," + nfs(d.z,3) +") \n");
      float gradient1  = a.y != b.y ? PApplet.parseFloat(y - a.y) / PApplet.parseFloat(b.y - a.y) : 1;
      float gradient2 = c.y != d.y ? PApplet.parseFloat(y - c.y) / PApplet.parseFloat(d.y - c.y) : 1;

      //print("grad1: " + nfc(gradient1,3) + " grad 2: " + nfc(gradient2,3) + "\t\t");
      int left_x  = PApplet.parseInt(PApplet.parseFloat(b.x-a.x) * gradient1) + a.x; // this assumes that the point passed as "a" was the highest of a,b
      int right_x = PApplet.parseInt(PApplet.parseFloat(d.x-c.x) * gradient2) + c.x; // this assumes that the point passed as "c" was the highest of c,d

      int left_z = PApplet.parseInt(PApplet.parseFloat(b.z-a.z) * gradient1) + a.z; // this assumes that the point passed as "c" was the highest of c,d
      int right_z = PApplet.parseInt(PApplet.parseFloat(d.z-c.z) * gradient2) + c.z; // this assumes that the point passed as "c" was the highest of c,d



      if (left_x > right_x) {

          pauseFlag = true;
          println("\t\t::::AUTO-PAUSING::::\t\t");
      }
      //print("left_x: " + left_x + " right_x: " + right_x + " left_z: " + left_z + " right_z: " + right_z + "  ");
      for (int x = left_x; x <= right_x;x++) {

         float gradient_z = left_x != right_x ? (x - left_x) / PApplet.parseFloat(right_x - left_x) : 1.0f;
         //print("gz: " + gradient_z);
         int z = PApplet.parseInt(PApplet.parseFloat(right_z-left_z) * gradient_z) + left_z;
         //print(" " + z + " ");
         //print(" dbi: " + (x + y * SCREEN_WIDTH) + " ");
         if (z <= depth_buffer[x + y * SCREEN_WIDTH]) {
             point(x,y);
             depth_buffer[x + y * SCREEN_WIDTH] = z;
         }
      }
      //print("\n");


  }
  public void settings() {  size(1000,1000);  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "THREE_D_Projection_Demo" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
