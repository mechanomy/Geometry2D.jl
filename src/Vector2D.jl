# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

export Vector2D, delta, angle, isapprox

"""A vector from `origin` to `tip`"""
struct Vector2D
  origin::Point
  tip::Point
end
@kwdispatch Vector2D()
@kwmethod Vector2D(;origin::Point, tip::Point) = Vector2D(origin, tip)


# distance
# norm

    # @test toStringVectors(seg) == "A:[100.000,100.000]<10.000@90.000°>[100.000,110.000]--B:[-100.000,100.000]<10.000@90.000°>[-100.000,110.000]"

function delta(v::Vector2D) :: Delta
  return v.tip - v.origin
end

import Base.angle
"""Calculate the angle of Delta `d` relative to global x = horizontal"""
function angle(v::Vector2D) :: Angle
  # Both Geometry2D and Base export a method angle(), leading to a collision even though they are differentiated by type, as https://discourse.julialang.org/t/two-modules-with-the-same-exported-function-name-but-different-signature/15231/13
  return angle(delta(v))
end

"""Approximately compare Vectors `a` to `b`"""
function isapprox(a::Vector2D, b::Vector2D; atol=0, rtol=√eps()) :: Bool #these defaults copied from the docs
  return isapprox(a.origin, b.origin, atol=atol, rtol=rtol) && isapprox(a.tip, b.tip, atol=atol, rtol=rtol) 
end

