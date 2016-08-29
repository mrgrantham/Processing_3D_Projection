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