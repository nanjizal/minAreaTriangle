package minAreaTriangle.finder.enclosing;
import minAreaTriangle.mathGeom.Geom2D;
import minAreaTriangle.mathGeom.Numeric;
import minAreaTriangle.structure.Point2f;
import minAreaTriangle.finder.enclosing.TriFinder;
enum abstract Intersects( Int ) from Int to Int {
    var NONE;
    var BELOW;
    var ABOVE;
    var CRITICAL;
    var LIMIT;
    var NOT_SURE; // TODO: Investigate
}
enum abstract Validation( Int ) from Int to Int {
    var SIDE_NONE;
    var SIDE_A_TANGENT;
    var SIDE_B_TANGENT;
    var SIDE_FLUSH;
}
enum abstract LinearError( String ) from String to String {
    var MIDPOINT_SIDE_B         = "The position of the middle point of side B could not be determined.";
    var SIDE_B_GAMMA            = "The position of side B could not be determined,"
                                + "because gamma(b) could not be computed.";
    var VERTEX_C_ON_SIDE_B      = "The position of the vertex C on side B could not be determined,"
                                + " because the considered lines do not intersect.";
}
class Linear extends TriFinder{
    var validationFlag: Validation = SIDE_NONE;/*!< Validation flag can take the following values:
                                                  - VALIDATION_SIDE_A_TANGENT;
                                                  - VALIDATION_SIDE_B_TANGENT;
                                                  - VALIDATION_SIDES_FLUSH.
                                             */
    var a = 0;                           /*!< Index of point "a"; see paper for more details */
    var b = 0;                           /*!< Index of point "b"; see paper for more details */
    var c = 0;                           /*!< Index of point "c"; see paper for more details */
    var sideAstart: Point2f;       /*!< Starting vertex for side A of triangle */
    var sideAend:   Point2f;       /*!< Ending vertex for side A of triangle */
    var sideBstart: Point2f;       /*!< Starting vertex for side B of triangle */
    var sideBend:   Point2f;       /*!< Ending vertex for side B of triangle */
    var sideCstart: Point2f;       /*!< Starting vertex for side C of triangle */
    var sideCend:   Point2f;       /*!< Ending vertex for side C of triangle */
    public function new(){
        super();
    }
    public function initialiseAlgorithmVariables() {
        nrOfPoints = polygon.length;
        a = 1;
        b = 2;
        c = 0;
    }
    override
    public function findMinEnclosingTriangle( minTri: Array<Point2f>, minArea: Float ): Float {
        for( c in 0...nrOfPoints ){
            advanceBToRightChain();
            moveAIfLowAndBIfHigh();
            searchForBTangency();
            updateSidesCA();
            if (isNotBTangency()) {
                updateSidesBA();
            } else {
                updateSideB();
            }
            if( isLocalMinimalTriangle() ){
                minArea = updateMinEnclosingTriangle( minTri, minArea );
            }
        }
        return minArea;
    }
    public function advanceBToRightChain(){
        while( greaterOrEqual( height( successor(b) ), height( b ) ) ){
            advance( b );
        }
    }
    public function moveAIfLowAndBIfHigh(){
        while( height( b ) > height( a ) ){
            var gammaOfA = new Point2f( 0, 0 );
            var g = gamma( b, gammaOfA );
            if( g.val && intersectsBelow( g.gammaPoint, b ) ){
                advance( b );
            } else {
                advance( a );
            }
        }
    }
    public function searchForBTangency() {
         var gammaOfB = new Point2f( 0, 0 );
         var g = gamma( b, gammaOfB );
         while( 
                ( 
                    g.val
                    &&
                    intersectsBelow( g.gammaPoint, b )
                )
                &&
                greaterOrEqual( height( b ), height( predecessor( a ) ) )
             ){
                 advance( b );
             }
    }
    public function isNotBTangency() {
        var gammaOfB = new Point2f( 0, 0 );
        var g = gamma( b, gammaOfB );
        if( 
            ( 
                g.val
                &&
                intersectsAbove( g.gammaPoint, b )
             ) 
             || 
             height( b ) < height( predecessor( a ) )
            ){
            return true;
        }
        return false;
    }
    public function updateSidesCA(){
        sideCstart = polygon[ predecessor( c ) ];
        sideCend   = polygon[ c ];
        sideAstart = polygon[ predecessor( a ) ];
        sideAend   = polygon[ a ];
    }
    public function updateSidesBA(){
        // Side B is flush with edge [b, b-1]
        sideBstart = polygon[ predecessor( b ) ];
        sideBend   = polygon[ b ];
        // Find middle point of side B
        var sideBMiddlePoint = new Point2f( 0, 0 );
        if( middlePointOfSideB( sideBMiddlePoint ) 
            &&
            height2f( sideBMiddlePoint ) < height( predecessor( a ) )
            ){
            sideAstart = polygon[ predecessor( a ) ];
            sideAend   = findVertexCOnSideB();
            validationFlag = SIDE_A_TANGENT;
        } else {
            validationFlag = SIDE_FLUSH;
        }
    }
    public function updateSideB(){
        var g = gamma( b, sideBstart );
        if( !g.val ) throw new haxe.Exception( SIDE_B_GAMMA );
        sideBend = polygon[ b ];
        validationFlag = SIDE_B_TANGENT;
    }
    public function isLocalMinimalTriangle(){
        return 
            if (   lineIntersection2f( sideAstart, sideAend, sideBstart, sideBend, vertexC ) 
                ||
                   lineIntersection2f( sideAstart, sideAend, sideCstart, sideCend, vertexB )
                ||
                   lineIntersection2f( sideBstart, sideBend, sideCstart, sideCend, vertexA )
                ){
                    false;
                } else {
                    isValidMinimalTriangle();
                }
    }
    public function isValidMinimalTriangle() {
        var midpointSideA = middlePoint( vertexB, vertexC );
        var midpointSideB = middlePoint( vertexA, vertexC );
        var midpointSideC = middlePoint( vertexA, vertexB );
        var sideAValid    = if( validationFlag == SIDE_A_TANGENT ){ 
                                areEqualPoints( midpointSideA, polygon[ predecessor( a ) ] );
                            } else {
                                isPointOnLineSegment( midpointSideA, sideAstart, sideAend );
                            }
        var sideBValid    = if( validationFlag == SIDE_B_TANGENT ){
                                  areEqualPoints( midpointSideB, polygon[ b ] );
                            } else {
                                  isPointOnLineSegment( midpointSideB, sideBstart, sideBend );
                            }
        var sideCValid    = isPointOnLineSegment( midpointSideC, sideCstart, sideCend );
        return sideAValid && sideBValid && sideCValid;
    }
    public function middlePointOfSideB( middlePoint: Point2f ): Bool {
        vertexA = new Point2f( 0, 0 );
        vertexB = new Point2f( 0, 0 );
        return if( !Geom2D.lineIntersection2f_( sideBstart, sideBend, sideCstart, sideCend, vertexA )
          ||
            !Geom2D.lineIntersection2f_( sideBstart, sideBend, sideAstart, sideAend, vertexC )
            ){
                false;
            } else {
                middlePoint = Geom2D.middlePoint_( vertexA, vertexC );
                true;
            }
    }
    public function intersectsBelow( gammaPoint: Point2f, polygonPointIndex: Int ): Bool {
        var angleOfGammaAndPoint = angleOfLineWrtOxAxis( polygon[ polygonPointIndex ], gammaPoint );
        return intersects( angleOfGammaAndPoint, polygonPointIndex ) == BELOW;
    }
    public function intersectsAbove( gammaPoint: Point2f, polygonPointIndex: Int ): Bool {
        var angleOfGammaAndPoint = angleOfLineWrtOxAxis( gammaPoint, polygon[ polygonPointIndex ] );
        return intersects( angleOfGammaAndPoint, polygonPointIndex ) == ABOVE;
    }
    public function intersects( angleOfGammaAndPoint: Float, polygonPointIndex: Int ): Intersects {
        var a = polygon[ predecessor( polygonPointIndex ) ];
        var b =  polygon[ polygonPointIndex ];
        var angleOfPointAndPredecessor = angleOfLineWrtOxAxis( a, b );
            a = polygon[ successor( polygonPointIndex ) ];
            b = polygon[ polygonPointIndex ]; // not sure if need to set this again.
        var angleOfPointAndSuccessor =  angleOfLineWrtOxAxis( a, b );
            a = polygon[ predecessor( c ) ];
            b = polygon[ c ];
        var angleOfFlushEdge = angleOfLineWrtOxAxis( a, b );
        var checkAngle = isFlushAngleBetweenPredecessorAndSuccessor( angleOfFlushEdge
                                                                   , angleOfPointAndPredecessor
                                                                   , angleOfPointAndSuccessor );
        angleOfFlushEdge = checkAngle.angle;
        return 
            if( checkAngle.val ){
                if( isGammaAngleBetween( angleOfGammaAndPoint, angleOfPointAndPredecessor, angleOfFlushEdge ) 
                    ||
                    almostEqual( angleOfGammaAndPoint, angleOfPointAndPredecessor )
                ){
                    intersectsAboveOrBelow( predecessor( polygonPointIndex ), polygonPointIndex );
                } else if( 
                    isGammaAngleBetween( angleOfGammaAndPoint, angleOfPointAndSuccessor, angleOfFlushEdge  )
                    ||
                    almostEqual( angleOfGammaAndPoint, angleOfPointAndSuccessor )
                           ){
                               intersectsAboveOrBelow(successor(polygonPointIndex), polygonPointIndex);
                } else {
                    if (    isGammaAngleBetween( angleOfGammaAndPoint, angleOfPointAndPredecessor, angleOfPointAndSuccessor )
                        ||
                        ( isGammaAngleEqualTo( angleOfGammaAndPoint, angleOfPointAndPredecessor ) 
                            && !isGammaAngleEqualTo( angleOfGammaAndPoint, angleOfFlushEdge) ) 
                        ||
                        ( isGammaAngleEqualTo( angleOfGammaAndPoint, angleOfPointAndSuccessor )
                            && !isGammaAngleEqualTo( angleOfGammaAndPoint, angleOfFlushEdge ) )
                        ){
                            BELOW;
                        } else {
                            NOT_SURE;
                        }
                }
            } else {
                CRITICAL;
            }
    }
    public function intersectsAboveOrBelow( successorOrPredecessorIndex: Int, pointIndex: Int ): Intersects {
        return if( height( successorOrPredecessorIndex ) > height( pointIndex ) ){
            ABOVE;
        } else {
            BELOW;
        }
    }
    public function isFlushAngleBetweenPredecessorAndSuccessor( angleFlushEdge:   Float
                                                              , anglePredecessor: Float
                                                              , angleSuccessor:   Float ): { angle: Float, val: Bool }{
    return if( isAngleBetweenNonReflex( angleFlushEdge, anglePredecessor, angleSuccessor ) ){
               { angle: angleFlushEdge, val: true };
           } else if( isOppositeAngleBetweenNonReflex( angleFlushEdge, anglePredecessor, angleSuccessor ) ){
               angleFlushEdge = cast oppositeAngle( angleFlushEdge );
               { angle: angleFlushEdge, val: true };
           } else {
              { angle: angleFlushEdge, val: false };
           }
     }
     public function isGammaAngleBetween( gammaAngle: Float, angle1: Float, angle2: Float ): Bool {
         return isAngleBetweenNonReflex( gammaAngle, angle1, angle2 );
     }
     public function isGammaAngleEqualTo( gammaAngle: Float, angle: Float ) {
         return almostEqual( gammaAngle, angle );
     }
     public function height( polygonPointIndex: Int ): Float {
         var pointC = polygon[ c ];
         var pointCPredecessor = polygon[ predecessor( c ) ];
         var polygonPoint = polygon[ polygonPointIndex ];
         return distanceFromPointToLine( polygonPoint, pointC, pointCPredecessor );
     }
     public function height2f( polygonPoint: Point2f ): Float {
         var pointC = polygon[c];
         var pointCPredecessor = polygon[predecessor(c)];
         return distanceFromPointToLine( polygonPoint, pointC, pointCPredecessor );
     }
     public function gamma( polygonPointIndex: Int, gammaPoint: Point2f ): { gammaPoint: Point2f, val: Bool } {
         var intersect1 = new Point2f( 0., 0. );
         var intersect2 = new Point2f( 0., 0. );
         // Get intersection points if they exist
         if( !findGammaIntersectionPoints( polygonPointIndex, polygon[ a ], polygon[predecessor( a ) ], polygon[ c ],
                                           polygon[ predecessor( c ) ], intersect1, intersect2 )
         ){
             return { gammaPoint: gammaPoint, val: false };
         }
         // Select the point which is on the same side of line C as the polygon
         if( areOnTheSameSideOfLine( intersect1, polygon[ successor( c ) ]
                                   , polygon[ c ], polygon[ predecessor( c ) ] )
         ){
             gammaPoint = intersect1;
         } else {
             gammaPoint = intersect2;
         }
         return { gammaPoint: gammaPoint, val: true };
     }
     public function findVertexCOnSideB() {
         var intersect1 = new Point2f( 0., 0. );
         var intersect2 = new Point2f( 0., 0. );
         // Get intersection points if they exist
         if( !findGammaIntersectionPoints( predecessor(a), sideBstart, sideBend, sideCstart,
                                          sideCend, intersect1, intersect2 ) 
        ){
             throw new haxe.Exception( VERTEX_C_ON_SIDE_B );
         }

         // Select the point which is on the same side of line C as the polygon
         if( areOnTheSameSideOfLine( intersect1, polygon[successor(c)], polygon[c], polygon[predecessor(c)])
         ){
             return intersect1;
         } else {
             return intersect2;
         }
     }
     // not ideal has side effect on intersect1 and intersect2
     public function findGammaIntersectionPoints( polygonPointIndex: Int
                                                , side1StartVertex: Point2f, side1EndVertex: Point2f
                                                , side2StartVertex: Point2f, side2EndVertex: Point2f
                                                , intersect1:       Point2f, intersect2:     Point2f ): Bool {
         var side1Params = lineEquationParameters( side1StartVertex, side1EndVertex );
         var side2Params = lineEquationParameters( side2StartVertex, side2EndVertex );
         // Compute side C extra parameter using the formula for distance from a point to a line
         var polygonPointHeight = height( polygonPointIndex );
         var distanceFormulaDenominator = Math.sqrt( side2Params[0] * side2Params[0] + side2Params[1] * side2Params[1] );
         var sideCExtraParam = 2 * polygonPointHeight * distanceFormulaDenominator;
         // Get intersection points if they exist or if lines are identical
         if( !areIntersectingLines( side1Params, side2Params, sideCExtraParam, intersect1, intersect2 )
         ){
             return false;
         } else if ( areIdenticalLines(side1Params, side2Params, sideCExtraParam ) ){
             intersect1 = side1StartVertex;
             intersect2 = side1EndVertex;
         }
         return true;
     }
}