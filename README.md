# minAreaTriangle
Port of minimal-Area-Triangle from C++ to Haxe.  
https://github.com/ovidiuparvu/minimal-area-triangle   
Initial Dox working ( proves that typing is reasonable and removed many obvious typo errors ),  
but not yet tested to see if library is currently correct, or even in anyway useful.  

Generated Documentation  
https://nanjizal.github.io/minAreaTriangle/pages/index.html

To avoid OpenCV dependancy and to allow MIT license:
- replaced ConvexHull code for some I found and tweaked from rosetta, which I think was based on some rust, signiture is different but think should be suitable.
- Swapped the point within or on edge of triangle code distance for some simpler code that checks if point within triangle, may result in slightly larger triangle hopefully would still work.
