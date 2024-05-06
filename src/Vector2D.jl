# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

export Vector2D, delta, isapprox

"""
A 2D vector from `origin` to `tip`.
Functions are provided to convert from the struct's cartesian format to polar.

 FIELDS

"""
struct Vector2D
  """the origin [Point2D](#Geometry2D.Point2D)"""
  origin::Point2D

  """the tip [Point2D](#Geometry2D.Point2D)"""
  tip::Point2D
end
@kwdispatch Vector2D()
"""
    Vector2D(;origin::Point2D, tip::Point2D)
Keyword constructor for a Vector2D from `origin` to `tip`.
"""
@kwmethod Vector2D(;origin::Point2D, tip::Point2D) = Vector2D(origin, tip)
@testitem "Vector2D constructor" begin
  using UnitTypes
  po = Point2D(Meter(1), Meter(1))
  pt = Point2D(Meter(2), Meter(2))
  @test typeof( Vector2D(po,pt) ) <: Vector2D #was the constructor successful? @test_nothrow hasn't shown up yet
  @test typeof( Vector2D(origin=po, tip=pt) ) <: Vector2D
end

"""
    delta(v::Vector2D) :: Delta
Given `v`, return the difference in x and y as a [Delta](#Geometry2D.Delta) from `v`'s tip to origin.
"""
function delta(v::Vector2D) :: Delta
  return v.tip - v.origin
end
@testitem "delta" begin
  using UnitTypes
  dv = delta(Vector2D(Point2D(MilliMeter(1), MilliMeter(1)), Point2D(MilliMeter(2), MilliMeter(2)) ))
  @test dv.dx ≈ MilliMeter(1)
  @test dv.dy ≈ MilliMeter(1)
end

"""
    angle(v::Vector2D) :: Angle
    angleDegree(v::Vector2D) :: typeof(1.0u"°")
Calculate the angle of [Vector2D](#Geometry2D.Vector2D) `v` relative to global x = horizontal, via atan().
"""
function Base.angle(v::Vector2D) 
  return angle(delta(v))
end
function angleRadian(v::Vector2D) :: Radian
  return angleRadian(delta(v))
end
function angleDegree(v::Vector2D) :: Degree
  return angleDegree(delta(v))
end
@testitem "Vector2D angle calculation" begin
  using UnitTypes
  po = Point2D(Meter(1), Meter(1))
  pt = Point2D(Meter(2), Meter(2))
  vot = Vector2D(po,pt)
  @test angle(vot) ≈ Radian(Degree(45)).value
  @test angleDegree(Vector2D(po,pt)) ≈ Degree(45)

  pt = Point2D(Meter(2), Meter(0))
  @test angleDegree(Vector2D(po,pt)) ≈ Degree(-45)
  # @test angle(Vector2D(po,pt)) == 315° =-45, do I want a circular or mod equals?

  pt = Point2D(Meter(0),Meter(0))
  @test angleDegree(Vector2D(po,pt)) ≈ Degree(-135)
  # @test angle(Vector2D(po,pt)) == 225°
end

"""
    isapprox(a::Vector2D, b::Vector2D; atol=0, rtol=√eps()) :: Bool 
Approximately compare [Vector2D](#Geometry2D.Vector2D)s `a` to `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function Base.isapprox(a::Vector2D, b::Vector2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox(a.origin, b.origin, atol=atol, rtol=rtol) && isapprox(a.tip, b.tip, atol=atol, rtol=rtol) 
end
@testitem "isapprox" begin
  using UnitTypes
  va = Vector2D(Point2D(MilliMeter(1), MilliMeter(1)), Point2D(MilliMeter(2), MilliMeter(2)) )
  vb = Vector2D(Point2D(MilliMeter(1.0001), MilliMeter(1)), Point2D(MilliMeter(2), MilliMeter(2)) )
  @test isapprox(va, vb, atol=1e-3)
  vc = Vector2D(Point2D(MilliMeter(1.0001), MilliMeter(1)), Point2D(MilliMeter(2.0001), MilliMeter(2)) )
  @test isapprox(va, vc, atol=1e-3)
end


# distance
# norm
# @test toStringVector2Ds(seg) == "A:[100.000,100.000]<10.000@90.000°>[100.000,110.000]--B:[-100.000,100.000]<10.000@90.000°>[-100.000,110.000]"

