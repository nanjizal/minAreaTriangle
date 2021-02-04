package minAreaTriangle.finder.enclosing;
import minAreaTriangle.mathGeom.Geom2D;
import minAreaTriangle.mathGeom.Numeric;
import minAreaTriangle.structure.Point2f;
import minAreaTriangle.mathGeom.ConvexHull;

class TriFinder {
    final CONVEX_HULL_CLOCKWISE = true;
    var area       = 0.;
    var nrOfPoints = 0;
    var vertexA    = new Point2f( 0, 0 );
    var vertexB    = new Point2f( 0, 0 );
    var vertexC    = new Point2f( 0, 0 );
    var polygon:   Array<Point2f>; // ???
    var points: Array<Point2f>;
    public function new(){}
    public
    function find( points: Array<Point2f>, minTri: Array<Point2f> ): Float {
        if( points.length == 0 ) throw new haxe.Exception( 'no points' );
        polygon = convexHull( points );
        return if( polygon.length > 3) {
            findMinEnclosingTriangle( minTri, maxFloat );
        } else {
            returnMinEnclosingTriangle( minTri );
        }
    }
    // overide in subclass don't used directly.
    public 
    function findMinEnclosingTriangle( minTri: Array<Point2f>, minArea: Float ): Float {
        return minArea;
    }
    public
    function returnMinEnclosingTriangle( minTri: Array<Point2f> ){
        var nrOfPolygonPoints = polygon.length;
        for( i in 0...3 ){
            minTri.push( polygon[i % nrOfPolygonPoints] );
        }
        return areaOfTriangle( minTri[ 0 ], minTri[ 1 ], minTri[ 2 ] );
    }
    public 
    function updateMinEnclosingTriangle( minTri: Array<Point2f>, minArea: Float ): Float {
        area = areaOfTriangle( vertexA, vertexB, vertexC );
        if( area < minArea ){
            minTri = new Array<Point2f>();
            minTri[0] = vertexA;
            minTri[1] = vertexB;
            minTri[2] = vertexC;
            minArea = area;
        }
        return minArea;
    }
    public
    function areIdenticalLines( s1: Array<Float>, s2: Array<Float>, sideCExtraParam: Float ): Bool {
        var check0: Bool = Geom2D.areIdenticalLines_( s1[0], s1[1], -(s1[2])
                                            , s2[0], s2[1], -(s2[2]) - sideCExtraParam );
        var check1: Bool = Geom2D.areIdenticalLines_( s1[0], s1[1], -s1[2], s2[0]
                                            , s2[1], -s2[2] + sideCExtraParam );
        return check0 || check1;
    }
    public
    function areIntersectingLines( s1: Array<Float>, s2: Array<Float>
                                , sideCExtraParam: Float
                                , intersect1: Point2f, intersect2: Point2f ): Bool {
        var check0: Bool = lineIntersection( s1[0], s1[1], -s1[2], s2[0]
                                           , s2[1], -s2[2] - sideCExtraParam, intersect1 );
        var check1: Bool = lineIntersection( s1[0], s1[1], -s1[2], s2[0]
                                           , s2[1], -s2[2] + sideCExtraParam, intersect2 );
        return check0 && check1;
    }
    public
    function lineEquationParameters( p: Point2f, q: Point2f ): Array<Float> {
        var parametersLineEquation = new Array<Float>();
        var abc = lineEquationDeterminedByPoints( p, q );
        parametersLineEquation[0] = abc.a;
        parametersLineEquation[1] = abc.b;
        parametersLineEquation[2] = abc.c;
        return parametersLineEquation;
    }
    public
    function advance( index: Int ): Int {
        index = successor(index);
        return index;
    }
    public
    function successor( index: Int ): Int {
        return (index + 1) % nrOfPoints;
    }
    public
    function predecessor( index: Int ): Int {
        return (index == 0)? nrOfPoints - 1: index - 1;
    }
}