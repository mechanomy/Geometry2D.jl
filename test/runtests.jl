
using Test
using Unitful

include("../src/Geometry2D.jl")

# test rationale:
# - Uniful conversions are correct
# - math operations correct...?
function testPoint()
  p = Geometry2D.Point(1u"mm",2u"inch")
  return p.x == 1e-3u"m" && p.y == 50.8u"mm"
end
function testCircle()
  p = Geometry2D.Point(1u"mm",2u"inch")
  c = Geometry2D.Circle(p, 5u"mm")
  return c.center.x == 1u"mm" && c.center.y == 50.8u"mm" && c.radius == 5u"mm"
end
function testVectorLengthAngle()
  vla = Geometry2D.vectorLengthAngle( 10u"mm", 10u"rad" )
  return abs(Geometry2D.length(vla) - 10u"mm") < 1e-3u"mm"
end

@testset "test Geometry2D.Point" begin
  @test testPoint()
  @test testCircle()
  @test testVectorLengthAngle()
end

function test_circle2ellipseAngle_calc()
  rx = 2u"mm"
  ry = 1u"mm"
  a30 = 30u"°"
  e30 = Geometry2D.circular2EllipticalAngle(angle=a30, radiusX=rx, radiusY=ry)
  c30 = Geometry2D.elliptical2CircularAngle(angle=e30, radiusX=rx, radiusY=ry)
  # println("rx[$rx] ry[$ry] a30[$a30] e30[$e30] c30[$c30]")
  return abs(a30 - c30) < 1e-5

end

function test_circle2ellipseAngle_calc90()
  #circular and elliptical angles equal at 0 and 90s
  rx = 2u"mm"
  ry = 1u"mm"
  a90 = Geometry2D.circular2EllipticalAngle(angle=90u"°", radiusX=rx, radiusY=ry)
  a180 = Geometry2D.circular2EllipticalAngle(angle=180u"°", radiusX=rx, radiusY=ry)
  a270 = Geometry2D.circular2EllipticalAngle(angle=270u"°", radiusX=rx, radiusY=ry)
  a360 = Geometry2D.circular2EllipticalAngle(angle=360u"°", radiusX=rx, radiusY=ry)
  return a90 == 90u"°" && a180 == 180u"°" && a270 == 270u"°" && a360 == 360u"°"
end

function test_circle2ellipseAngle_quadrants()
  rx = 1u"mm"
  ry = rx
  q0 = Geometry2D.circular2EllipticalAngle(angle=-0u"°"-11u"°", radiusX=rx, radiusY=ry)
  q1 = Geometry2D.circular2EllipticalAngle(angle=0u"°"+11u"°", radiusX=rx, radiusY=ry)
  q2 = Geometry2D.circular2EllipticalAngle(angle=90u"°"+11u"°", radiusX=rx, radiusY=ry)
  q3 = Geometry2D.circular2EllipticalAngle(angle=180u"°"+11u"°", radiusX=rx, radiusY=ry)
  q4 = Geometry2D.circular2EllipticalAngle(angle=270u"°"+11u"°", radiusX=rx, radiusY=ry)
  q5 = Geometry2D.circular2EllipticalAngle(angle=360u"°"+11u"°", radiusX=rx, radiusY=ry)
  return q0 == -11u"°" && q1 == 11u"°" && q2 == 101u"°" && q3 == 191u"°" && q4 == 281u"°" && q5 == 371u"°"
end

function test_circle2ellipseAngle_deltas()
  #the difference in angles should be constant
  rx = 2u"mm"
  ry = 1u"mm"
  n010 = Geometry2D.circular2EllipticalAngle(angle=-10u"°", radiusX=rx, radiusY=ry)
  p010 = Geometry2D.circular2EllipticalAngle(angle=10u"°", radiusX=rx, radiusY=ry)
  p370 = Geometry2D.circular2EllipticalAngle(angle=370u"°", radiusX=rx, radiusY=ry) 
  n370 = Geometry2D.circular2EllipticalAngle(angle=-370u"°", radiusX=rx, radiusY=ry) 

  return (p010+n010) < 1e-3u"°" && (p370+n370) < 1e-3u"°"
end

@testset "circular2EllipticalAngle() tests" begin
  @test test_circle2ellipseAngle_calc()
  @test test_circle2ellipseAngle_calc90()
  @test test_circle2ellipseAngle_quadrants()
  @test test_circle2ellipseAngle_deltas()
end

# when the major == minor, we have a circle and expect that the ellipse length == circle arc length
function test_ellipseCircle()
  major = 1u"m"
  minor = 1u"m"
  angle = deg2rad(45)u"rad"
  len = Geometry2D.ellipseArcLength(stop=angle, radiusX=major, radiusY=minor)
  return len == Geometry2D.circleArcLength(angle, major)
end
function test_ellipseFullCircle()
  major = 1u"m"
  minor = 1u"m"
  angle = deg2rad(360)u"rad"
  len = Geometry2D.ellipseArcLength(stop=angle, radiusX=major, radiusY=minor)
  return len == Geometry2D.circleArcLength(angle, major)
end
function test_ellipseArcDirection()
  lp = Geometry2D.ellipseArcLength(start=10u"°", stop=20u"°", radiusX=1u"mm", radiusY=0.5u"mm")
  ln = Geometry2D.ellipseArcLength(start=20u"°", stop=10u"°", radiusX=1u"mm", radiusY=0.5u"mm")
  return lp == ln
end
function test_ellipseNegativeAngle()
  major = 2u"m"
  minor = 1u"m"
  angle = deg2rad(30)u"rad"
  lPos = Geometry2D.ellipseArcLength(stop=angle, radiusX=major, radiusY=minor)
  lNeg = Geometry2D.ellipseArcLength(stop=-angle, radiusX=major, radiusY=minor)
  return lPos == lNeg
end
function test_ellipseAngles()
  close("all")
  rx = 2u"mm"
  ry = 0.5u"mm"
  lArc1 = Geometry2D.ellipseArcLength(start=-10u"°", stop=10u"°", radiusX=rx, radiusY=ry, showConstruction=false)
  lArc2 = Geometry2D.ellipseArcLength(start=170u"°", stop=190u"°", radiusX=rx, radiusY=ry, showConstruction=false)
  return abs(lArc1 - lArc2) < 1e-3u"mm"
end
function testThrow_ellipseYNegative()
  Geometry2D.ellipseArcLength(stop=10u"°", radiusX=3u"mm", radiusY=-2u"mm")
  return true 
end
function testThrow_ellipseXNegative()
  Geometry2D.ellipseArcLength(stop=10u"°", radiusX=-3u"mm", radiusY=2u"mm")
  return true
end

@testset "ellipse length" begin
  @test test_ellipseCircle()
  @test test_ellipseFullCircle()
  @test test_ellipseArcDirection()
  @test test_ellipseNegativeAngle()
  @test test_ellipseAngles()

  @test_throws DomainError testThrow_ellipseXNegative()
  @test_throws DomainError testThrow_ellipseYNegative()
end
