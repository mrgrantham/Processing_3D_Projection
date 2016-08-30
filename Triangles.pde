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

void test_triangles() {
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

void drawFilledTriangleBresenham(TRIANGLE_POINTS triangle) {
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

  if(edge > 0) { // right pointing triangle
    print("POINTING RIGHT TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
                          ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
                          ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") \n");

     // top half of triangle
     for(;;){
        if(YL == YR) {
              //if(ZL < 0 || ZR < 0) {
                println("RIGHT TOP XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
              //  break;
              //}
              drawSLine(XL, XR, ZL, ZR, YL);
              if (YL >= middle.y) break;
        }
        E2L = ETB;
        E2R = ETM;

        E2Lz = ETBz;
        E2Rz = ETMz;

        // if the left line is not matching the right then increment the equation until it matches
        if(YL <= YR) {
            if (E2L >-DTB.x) { ETB -= DTB.y; XL += STB.x; }
            if (E2L < DTB.y) { ETB += DTB.x; YL += STB.y; }
            if (E2Lz >-DTB.z) { ETBz -= DTB.y; ZL += STB.z; }
            if (E2Lz < DTB.y) { ETBz += DTB.z;}
        }
        // if the right line is not matching the left then increment the equation until it matches
        else if (YL > YR) {
            if (E2R >-DTM.x) { ETM -= DTM.y; XR += STM.x; }
            if (E2R < DTM.y) { ETM += DTM.x; YR += STM.y; }
            if (E2Rz >-DTM.z) { ETMz -= DTM.y; ZR += STM.z; }
            if (E2Rz < DTM.y) { ETMz += DTM.z;}
        }
     }
     // bottom half of triangle
     YR = middle.y;
     XR = middle.x;
     for(;;){
        if(YL == YR) {
          //if(ZL < 0 || ZR < 0) {
            println("RIGHT BOTTOM XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
          //  break;
          //}
          drawSLine(XL, XR, ZL, ZR, YL);
              if (YL >= bottom.y) break;
      }
        E2L = ETB;
        E2R = EMB;
        // if the left line is not matching the right then increment the equation until it matches
        if(YL <= YR) {
            if (E2L >-DTB.x) { ETB -= DTB.y; XL += STB.x; }
            if (E2L < DTB.y) { ETB += DTB.x; YL += STB.y; }

            if (E2Lz >-DTB.z) { ETBz -= DTB.y; ZL += STB.z; }
            if (E2Lz < DTB.y) { ETBz += DTB.z;}
        }
        // if the right line is not matching the left then increment the equation until it matches
        else if (YL > YR) {
            if (E2R >-DMB.x) { EMB -= DMB.y; XR += SMB.x; }
            if (E2R < DMB.y) { EMB += DMB.x; YR += SMB.y; }

            if (E2Rz >-DMB.z) { EMBz -= DMB.y; ZR += SMB.z; }
            if (E2Rz < DMB.y) { EMBz += DMB.z;}
        }
     }
  }
  // Case with middle point on left side of triangle
  else { //<>// //<>//
        print("POINTING LEFT  TOP (" + nfs(top.x,3) + "," + nfs(top.y,3) + "," + nfs(top.z,3) +
                          ") MID (" + nfs(middle.x,3) + "," + nfs(middle.y,3) + "," + nfs(middle.z,3) +
                          ") BOT (" + nfs(bottom.x,3) + "," + nfs(bottom.y,3) + "," + nfs(bottom.z,3) + ") \n");

     // top half of triangle //<>// //<>//
     for(;;){
        if(YL == YR) {
            //  if(ZL < 0 || ZR < 0) {
              println("LEFT TOP XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
            //    break;
              //}
              drawSLine(XL, XR, ZL, ZR, YL);
              if (YR >= middle.y) break;
        }
        E2L = ETM;
        E2R = ETB;
        // if the left line is not matching the right then increment the equation until it matches
        if(YL <= YR) {
            if (E2L >-DTM.x) { ETM -= DTM.y; XL += STM.x; }
            if (E2L < DTM.y) { ETM += DTM.x; YL += STM.y; }
            if (E2Lz >-DTM.z) { ETMz -= DTM.y; ZL += STM.z; }
            if (E2Lz < DTM.y) { ETMz += DTM.z;}
        }
        // if the right line is not matching the left then increment the equation until it matches
        else if (YL > YR) {
            if (E2R >-DTB.x) { ETB -= DTB.y; XR += STB.x; }
            if (E2R < DTB.y) { ETB += DTB.x; YR += STB.y; }
            if (E2Rz >-DTB.z) { ETBz -= DTB.y; ZR += STB.z; }
            if (E2Rz < DTB.y) { ETBz += DTB.z;}
        }
     }
     // bottom half of triangle
     YL = middle.y;
     XL = middle.x;
     for(;;){
        if(YL == YR) {
              //if(ZL < 0 || ZR < 0) {
                println("LEFT BOTTOM XL " + XL + " XR " + XR + " ZL " + ZL + " ZR " + ZR + " Y " + YL);
              //  break;
              //}
              drawSLine(XL, XR, ZL, ZR, YL);
              if (YR >= bottom.y) break;
        }
        E2L = EMB;
        E2R = ETB;
        // if the left line is not matching the right then increment the equation until it matches
        if(YL <= YR) {
            if (E2L >-DMB.x) { EMB -= DMB.y; XL += SMB.x; }
            if (E2L < DMB.y) { EMB += DMB.x; YL += SMB.y; }
            if (E2Lz >-DMB.z) { EMBz -= DMB.y; ZL += SMB.z; }
            if (E2Lz < DMB.y) { EMBz += DMB.z;}
        }
        // if the right line is not matching the left then increment the equation until it matches
        else if (YL > YR) {
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

void drawSLine(int left_x, int right_x, int left_z, int right_z, int y){
      if(left_z < 0 || right_z < 0) { //<>//
        println(" left_Z: " + left_z + "right_Z: " + right_z);
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

      println(" LeftX: " + left_x + " RightX: " + right_x + " LeftZ: " + left_z + " RightZ: " + right_z + " DX: " + DeltaX + " DZ: " + DeltaZ + " SX: " +StepX + " SZ: " + StepZ + " Error: " + Error);

      for(;;) {
         if(z < 0) {
            println("Z went negative");
            //System.exit(1);
            pauseFlag = true;  //<>//
            break;
         }
         depthBufferIndex = x + (y * SCREEN_WIDTH); //<>//
         //print("LeftX: " + left_x + " RightX: " + right_x + "LeftZ: " + left_z + " RightZ: " + right_z + " DX: " + DeltaX + " DZ: " + DeltaZ + " SX: " +StepX + " SZ: " + StepZ + " Error: " + Error);
         //println(" db: " + depth_buffer[depthBufferIndex] + " x: " + x + " z: " + z  + " Error: " + Error);

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
          //print("\t\t::::AUTO-PAUSING::::\t\t");
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
