# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

export Vector2D, delta, angle, isapprox

"""
A 2D vector from `origin` to `tip`.
Functions are provided to convert from the struct's cartesian format to polar.

$FIELDS

"""
struct Vector2D
  """the origin [Point](#Geometry2D.Point)"""
  origin::Point

  """the tip [Point](#Geometry2D.Point)"""
  tip::Point
end
@kwdispatch Vector2D()

"""
    Vector2D(;origin::Point, tip::Point)
Keyword constructor for a vector from `origin` to `tip`.
"""
@kwmethod Vector2D(;origin::Point, tip::Point) = Vector2D(origin, tip)

# distance
# norm
# @test toStringVectors(seg) == "A:[100.000,100.000]<10.000@90.000°>[100.000,110.000]--B:[-100.000,100.000]<10.000@90.000°>[-100.000,110.000]"

"""
    delta(v::Vector2D) :: Delta
Given `v`, return the difference in x and y as a [Delta](#Geometry2D.Delta) from `v`'s tip to origin.
"""
function delta(v::Vector2D) :: Delta
  return v.tip - v.origin
end

"""
    angle(v::Vector2D) :: Angle
    angled(v::Vector2D) :: typeof(1.0u"°")
Calculate the angle of [Vector2D](#Geometry2D.Vector2D) `v` relative to global x = horizontal, via atan().
"""
function Base.angle(v::Vector2D) :: Angle
  return angle(delta(v))
end
function angled(v::Vector2D) :: typeof(1.0u"°")
  return angled(delta(v))
end

"""
    isapprox(a::Vector2D, b::Vector2D; atol=0, rtol=√eps()) :: Bool 
Approximately compare [Vector2D](#Geometry2D.Vector2D)s `a` to `b` via absolute tolerance `atol` and relative tolerance `rtol`, as in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
"""
function Base.isapprox(a::Vector2D, b::Vector2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox(a.origin, b.origin, atol=atol, rtol=rtol) && isapprox(a.tip, b.tip, atol=atol, rtol=rtol) 
end

