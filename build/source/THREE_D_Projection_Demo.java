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

float current_rad = 0.0f;
int iteration = 0;

// ARWING MODEL
int arwing1Vertices[][] = {{100, 124, -73},
{282, 81, -268},
{60, 152, 150},
{39, 152, -50},
{172, 152, -73},
{83, 152, -50},
{39, 152, -50},
{60, 242, -250},
{39, 152, -50},
{-100, 124, -73},
{-282, 81, -268},
{-60, 152, 150},
{-39, 152, -50},
{0, 174, -100},
{0, 150, 365},
{-172, 152, -73},
{-83, 152, -50},
{0, 193, -54},
{-39, 152, -50},
{-60, 242, -250},
{-39, 152, -50},
{0, 152, -50}};

POINT arwingVertexPoints[] = new POINT[22]; // hold original vetex points
POINT arwingRotatedVertexPoints[] = new POINT[22]; // holst points after rotation transformation
POINT arwingFlattenedVertexPoints[] = new POINT[22]; // flatrtens points on viewport canvas

POINT arwingTranslation = new POINT(128,260,600); // this is where the model should be positioned behind the viewport


int arwing1Faces[][] = {{6, 2, 7},
{2, 6, 5},
{0, 4, 8},
{6, 13, 17},
{4, 1, 8},
{14, 6, 17},
{2, 5, 7},
{4, 0, 1},
{5, 6, 7},
{8, 21, 17},
{21, 8, 14},
{0, 8, 1},
{18, 19, 11},
{11, 16, 18},
{9, 20, 15},
{18, 17, 13},
{15, 20, 10},
{14, 17, 18},
{11, 19, 16},
{15, 10, 9},
{16, 19, 18},
{20, 17, 21},
{21, 14, 20},
{9, 10, 20}};

TRIANGLE_POINTS arwingTriFaces[] = new TRIANGLE_POINTS[24];
//TRIANGLE_POINTS tempArwingRot[] = new TRIANGLE_POINTS[24];
TRIANGLE_POINTS arwingTriangleArray[] = new TRIANGLE_POINTS[24];

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
    //camera =  new POINT(128  ,96  , -170);
    camera =  new POINT(128  ,96  , -270);
    viewportPlane[0] = new POINT(0,   0,   0);
    viewportPlane[1] = new POINT(255, 0,   0);
    viewportPlane[2] = new POINT(0,   191,  0);


    // stuctures for 3d Cube and 2D representation
//    _3Daxis =  new POINT(128, 96, 138);
    _3Daxis =  new POINT(128, 96, 100);

    /*
    _3Dreal[0] = new POINT(68  ,36  ,98 ); // front top left *
    _3Dreal[1] = new POINT(188 ,36  ,98 ); // front top right
    _3Dreal[2] = new POINT(68  ,156 ,98 ); // front bottom left
    _3Dreal[3] = new POINT(188 ,156 ,98 ); // front bottom right *
    _3Dreal[4] = new POINT(68  ,36  ,218); // back top left
    _3Dreal[5] = new POINT(188 ,36  ,218); // back top right
    _3Dreal[6] = new POINT(68  ,156 ,218); // back bottom left
    _3Dreal[7] = new POINT(188 ,156 ,218); // back bottom right
    */

    for (int i = 0; i < 8; i++) {
      _3Dflattened_curr[i] = new POINT(0,0,0);
      _3Dflattened_prev[i] = new POINT(0,0,0);
      _3Drotated[i] = new POINT(0,0,0);
    }

    for (int tri = 0; tri < 12; tri++) {
       temp_triangle_rot[tri] = new TRIANGLE_POINTS();
    }


    for (int vert = 0; vert < 22; vert++) {
        arwingVertexPoints[vert] = new POINT(arwing1Vertices[vert][0],arwing1Vertices[vert][1],arwing1Vertices[vert][2]);
        println("V " + arwingVertexPoints[vert].x + " " + arwingVertexPoints[vert].y + " " + arwingVertexPoints[vert].z);
    }

    for (int tri=0;tri < 24;tri++) {
        arwingTriangleArray[tri] = new TRIANGLE_POINTS();
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

  stroke(255);
  noFill();
  rect(0, 0, 256, 192);
  update();

  // draw cube top view
  for (int i = 0; i < 12; i++) {
      drawTopLine(_3Drotated[line_pairs[i][0]],_3Drotated[line_pairs[i][1]]);
  }

  // draw viewport
  drawTopLine(viewportPlane[0],viewportPlane[1]);
  drawSideLine(viewportPlane[0],viewportPlane[2]);

  // draw arwing
  for (int tri = 0; tri < 24; tri++) {
     stroke(tri,(tri*5)+50,(tri*6) + 130);
     strokeWeight(1);
     //drawFilledTriangle(triangle_array[tri]);
    // drawFilledTriangleBresenham(triangle_array[tri]);
     drawFilledTriangleBresenham(arwingTriangleArray[tri]);

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

  int offset = 800;
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
   text("CURRENT RADIANS: ",50, 900); text(current_rad,170,900);
   text("CAMERA X: ",50, 950); text(camera.x,120,950);
   text("CAMERA Y: ",150, 950); text(camera.y,220,950);
   text("CAMERA Z: ",250, 950); text(camera.z,320,950);

  test_triangles();
  }
}

public void update() {

    for (int i=0;i < 22; i++) {
        POINT temp_rotate = new POINT();
        POINT origin_point = new POINT();
        temp_rotate = rotateX3D(origin_point,arwingVertexPoints[i],15*PI/16);
        temp_rotate = rotateY3D(origin_point,temp_rotate,current_rad);

        //println("V#  " + i);
        //println("_3Daxis " + _3Daxis.x + " " + _3Daxis.y + " " + _3Daxis.z);
        //println("_3Daxis " + _3Daxis.x + " " + _3Daxis.y + " " + _3Daxis.z);
        //println("current_rad " + current_rad);

        temp_rotate = Translate3D(arwingTranslation, temp_rotate);
        arwingRotatedVertexPoints[i] = temp_rotate;
        arwingFlattenedVertexPoints[i] = flatten(temp_rotate);
    }

    for (int tri=0;tri < 24;tri++) {
        arwingTriangleArray[tri].set(   arwingFlattenedVertexPoints[arwing1Faces[tri][0]],
                                        arwingFlattenedVertexPoints[arwing1Faces[tri][1]],
                                        arwingFlattenedVertexPoints[arwing1Faces[tri][2]]);
    }


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

    public void set(int nx,int ny, int nz){
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
public POINT Translate3D(POINT translationVector, POINT oringinalPoint) {
    POINT tempPoint = new POINT();

    tempPoint.x = translationVector.x + oringinalPoint.x;
    tempPoint.y = translationVector.y + oringinalPoint.y;
    tempPoint.z = translationVector.z + oringinalPoint.z;

    return tempPoint;
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

    public void set(POINT np1, POINT np2, POINT np3) {
       P1 = np1;
       P2 = np2;
       P3 = np3;
    }
}

public void test_triangles() {
  //println("_2Daxis: X" + _2Daxis.x + " Y" + _2Daxis.y + " Test_triangle P1: X:" + test_triangle1.P1.x + " Y:" + test_triangle1.P1.y + " current rad: " + current_rad);
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

  int DMaxTM;
  int DMaxTB;
  int DMaxMB;

  int remainingSteps;

  POINT STB = new POINT(); // calculating Top-Bottom
  POINT STM = new POINT(); // calculating Middle-Bottom
  POINT SMB = new POINT(); // calculating Middle-Bottom

  // error calculation
  POINT ETB = new POINT(); // calculating Top-Bottom Error
  POINT ETM = new POINT(); // calculating Middle-Bottom Error
  POINT EMB = new POINT(); // calculating Middle-Bottom Error

  // temp error holder for comparisons
  int E2L;
  int E2R;

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

  DMaxTM = DTM.x > DTM.y ? (DTM.x > DTM.z ? DTM.x : DTM.z) : (DTM.y > DTM.z ? DTM.y : DTM.z);
  DMaxTB = DTB.x > DTB.y ? (DTB.x > DTB.z ? DTB.x : DTB.z) : (DTB.y > DTB.z ? DTB.y : DTB.z);
  DMaxMB = DMB.x > DMB.y ? (DMB.x > DMB.z ? DMB.x : DMB.z) : (DMB.y > DMB.z ? DMB.y : DMB.z);

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
  // initiale error is half of which ever metrics x, y or z
  // contributes most greatly to the slope
  ETM.x = DMaxTM >> 1;
  ETM.y = DMaxTM >> 1;
  ETM.z = DMaxTM >> 1;

  ETB.x = DMaxTB >> 1;
  ETB.y = DMaxTB >> 1;
  ETB.z = DMaxTB >> 1;

  EMB.x = DMaxMB >> 1;
  EMB.y = DMaxMB >> 1;
  EMB.z = DMaxMB >> 1;

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
        if(YL <= YR) {        // if the left line < right increment only left
            ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XL += STB.x; }
            ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YL += STB.y; }
            ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZL += STB.z; }
        }
        else if (YL > YR) {   // if the right line < left increment only
            ETM.x -= DTM.x; if (ETM.x < 0) { ETM.x += DMaxTM; XR += STM.x; }
            ETM.y -= DTM.y; if (ETM.y < 0) { ETM.y += DMaxTM; YR += STM.y; }
            ETM.z -= DTM.z; if (ETM.z < 0) { ETM.z += DMaxTM; ZR += STM.z; }
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
        if(YL <= YR) {        // if the left line < right increment only left
            ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XL += STB.x; }
            ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YL += STB.y; }
            ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZL += STB.z; }
        }
        else if (YL > YR) {   // if the right line < left increment only
            EMB.x -= DMB.x; if (EMB.x < 0) { EMB.x += DMaxMB; XR += SMB.x; }
            EMB.y -= DMB.y; if (EMB.y < 0) { EMB.y += DMaxMB; YR += SMB.y; }
            EMB.z -= DMB.z; if (EMB.z < 0) { EMB.z += DMaxMB; ZR += SMB.z; }
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
        if(YL <= YR) {        // if the left line < right increment only left
            ETM.x -= DTM.x; if (ETM.x < 0) { ETM.x += DMaxTM; XL += STM.x; }
            ETM.y -= DTM.y; if (ETM.y < 0) { ETM.y += DMaxTM; YL += STM.y; }
            ETM.z -= DTM.z; if (ETM.z < 0) { ETM.z += DMaxTM; ZL += STM.z; }
        }
        else if (YL > YR) {   // if the right line < left increment only
            ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XR += STB.x; }
            ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YR += STB.y; }
            ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZR += STB.z; }
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
        if(YL <= YR) {        // if the left line < right increment only left
            EMB.x -= DMB.x; if (EMB.x < 0) { EMB.x += DMaxMB; XL += SMB.x; }
            EMB.y -= DMB.y; if (EMB.y < 0) { EMB.y += DMaxMB; YL += SMB.y; }
            EMB.z -= DMB.z; if (EMB.z < 0) { EMB.z += DMaxMB; ZL += SMB.z; }
        }
        else if (YL > YR) {   // if the right line < left increment only
            ETB.x -= DTB.x; if (ETB.x < 0) { ETB.x += DMaxTB; XR += STB.x; }
            ETB.y -= DTB.y; if (ETB.y < 0) { ETB.y += DMaxTB; YR += STB.y; }
            ETB.z -= DTB.z; if (ETB.z < 0) { ETB.z += DMaxTB; ZR += STB.z; }
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
      DeltaZ = -(left_z > right_z ? left_z - right_z : right_z - left_z);

      StepX = left_x < right_x ? 1 : -1;
      StepZ = left_z < right_z ? 1 : -1;

      //Error = (DeltaX > DeltaZ ? DeltaX : -DeltaZ) >> 1;
      Error = DeltaX + DeltaZ;

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
         ErrorTmp = 2 * Error;
         if (ErrorTmp >= DeltaZ) { Error += DeltaZ; x += StepX; }
         if (ErrorTmp <= DeltaX) { Error += DeltaX; z += StepZ; }
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
