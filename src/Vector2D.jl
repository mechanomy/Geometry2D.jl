# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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

