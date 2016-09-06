POINT Translate3D(POINT translationVector, POINT oringinalPoint) {
    POINT tempPoint = new POINT();

    tempPoint.x = translationVector.x + oringinalPoint.x;
    tempPoint.y = translationVector.y + oringinalPoint.y;
    tempPoint.z = translationVector.z + oringinalPoint.z;

    return tempPoint;
}
