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

    void set(POINT np1, POINT np2, POINT np3) {
       P1 = np1;
       P2 = np2;
       P3 = np3;
    }
}

void test_triangles() {
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

void drawFilledTriangleBresenham(TRIANGLE_POINTS triangle) {
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

void drawSLine(int left_x, int right_x, int left_z, int right_z, int y){
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

  void drawFilledTriangle(TRIANGLE_POINTS triangle) {
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
  void drawScanLine(int y, POINT a, POINT b, POINT c, POINT d) {
  //print("SCANLINE A (" + nfs(a.x,3) + "," + nfs(a.y,3) + "," + nfs(a.z,3) +
  //                        ") B (" + nfs(b.x,3) + "," + nfs(b.y,3) + "," + nfs(b.z,3) +
  //                        ") C (" + nfs(c.x,3) + "," + nfs(c.y,3) + "," + nfs(c.z,3) +
  //                        ") D (" + nfs(d.x,3) + "," + nfs(d.y,3) + "," + nfs(d.z,3) +") \n");
      float gradient1  = a.y != b.y ? float(y - a.y) / float(b.y - a.y) : 1;
      float gradient2 = c.y != d.y ? float(y - c.y) / float(d.y - c.y) : 1;

      //print("grad1: " + nfc(gradient1,3) + " grad 2: " + nfc(gradient2,3) + "\t\t");
      int left_x  = int(float(b.x-a.x) * gradient1) + a.x; // this assumes that the point passed as "a" was the highest of a,b
      int right_x = int(float(d.x-c.x) * gradient2) + c.x; // this assumes that the point passed as "c" was the highest of c,d

      int left_z = int(float(b.z-a.z) * gradient1) + a.z; // this assumes that the point passed as "c" was the highest of c,d
      int right_z = int(float(d.z-c.z) * gradient2) + c.z; // this assumes that the point passed as "c" was the highest of c,d



      if (left_x > right_x) {

          pauseFlag = true;
          println("\t\t::::AUTO-PAUSING::::\t\t");
      }
      //print("left_x: " + left_x + " right_x: " + right_x + " left_z: " + left_z + " right_z: " + right_z + "  ");
      for (int x = left_x; x <= right_x;x++) {

         float gradient_z = left_x != right_x ? (x - left_x) / float(right_x - left_x) : 1.0;
         //print("gz: " + gradient_z);
         int z = int(float(right_z-left_z) * gradient_z) + left_z;
         //print(" " + z + " ");
         //print(" dbi: " + (x + y * SCREEN_WIDTH) + " ");
         if (z <= depth_buffer[x + y * SCREEN_WIDTH]) {
             point(x,y);
             depth_buffer[x + y * SCREEN_WIDTH] = z;
         }
      }
      //print("\n");


  }
