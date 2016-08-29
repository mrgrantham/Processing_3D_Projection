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