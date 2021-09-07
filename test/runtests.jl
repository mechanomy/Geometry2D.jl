
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

# when the major == minor, we have a circle and expect that the ellipse length == circle arc length
function test_ellipseCircle()
  major = 1u"m"
  minor = 1u"m"
  angle = deg2rad(45)u"rad"
  len = Geometry2D.ellipseArcLength(angle, major, minor)
  return len == Geometry2D.circleArcLength(angle, major)
end

function test_ellipseFullCircle()
  major = 1u"m"
  minor = 1u"m"
  angle = deg2rad(360)u"rad"
  len = Geometry2D.ellipseArcLength(angle, major, minor)
  println("ellipseFullCircle $len")
  return len == Geometry2D.circleArcLength(angle, major)
end

#when is this undefined?
function test_ellipseLargeAngle()
  major = 2u"m"
  minor = 1u"m"
  angle = deg2rad(130)u"rad"
  len = Geometry2D.ellipseArcLength(angle, major, minor)
  # println("len $len")
  return true
end

function test_ellipseMinorNegative()
  major = 2u"m"
  minor = -1u"m"
  angle = deg2rad(45)u"rad"
  Geometry2D.ellipseArcLength(angle, major, minor)
  return true 
end

function test_ellipseMajorNegative()
  major = -2u"m"
  minor = 1u"m"
  angle = deg2rad(45)u"rad"
  Geometry2D.ellipseArcLength(angle, major, minor)
  return true
end

"""
Throw a DomainError if `major` < `minor`
"""
function test_ellipseMajorLessMinor()
  major = 1u"m"
  minor = 2u"m"
  angle = deg2rad(45)u"rad"
  Geometry2D.ellipseArcLength(angle, major, minor)
  return true
end

function test_ellipseNegativeAngle()
  major = 2u"m"
  minor = 1u"m"
  angle = deg2rad(30)u"rad"
  lPos = Geometry2D.ellipseArcLength(angle, major, minor)
  lNeg = Geometry2D.ellipseArcLength(-angle, major, minor)
  # println("lPos $lPos lNeg $lNeg")
  return lPos == lNeg
end



@testset "test ellipse length" begin
  @test test_ellipseCircle()
  @test_throws DomainError test_ellipseFullCircle()
  @test_throws DomainError test_ellipseMajorLessMinor()
  @test_throws DomainError test_ellipseMajorNegative()
  @test_throws DomainError test_ellipseMinorNegative()
  @test_throws DomainError test_ellipseLargeAngle()
end