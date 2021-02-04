package minAreaTriangle.mathGeom;
import minAreaTriangle.mathGeom.Numeric;
import minAreaTriangle.structure.Point2f;
class Geom2D{
    public static var angleOfLineWrtOxAxis_:( a: Point2f, b: Point2f ) -> Float = angleOfLineWrtOxAxis;
    public static var isAngleBetween_:( angle1: Float, angle2: Float, angle3: Float ) -> Bool = isAngleBetween;
    public static var isOppositeAngleBetween_:( angle1: Float, angle2: Float, angle3: Float ) -> Bool = isOppositeAngleBetween;
    public static var isAngleBetweenNonReflex_:( angle1: Float, angle2: Float, angle3: Float ) -> Bool = isAngleBetweenNonReflex;
    public static var isOppositeAngleBetweenNonReflex_:( angle1: Float, angle2: Float, angle3: Float ) -> Bool = isOppositeAngleBetweenNonReflex;
    public static var oppositeAngle_:( angle: Float )-> Float = oppositeAngle;
    public static var slopeOfLine_:( a: Point2f, b: Point2f, slope: Float ) -> Bool = slopeOfLine;
    public static var distanceBtwPoint2f_:( a: Point2f, b: Point2f ) -> Float = distanceBtwPoint2f;
    public static var distanceBtwPoints_:( x1: Float, y1: Float, x2: Float, y2: Float )-> Float = distanceBtwPoints;
    public static var distBtw_:( xd: Float, yd: Float ) -> Float = distBtw;
    public static var distanceFromPointToLine_:( a: Point2f, linePointB: Point2f, linePointC: Point2f ) -> Float = distanceFromPointToLine;
    public static var middlePoint_:( a: Point2f, b: Point2f )-> Point2f = middlePoint;
    public static var areOnTheSameSideOfLine_:( p1: Point2f, p2: Point2f, a: Point2f, b: Point2f ) -> Bool = areOnTheSameSideOfLine;
    public static var lineEquationDeterminedByPoints_:( p: Point2f, q: Point2f )-> { a: Float, b: Float, c: Float } = lineEquationDeterminedByPoints;
    public static var areIdenticalLines_: ( a1: Float, b1: Float, c1: Float
                              , a2: Float, b2: Float, c2: Float ) -> Bool = areIdenticalLines;
    public static var areIdenticalLines2f_: ( a1: Point2f, b1: Point2f, a2: Point2f, b2: Point2f ) -> Bool = areIdenticalLines2f;
    public static var lineIntersection2f_: ( a1: Point2f, b1: Point2f
                               , a2: Point2f, b2: Point2f
                               , intersection: Point2f ) -> Bool = lineIntersection2f;
    public static var lineIntersection_: ( a1: Float, b1: Float, c1: Float
                         , a2: Float, b2: Float, c2: Float
                         , intersection: Point2f ) -> Bool = lineIntersection;
    public static var angleBtwPoints_: ( a: Point2f, b: Point2f, c: Point2f ) -> Float = angleBtwPoints;
    public static var areaOfTriangle_: ( a: Point2f, b: Point2f, c: Point2f ) -> Float = areaOfTriangle;
    public static var isPointOnLineSegment_: ( point:            Point2f
                                 , lineSegmentStart: Point2f
                                 , lineSegmentEnd:   Point2f ) -> Bool = isPointOnLineSegment;
    public static var areEqualPoints_: ( p1: Point2f, p2: Point2f ) -> Bool = areEqualPoints;
    public static var areCollinear_: ( a: Point2f, b: Point2f, c: Point2f ) -> Bool = areCollinear;
    public static var isPointOnEdge_: ( p: Point2f, nrOfRows: Int, nrOfCols: Int ) -> Bool = isPointOnEdge;
    public static var translate_: ( point: Point2f, translation: Point2f )-> Point2f = translate;
    public static var inverseTranslate_:( point: Point2f, translation: Point2f ) -> Point2f = inverseTranslate;
}
function liteHit( px: Float, py: Float
                , ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float ): Bool {
    var planeAB = ( ax - px )*( by - py ) - ( bx - px )*( ay - py );
    var planeBC = ( bx - px )*( cy - py ) - ( cx - px )*( by - py );
    var planeCA = ( cx - px )*( ay - py ) - ( ax - px )*( cy - py );
    return sign( planeAB ) == sign( planeBC ) && sign( planeBC ) == sign( planeCA );
}
/*
function sign( n: Float ): Int {
    return Std.int( Math.abs( n )/n );
}
*/
function angleOfLineWrtOxAxis( a: Point2f, b: Point2f ): Float {
    var y = b.y - a.y;
    var x = b.x - a.x;
    var angle = ( Math.atan2( y, x ) * 180 / PI );
    return (angle < 0) ? (angle + 360): angle;
}
function isAngleBetween( angle1: Float, angle2: Float, angle3: Float ): Bool {
    if( ( Std.int( angle2 - angle3 )  % 180 ) > 0) {
        return ( angle3 < angle1 ) && ( angle1 < angle2 );
    } else {
        return ( angle2 < angle1 ) && ( angle1 < angle3 );
    }
}
function isOppositeAngleBetween( angle1: Float, angle2: Float, angle3: Float ): Bool {
    var angle1Opposite = oppositeAngle( angle1 );
    return isAngleBetween( angle1Opposite, angle2, angle3 );
}
function isAngleBetweenNonReflex( angle1: Float, angle2: Float, angle3: Float ): Bool {
    return if( Math.abs( angle2 - angle3 ) > 180 ){
        var lessEq360 = lessOrEqual( angle1, 360 );
        var lessEq0   = lessOrEqual( 0, angle1 );
        var _12   = angle1 < angle2;
        var _21   = angle2 < angle1;
        var _31   = angle3 < angle1;
        var _13   = angle1 < angle3;
        if( angle2 > angle3 ){
            ( _21 && lessEq360 ) || ( lessEq0 && _13 );
        } else {
            ( _31 && lessEq360 ) || ( lessEq0 && _12 );
        }
    } else {
        isAngleBetween(angle1, angle2, angle3);
    }
}
function isOppositeAngleBetweenNonReflex( angle1: Float, angle2: Float, angle3: Float ): Bool {
    var angle1Opposite = oppositeAngle( angle1 );
    return isAngleBetweenNonReflex( angle1Opposite, angle2, angle3 );
}
function oppositeAngle( angle: Float ): Float {
    return (angle > 180.) ? (angle - 180.) : (angle + 180.);
}
function slopeOfLine( a: Point2f, b: Point2f, slope: Float ): Bool {
    var nominator = b.y - a.y;
    var denominator = b.x - a.x;
    if( almostEqual( denominator, 0 ) ){
        return false;
    } else {
        slope = nominator / denominator;
        return true;
    }
}
function distanceBtwPoint2f( a: Point2f, b: Point2f ): Float {
    var xDiff = a.x - b.x;
    var yDiff = a.y - b.y;
    return distBtw( xDiff, yDiff );
}
function distanceBtwPoints( x1: Float, y1: Float, x2: Float, y2: Float ): Float {
    var xDiff = x1 - x2;
    var yDiff = y1 - y2;
    return distBtw( xDiff, yDiff );
}
function distBtw( xd: Float, yd: Float ): Float {
    var xd2 = xd*xd;
    var yd2 = yd*yd;
    return Math.sqrt( xd2 + yd2 );
}
function distanceFromPointToLine( a: Point2f, linePointB: Point2f, linePointC: Point2f ): Float {
    var term1 = linePointC.x - linePointB.x;
    var term2 = linePointB.y - a.y;
    var term3 = linePointB.x - a.x;
    var term4 = linePointC.y - linePointB.y;
    var nominator   = Math.abs(  (term1 * term2) - (term3 * term4) );
    var denominator = Math.sqrt( (term1 * term1) + (term4 * term4) );
    return nominator / denominator;
}
function middlePoint( a: Point2f, b: Point2f ): Point2f {
    var middleX = ( a.x + b.x ) / 2;
    var middleY = ( a.y + b.y ) / 2;
    return { x: middleX, y: middleY };
}
function areOnTheSameSideOfLine( p1: Point2f, p2: Point2f, a: Point2f, b: Point2f ): Bool {
    var a1 = 0.;
    var b1 = 0;
    var c1 = 0;
    var abc: { a: Float, b: Float, c: Float } = lineEquationDeterminedByPoints( a, b );
    var p1OnLine = ( abc.a * p1.x) + ( abc.b * p1.y) + abc.c;
    var p2OnLine = ( abc.a * p2.x) + ( abc.b * p2.y) + abc.c;

    return ( sign( p1OnLine ) == sign( p2OnLine ) );
}
function lineEquationDeterminedByPoints( p: Point2f, q: Point2f ): { a: Float, b: Float, c: Float } {
    //assert(Geometry2D::areEqualPoints(p, q) == false);
    var a = q.y - p.y;
    var b = p.x - q.x;
    return { a: a, b: b, c: ((-p.y) * b) - (p.x * a) };
}
function areIdenticalLines( a1: Float, b1: Float, c1: Float
                          , a2: Float, b2: Float, c2: Float ): Bool {
    var a1B2 = a1 * b2;
    var a2B1 = a2 * b1;
    var ab   = almostEqual( a1B2, a2B1 );
    var a1C2 = a1 * c2;
    var a2C1 = a2 * c1;
    var ac   = almostEqual( a1C2, a2C1 );
    var b1C2 = b1 * c2;
    var b2C1 = b2 * c1;
    var bc   = almostEqual( b1C2, b2C1 );
    return ab && bc && ac;
}
function areIdenticalLines2f( a1: Point2f, b1: Point2f, a2: Point2f, b2: Point2f ): Bool {
    var A1 = b1.y - a1.y;
    var B1 = a1.x - b1.x;
    var C1 = (a1.x * A1) + (a1.y * B1);
    var A2 = b2.y - a2.y;
    var B2 = a2.x - b2.x;
    var C2 = (a2.x * A2) + (a2.y * B2);
    return areIdenticalLines( A1, B1, C1, A2, B2, C2 );
}
function lineIntersection2f( a1: Point2f, b1: Point2f
                           , a2: Point2f, b2: Point2f
                           , intersection: Point2f ): Bool {
    var A1  = b1.y - a1.y;
    var B1  = a1.x - b1.x;
    var C1  = a1.x * A1 + a1.y * B1;
    var A2  = b2.y - a2.y;
    var B2  = a2.x - b2.x;
    var C2  = a2.x * A2 + a2.y * B2;
    var det = A1 * B2 - A2 * B1;
    return if( almostEqual( det, 0 ) ){
                intersection.x = ( C1 * B2 - C2 * B1 ) / det;
                intersection.y = ( C2 * A1 - C1 * A2 ) / det;
                true;
            } else {
                false;
            }
}
function lineIntersection( a1: Float, b1: Float, c1: Float
                         , a2: Float, b2: Float, c2: Float
                         , intersection: Point2f ): Bool {
    var det = (a1 * b2) - (a2 * b1);
    return if( almostEqual( det, 0) ){
                intersection.x = ( c1 * b2 - c2 * b1) / det;
                intersection.y = ( c2 * a1 - c1 * a2) / det;
                true;
            } else {
                false;
            }
}
function angleBtwPoints( a: Point2f, b: Point2f, c: Point2f ): Float {
    var ab: Point2f  = { x: b.x - a.x, y: b.y - a.y };
    var cb: Point2f  = { x: b.x - c.x, y: b.y - c.y };
    var dotProduct   = ab.x * cb.x + ab.y * cb.y;
    var crossProduct = ab.x * cb.y - ab.y * cb.x;
    var alpha = Math.atan2( crossProduct, dotProduct );
    return Math.abs( (alpha * 180.) / PI );
}
function areaOfTriangle( a: Point2f, b: Point2f, c: Point2f ): Float {
    var posTerm = a.x * b.y + a.y * c.x + b.x * c.y;
    var negTerm = b.y * c.x + a.x * c.y + a.y * b.x;
    var determinant = posTerm - negTerm;
    return Math.abs( determinant )/2;
}
function isPointOnLineSegment( point:            Point2f
                             , lineSegmentStart: Point2f
                             , lineSegmentEnd:   Point2f ): Bool {
    var d1 = distanceBtwPoint2f( point, lineSegmentStart );
    var d2 = distanceBtwPoint2f( point, lineSegmentEnd   );
    var lineSegmentLength = distanceBtwPoint2f( lineSegmentStart, lineSegmentEnd );
    return almostEqual( d1 + d2, lineSegmentLength );
}
function areEqualPoints( p1: Point2f, p2: Point2f ): Bool {
    return almostEqual( p1.x, p2.x ) && almostEqual( p1.y, p2.y );
}
function areCollinear( a: Point2f, b: Point2f, c: Point2f ): Bool {
    var determinant = a.x*b.y + c.x*a.y + b.x * c.y - c.x*b.y - a.x*c.y - b.x * a.y;
    return almostEqual( determinant, 0 );
}
function isPointOnEdge( p: Point2f, nrOfRows: Int, nrOfCols: Int ): Bool {
    return (
              ((p.x <= MATRIX_START_INDEX) && (p.y > MATRIX_START_INDEX) && (p.y < nrOfCols)) ||
              ((p.x >= nrOfRows) && (p.y > MATRIX_START_INDEX) && (p.y < nrOfCols)) ||
              ((p.y <= MATRIX_START_INDEX) && (p.x > MATRIX_START_INDEX) && (p.x < nrOfRows)) ||
              ((p.y >= nrOfCols) && (p.x > MATRIX_START_INDEX) && (p.x < nrOfRows))
           );
}
function translate( point: Point2f, translation: Point2f ): Point2f {
    point.x += translation.x;
    point.y += translation.y;
    return point;
}
function inverseTranslate( point: Point2f, translation: Point2f ): Point2f {
    point.x += translation.x;
    point.y += translation.y;
    return point;
}

/*
template <typename T, typename U>
bool Geometry2D::isBetweenCoordinates(T c, U c1, U c2) {
    return ((std::min(c1, c2) <= c) && (c <= std::max(c1, c2)));
}
*/
