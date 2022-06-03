
"""A vector from `origin` to `tip`"""
struct Vector2D
  origin::Point
  tip::Point
end
@kwdispatch Vector2D()
@kwmethod Vector2D(;origin::Point, tip::Point) = Vector2D(origin, tip)

function delta(v::Vector2D) :: Delta
  return v.tip - v.origin
end

"""Calculate the angle of Delta `d` relative to global x = horizontal"""
function angle(v::Vector2D)
  return angle(delta(v))
end

function testVector2D()
  @testset "Vector2D constructor" begin
    po = Point(1m, 1m)
    pt = Point(2m, 2m)
    @test typeof( Vector2D(po,pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
    @test typeof( Vector2D(origin=po, tip=pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
  end

  @testset "Vector2D angle calculation" begin
    po = Point(1m, 1m)
    pt = Point(2m, 2m)
    @test angle(Vector2D(po,pt)) == 45°

    pt = Point(2m, 0m)
    @test angle(Vector2D(po,pt)) == -45°
    # @test angle(Vector2D(po,pt)) == 315° =-45, do I want a circular or mod equals?

    pt = Point(0m, 0m)
    @test angle(Vector2D(po,pt)) == -135°
    # @test angle(Vector2D(po,pt)) == 225°
  end
end

"""Approximately compare Vectors `a` to `b`"""
function isapprox(a::Vector2D, b::Vector2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox(a.origin, b.origin, atol=atol, rtol=rtol) && isapprox(a.tip, b.tip, atol=atol, rtol=rtol) 
end

