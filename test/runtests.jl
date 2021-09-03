
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
  println("length= $(Geometry2D.length(vla))")
  return abs(Geometry2D.length(vla) - 10u"mm") < 1e-3u"mm"
end

@testset "test Geometry2D.Point" begin
  @test testPoint()
  @test testCircle()
  @test testVectorLengthAngle()
end

function test_ellipseCircle()
  major = 1u"m"
  minor = 1u"m"
  angle = deg2rad(45)u"rad"
  len = Geometry2D.ellipseArcLength(angle, major, minor)
  println(len)
  println(angle)
  return len == Geometry2D.circleArcLength(angle, major)
end

@testset "test ellipse length" begin
  @test test_ellipseCircle()
end