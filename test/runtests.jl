
using Test
using Unitful

include("../src/Geometry2D.jl")

# test rationale:
# - Uniful conversions are correct
# - math operations correct...
function testPoint()
  p = Geometry2D.Point(1u"mm",2u"inch")
  return p.x == 1e-3u"m" && p.y == 50.8u"mm"
end
function testCircle()
  p = Geometry2D.Point(1u"mm",2u"inch")
  c = Geometry2D.Circle(p, 5u"mm")
  return c.ctr.x == 1u"mm" && c.ctr.y == 50.8u"mm" && c.r == 5u"mm"
end
function testVectorLengthAngle()
  vla = Geometry2D.vectorLengthAngle( 10u"mm", 10u"rad" )
  return Geometry2D.normalize(vla) == 10u"mm"
end
@testset "test Geometry2D.Point" begin
  @test testPoint()
  @test testCircle()
  @test testVectorLengthAngle()
end
