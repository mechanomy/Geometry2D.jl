
"""A vector from `origin` to `tip`"""
struct Vector
  origin::Point
  tip::Point
end
@kwdispatch Vector()
@kwmethod Vector(;origin::Point, tip::Point) = Vector(origin, tip)

function delta(v::Vector) :: Delta
  return v.tip - v.origin
end

"""Calculate the angle of Delta `d` relative to global x = horizontal"""
function angle(v::Vector)
  return angle(delta(v))
end

function testVector2D()
  @testset "Vector constructor" begin
    po = Point(1m, 1m)
    pt = Point(2m, 2m)
    @test typeof( Vector(po,pt) ) <: Vector #was the constructor successful? @test_nothrow hasn't shown up yet
    @test typeof( Vector(origin=po, tip=pt) ) <: Vector #was the constructor successful? @test_nothrow hasn't shown up yet
  end

  @testset "Vector angle calculation" begin
    po = Point(1m, 1m)
    pt = Point(2m, 2m)
    @test angle(Vector(po,pt)) == 45°

    pt = Point(2m, 0m)
    @test angle(Vector(po,pt)) == -45°
    # @test angle(Vector(po,pt)) == 315° =-45, do I want a circular or mod equals?

    pt = Point(0m, 0m)
    @test angle(Vector(po,pt)) == -135°
    # @test angle(Vector(po,pt)) == 225°
  end
end

"""Approximately compare Vectors `a` to `b`"""
function isapprox(a::Vector, b::Vector; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox(a.origin, b.origin, atol=atol, rtol=rtol) && isapprox(a.tip, b.tip, atol=atol, rtol=rtol) 
end

