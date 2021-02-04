package minAreaTriangle.mathGeom;
// Constants
final MATRIX_START_INDEX = 1;
final PI = 3.14159265358979323846264338327950288419716939937510;
final epsilon = 0.00001;
final maxFloat = 1.79e+308; // https://api.haxeflixel.com/flixel/math/FlxMath.html
final POLYGON_POINT_TEST_THRESHOLD = 0.0001;
function greaterOrEqual( a: Float, b: Float ): Bool {
    return ( ( a > b ) || ( almostEqual( a, b ) ) );
}
function lessOrEqual( a: Float, b: Float ){
    return ( ( a < b ) || ( almostEqual( a, b ) ) );
}
function almostEqual( a: Float, b: Float ){
    return ( Math.abs( a - b ) <= ( epsilon * Math.max( 1.0, Math.max( Math.abs( a ), Math.abs( b ) ) ) ) );
}
function sign( v: Float ): Int {
    return ( v > 0.) ? 1 : ( ( v < 0. ) ? -1 : 0 );
}
class Numeric {
    public var greaterOrEqual_: ( a: Float, b: Float ) -> Bool = greaterOrEqual;
    public var lessOrEqual_:( a: Float, b: Float ) -> Bool = lessOrEqual;
    public var almostEqual_:( a: Float, b: Float ) -> Bool = almostEqual;
    public var sign_:( v: Float ) -> Int = sign;
    public final MATRIX_START_IDEX_: Int = MATRIX_START_INDEX;
    public final PI_: Float = PI;
    public final epsilon_: Float = epsilon;
    public final maxFloat_: Float = maxFloat;
    public final POLYGON_POINT_TEST_THRESHOLD_: Float = POLYGON_POINT_TEST_THRESHOLD;
}