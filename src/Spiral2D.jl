# MIT License
# Copyright (c) 2022 Mechanomy LLC
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Spiral2D.jl is a member of Geometry2D.jl via the include()s listed there.

export Spiral, calcPitch, calcLength, isIncreasing, isDecreasing, isClockwise, isCounterClockwise, seriesPolar, seriesCartesian

# @unit rev "rev" Revolution (2*π)u"rad" false
# @derived_dimension Pitch dimension(u"m/rev")
# Unitful.register...
@derived_dimension Pitch dimension(u"m/(2*π*rad)")

# Define these or-types to permit a Spiral to be defined on a Real or 
"""
Type union accepting Unitful.Length or Real.
"""
LengthOrReal = Union{Unitful.Length, Real} 
"""
Type union accepting [`Angle`](#Geometry2D.Angle) or Real.
"""
AngleOrReal = Union{Angle, Real}
"""
Type union accepting [`Pitch`](#Geometry2D.Pitch) or Real.
"""
PitchOrReal = Union{Pitch, Real}

"""
Describes a spiral progressing from `a0`,`r0` to `a1`,`r1`. 
If `thickness` is not specified it is calculated such that each layer touches neighbors, a tightly wound spiral, if it is specified then an open spiral is modeled.
* `a0::AngleOrReal` -- start angle
* `a1::AngleOrReal` -- stop angle
* `r0::LengthOrReal` -- start radius
* `r1::LengthOrReal` -- stop radius
* `pitch::PitchOrReal` -- pitch
"""
struct Spiral
  a0::AngleOrReal #start angle
  a1::AngleOrReal #stop angle
  r0::LengthOrReal #starting radius
  r1::LengthOrReal #stopping radius
  pitch::PitchOrReal #distance between consecutive layers. this is a field to be able to model tight and loose spirals
end

"""
   Spiral( a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal )
Create a Spiral, calculating the pitch from `a0`, `a1`, `r0`, and `r1`.
"""
Spiral( a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal ) = Spiral( a0, a1, r0, r1, calcPitch(a0,a1,r0,r1))

@kwdispatch Spiral()
"""
    Spiral(; a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal, pitch::PitchOrReal) = Spiral(a0, a1, r0, r1, pitch)
Keyword create a Spiral with `a0`, `a1`, `r0`, `r1`, and `pitch`.
"""
@kwmethod Spiral(; a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal, pitch::PitchOrReal) = Spiral(a0, a1, r0, r1, pitch)

"""
    Spiral( a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal )
Keyword create a Spiral, calculating the pitch from `a0`, `a1`, `r0`, and `r1`.
"""
@kwmethod Spiral(; a0::Angle, a1::Angle, r0::Unitful.Length, r1::Unitful.Length) = Spiral(a0, a1, r0, r1, calcPitch(a0,a1,r0,r1)::Pitch )

"""
    Spiral(; a0::Real, a1::Real, r0::Real, r1::Real) = Spiral(a0, a1, r0, r1, calcPitch(a0,a1,r0,r1)::Real )
Keyword create a Spiral, calculating the pitch from `a0`[rad], `a1`[rad], `r0`, and `r1`.
"""
@kwmethod Spiral(; a0::Real, a1::Real, r0::Real, r1::Real) = Spiral(a0, a1, r0, r1, calcPitch(a0,a1,r0,r1)::Real )


"""
    isCounterClockwise(s::Spiral) :: Bool
2D Spirals are 'counterclockwise' if of increasing angle, `a0` to `a1`.
"""
function isCounterClockwise(s::Spiral) :: Bool
  return s.a0 < s.a1
end
"""
    isClockwise(s::Spiral) :: Bool
Conversely, clockwise implies decreasing angle.
"""
function isClockwise(s::Spiral) :: Bool
  return s.a0 > s.a1
end

"""
    isIncreasing(s::Spiral) :: Bool
Does the radius increase?
"""
function isIncreasing(s::Spiral) :: Bool
  return s.r0 < s.r1
end
"""
    isDecreasing(s::Spiral) :: Bool
Does the radius decrease"""
function isDecreasing(s::Spiral) :: Bool
  return s.r0 > s.r1
end

"""
    calcPitch(a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal)
    calcPitch(; a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal)
    calcPitch(s::Spiral)
Calculate a spiral's pitch from (`r1`-`r0`)/(`a1`-`a0`).
The nominal units of Pitch defined to be [m/rev], but this will return Real if the arguments or Spiral are that, or a Pitch,m/rad,m/deg depending on __. 
"""
function calcPitch(a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal)
  return abs( (r1-r0)/(a1-a0) ) * ( r0<r1 ? 1 : -1)
end
calcPitch(; a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal) = calcPitch(a0,a1,r0,r1)
calcPitch(s::Spiral) = calcPitch(s.a0, s.a1, s.r0, s.r1)


"""
    calcLength(a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal)
    calcLength(;a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal)
    calcLength(s::Spiral)
Length along the spiral, as if it were unrolled.
"""
function calcLength(a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal)
  if r0 < 0*unit(r0)
    @warn "calcLength() given r0=$r0, coerced to 0 as r0 < 0 is nonsensical."
    r0 = 0*unit(r0)
  end
  if r1 < 0*unit(r1)
    @warn "calcLength() given r1=$r1, coerced to 0 as r1 < 0 is nonsensical."
    r1 = 0*unit(r1)
  end

  if a0 == a1 && r0 != r1 # a straight, radial line
    return r1-r0
  end

  # this is likely approximate, see https://www.engineeringtoolbox.com/spiral-length-d_2191.html 
  if 0*unit(r1) < r1
    return  abs( ustrip(u"rad", (a1-a0)/2) * (r1+r0) )
  else 
    return 0*unit(r0)
  end
end
calcLength(;a0::AngleOrReal, a1::AngleOrReal, r0::LengthOrReal, r1::LengthOrReal) = calcLength(a0,a1,r0,r1)
calcLength(s::Spiral) = calcLength(s.a0, s.a1, s.r0, s.r1)


"""
    seriesPolar(s::Spiral, n::Int=1000)
    seriesPolar(; s::Spiral, n::Int=1000)
Spread `n` points over spiral `s`, returning an (`angles`,`radii`) tuple.
"""
function seriesPolar(s::Spiral, n::Int=1000)
  als = LinRange(s.a0, s.a1, n)
  rs = LinRange(s.r0, s.r1, n)
  return (collect(als),collect(rs))
end
seriesPolar(; s::Spiral, n::Int=1000) = seriesPolar(s, n)

"""
    seriesCartesian(s::Spiral, n::Int=1000)
    seriesCartesian(; s::Spiral, n::Int=1000)
Spread `n` points over spiral `s`, returning an (`xs`,`ys`) tuple"""
function seriesCartesian(s::Spiral, n::Int=1000)
  (als,rs) = seriesPolar(s, n)
  return ( rs .* cos.(als), rs .* sin.(als) )
end
seriesCartesian(; s::Spiral, n::Int=1000) = seriesCartesian(s,n)

