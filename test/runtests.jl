
using Pkg
Pkg.activate( normpath(joinpath(@__DIR__, "..")) ) #activate this package

include("../src/Geometry2D.jl")
Geometry2D.testPoint2D()
Geometry2D.testVector2D()
Geometry2D.testTriangle2D()
Geometry2D.testCircle2D()
Geometry2D.testEllipse2D()
Geometry2D.testTransform2D()


; #don't return the last thing