package minAreaTriangle.finder.enclosing;
import minAreaTriangle.mathGeom.Geom2D;
import minAreaTriangle.mathGeom.Numeric;
import minAreaTriangle.structure.Point2f;

class BruteForce extends Linear {
    public static inline var PARALLEL_TRIANGLE_SIDES = "At least two sides of the triangle are parallel when they should be intersecting. Please change.";

    public function new(){
        super();
        c = 0;
        a = 0;
        b = 0;
    }
    override
    public function findMinEnclosingTriangle( minTri: Array<Point2f>, minArea: Float ): Float {
        for( c in 0...nrOfPoints ){
            for( a in 0...nrOfPoints ){
                if( areValidIntersectingLines( predecessor( a ), a, predecessor( c ), c ) ){
                    for( b in 0...nrOfPoints ){
                        if( areValidPolygonPoints( c, a, b ) ){
                            findMinEnclosingTriangleTangentSideB( minTri, minArea );
                            findMinEnclosingTriangleFlushSideB( minTri, minArea );
                        }
                    }
                
                }
            }
        }
        return minArea;
    }
    public function areValidIntersectingLines( firstLineFirstIndex:   Int
                                             , firstLineSecondIndex:  Int
                                             , secondLineFirstIndex:  Int
                                             , secondLineSecondIndex: Int ): Bool {
        return if( firstLineFirstIndex  != secondLineFirstIndex 
            ||
            firstLineSecondIndex != secondLineSecondIndex )
            {
                lineIntersection2f( polygon[ firstLineFirstIndex ]
                               , polygon[ firstLineSecondIndex ]
                               , polygon[ secondLineFirstIndex ]
                               , polygon[ secondLineSecondIndex ]
                               , vertexB );
            } else {
                false;
            }
    }
    public function areValidPolygonPoints( firstPolygonPointIndex:  Int
                                         , secondPolygonPointIndex: Int
                                         , thirdPolygonPointIndex:  Int ) {
        return firstPolygonPointIndex  != secondPolygonPointIndex 
               &&
               firstPolygonPointIndex  != thirdPolygonPointIndex
               &&
               secondPolygonPointIndex != thirdPolygonPointIndex;
    }
    public function findMinEnclosingTriangleTangentSideB( minTri: Array<Point2f>, minArea: Float ) {
        if( b != predecessor( c ) && b != predecessor(a) ){
            var sideCParameters = lineEquationParameters( polygon[ predecessor( c ) ], polygon[ c ] );
            var sideAParameters = lineEquationParameters( polygon[ predecessor( a ) ], polygon[ a ] );
            findMinEnclosingTriangleTangentSideB_( sideCParameters, sideAParameters, minTri, minArea );
        }
    }
    // need to work out naming but added _ to stop class from original c code.
    public function findMinEnclosingTriangleTangentSideB_( sideCParameters: Array<Float>
                                                         , sideAParameters: Array<Float>
                                                         , minTri:          Array<Point2f>
                                                         , minArea:         Float ){
        if( areParallelLines( sideCParameters, sideAParameters ) ){
            throw new haxe.Exception( PARALLEL_TRIANGLE_SIDES );
        } else {
            updateVerticesCAndA( sideCParameters, sideAParameters );
            if( isValidTangentSideB() ){
                computeEnclosingTriangle( minTri, minArea );
            }
        }
    }
    public function findMinEnclosingTriangleFlushSideB( minTri: Array<Point2f>, minArea: Float ){
        // If vertices A and C exist
        if( lineIntersection2f( polygon[ predecessor( b ) ], polygon[ b ]
                            , polygon[ predecessor( c ) ], polygon[ c ], vertexA )
            &&
            lineIntersection2f( polygon[ predecessor( a ) ], polygon[ a ]
                            , polygon[ predecessor( b ) ], polygon[ b ], vertexC ) ){
                computeEnclosingTriangle( minTri, minArea );
        }
    }
    public function areParallelLines( sideC: Array<Float>, sideA: Array<Float> ){
        var determinant = sideC[0] * sideA[1] - sideA[0] * sideC[1];
        return almostEqual( determinant, 0 );
    }
    public function updateVerticesCAndA( sideCParameters: Array<Float>, sideAParameters: Array<Float> ){
        // Side A parameters
        var a1 = sideCParameters[ 0 ];
        var b1 = sideCParameters[ 1 ];
        var c1 = sideCParameters[ 2 ];
        // Side B parameters
        var a2 = sideAParameters[ 0 ];
        var b2 = sideAParameters[ 1 ];
        var c2 = sideAParameters[ 2 ];
        // Polygon point "b" coordinates
        var m = polygon[ b ].x;
        var n = polygon[ b ].y;

        // Compute vertices A and C x-coordinates
        var x2 = (( 2 * b1 * b2 * n ) + ( c1 * b2 ) + ( 2 * a1 * b2 * m ) + ( b1 * c2 )) / (( a1 * b2 ) - ( a2 * b1 ));
        var x1 = ( 2 * m ) - x2;
        // Compute vertices A and C y-coordinates
        var y2 = 0.;
        var y1 = 0.;
        if( almostEqual( b1, 0 ) ){          // b1 = 0 and b2 != 0
            y2 = ( -c2 - a2 * x2 ) / b2;
            y1 = (2 * n) - y2;
        } else if ( almostEqual( b2, 0 ) ){   // b1 != 0 and b2 = 0
            y1 = ( -c1 - a1 * x1 ) / b1;
            y2 = (2 * n) - y1;
        } else {                                    // b1 != 0 and b2 != 0
            y1 = ( -c1 - a1 * x1 ) / b1;
            y2 = ( -c2 - a2 * x2 ) / b2;
        }
        // Update vertices A and C coordinates
        vertexA.x = x1;
        vertexA.y = y1;
        vertexC.x = x2;
        vertexC.y = y2;
    }
    public function isValidTangentSideB() {
        var angleOfTangentSideB  = angleOfLineWrtOxAxis( vertexC, vertexA);
        var anglePredecessor     = angleOfLineWrtOxAxis( polygon[ predecessor( b ) ], polygon[ b ] );
        var angleSuccessor       = angleOfLineWrtOxAxis( polygon[ b ], polygon[successor( b ) ] );
        return (
            isAngleBetweenNonReflex( angleOfTangentSideB, anglePredecessor, angleSuccessor )
            ||
            isOppositeAngleBetweenNonReflex( angleOfTangentSideB, anglePredecessor, angleSuccessor ) );
    }
    public function computeEnclosingTriangle( minTri: Array<Point2f>, minArea: Float ) {
        if( isValidMinimalTriangle() ){
            updateMinEnclosingTriangle( minTri, minArea );
        }
    }
    override
    public function isValidMinimalTriangle() {
        //var currentMinTri = [ vertexA, vertexB, vertexC ];
        // Check if all polygon points are contained by the triangle
        for( i in 0...nrOfPoints ) {
            // may need to adjust to allow edges?
            if( !liteHit( polygon[i].x, polygon[i].y
                , vertexA.x, vertexA.y, vertexB.x, vertexB.y, vertexC.x, vertexC.y ) ){
                return false;
            }
            /* removed as required Open:Cv.
            var distance = pointPolygonTest( currentMinTri, polygon[i], true );
            if (distance < -POLYGON_POINT_TEST_THRESHOLD ) {
                return false;
            }*/
        }
        return true;
    }
}