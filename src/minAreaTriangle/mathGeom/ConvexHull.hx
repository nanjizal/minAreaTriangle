package minAreaTriangle.mathGeom;
import minAreaTriangle.structure.Point2f;
class ConvexHull{
    public var orientation_:( pt1:Point2f, pt2: Point2f, pt3: Point2f ) -> Int = orientation;
    public var convexHull_: ( p: Array<Point2f> )-> Array<Point2f> = convexHull;
}

// from Nim - https://rosettacode.org/wiki/Convex_hull#Haxe
// Calculate orientation for 3 points
// 0 -> Straight line
// 1 -> Clockwise
// 2 -> Counterclockwise
inline
function orientation( pt1:Point2f, pt2: Point2f, pt3: Point2f ): Int {
    var val = ((pt2.x - pt1.x) * (pt3.y - pt1.y)) - 
              ((pt2.y - pt1.y) * (pt3.x - pt1.x));
    return if( val == 0 ){
        0;
    } else if( val > 0 ){
        1;
    } else {
        2;
    }
}

inline
function convexHull( p: Array<Point2f> ): Array<Point2f> {
    var result = new Array<Point2f>();
    // There must be at least 3 points
    if( p.length < 3) result = p.copy();
    // Find the leftmost point
    var m = 0;
    var len = ( p.length - 1 );
    for( i in 0...len ) if( p[ i ].x < p[ m ].x ) m = i;
    var q = 0;
    var n = m;
    while( true ) {
        // The leftmost point must be part of the hull.
        result[ result.length ] = p[ n ];
        q = (n + 1) % p.length;
        len = p.length - 1;
        for( i in 0...len ) if( orientation( p[ n ], p[ i ], p[ q ] ) == 2 ) q = i;
        n = q;
        // Break from loop once we reach the first point again.
        if( n == m ) break;
    }
    return result;
}